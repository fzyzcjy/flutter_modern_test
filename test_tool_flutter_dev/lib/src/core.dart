import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:test_api/test_api.dart' as test_package; // ignore: deprecated_member_use
import 'package:test_tool_flutter_dev/src/rpc.dart';
import 'package:test_tool_flutter_dev/src/test_compat.dart';
import 'package:test_tool_proto/test_tool_proto.dart';

import 'interaction.dart';
import 'log.dart';

class TestTool {
  static late TestToolSlot slot;

  @internal
  final WidgetTester tester;

  TestTool(this.tester);
}

/// 由使用者自行填充，本测试框架要用
abstract class TestToolSlot {
  Future<void> startApp(TestTool t);

  BuildContext? getNavContext(TestTool t);

  Uri getServerUri();
}

typedef TWidgetTesterCallback = Future<void> Function(TestTool t);

/// 请用本函数包裹整个测试代码(应当只执行1次)
void tWrap(void Function() body) {
  _setUpExceptionReporter();

  final declarer = collectIntoDeclarer(() {
    TestToolRpcClient.send(Event(testSystemBoot: TestSystemBoot()));
    _setUpLogTestStartAndEnd();
    body();
  });

  runTestsInDeclarer(declarer);
}

void _setUpExceptionReporter() {
  // NOTE 看[reportTestException]的注释发现，它就是用于我们这种想要自定义捕捉异常情况的
  reportTestException = _testToolTestExceptionReporter;
}

/// NOTE XXX edited from flutter官方的_defaultTestExceptionReporter
/// https://github.com/flutter/flutter/blob/e7b7ebc066c1b2a5aa5c19f8961307427e0142a6/packages/flutter_test/lib/src/test_exception_reporter.dart#L31
void _testToolTestExceptionReporter(FlutterErrorDetails errorDetails, String testDescription) {
  FlutterError.dumpErrorToConsole(errorDetails, forceReport: true);
  test_package.registerException(_dumpErrorToString(errorDetails), errorDetails.stack ?? StackTrace.empty);
}

/// 参考[FlutterError.dumpErrorToConsole]，但输出到string而非console
String _dumpErrorToString(FlutterErrorDetails details) {
  // NOTE 根据[dumpErrorToConsole]注释，这个只在dev时能用……所以如果profile/release要用它，要把[dumpErrorToConsole]的其他代码也给移植过来
  return TextTreeRenderer(
    wrapWidth: FlutterError.wrapWidth,
    wrapWidthProperties: FlutterError.wrapWidth,
    maxDescendentsTruncatableNode: 5,
  ).render(details.toDiagnosticsNode(style: DiagnosticsTreeStyle.error)).trimRight();
}

void _setUpLogTestStartAndEnd() {
  setUp(() async {
    testToolLog('START', '', type: LogEntryType.TEST_START);
  });
  tearDown(() async {
    testToolLog('END', '', type: LogEntryType.TEST_END);
  });
}

@isTest
void tTestWidgets(
  // ... forward the arguments ...
  String description,
  TWidgetTesterCallback callback, {
  bool skip = false,
}) {
  testWidgets(
    description,
    (tester) async {
      testToolLog('BODY', '', type: LogEntryType.TEST_BODY);

      final t = TestTool(tester);

      await TestTool.slot.startApp(t);

      await callback(t);

      // hack，否则hot restart有时会导致这个变量被莫名其妙地设置了，从而assert失败
      // TODO 这个hack靠谱吗？
      debugDefaultTargetPlatformOverride = null;
    },
    skip: skip,
  );
}

void tTestWidgetsAlias(String description, {required String implementedAt}) {
  // nothing yet，只是个标识
}

extension ExtTestToolCore on TestTool {
  void section(String description) => log('SECTION', description);
}

abstract class TCommand {
  @protected
  final TestTool t;

  // NOTE 不能保存actual，而是需要用的时候动态读取
  //      因为需要retry-ability。比如actual是个String，那retry时永远只能拿到这个一开始读取的string，重试就没有意义
  @protected
  Object? getCurrentActual();

  TCommand(this.t);

  Future<void> should(Matcher matcher, {String? reason}) async {
    final log = t.log('ASSERT', '', type: LogEntryType.ASSERT);
    await shouldRaw(matcher, logUpdate: log.update, logSnapshot: log.snapshot);
  }

  Future<void> shouldRaw(
    Matcher matcher, {
    String? reason,
    required LogUpdate logUpdate,
    required LogSnapshot? logSnapshot,
  }) =>
      _expectWithRetry(t, getCurrentActual, matcher, reason: reason, logUpdate: logUpdate, logSnapshot: logSnapshot);

  // 语法糖
  Future<void> shouldEquals(dynamic expected, {String? reason}) => should(equals(expected), reason: reason);
}

// NOTE "retry-ability"思想，详见 https://docs.cypress.io/guides/core-concepts/retry-ability
Future<void> _expectWithRetry(
  TestTool t,
  ValueGetter<Object?> actualGetter,
  dynamic matcher, {
  String? reason,
  dynamic skip,
  Duration timeout = const Duration(seconds: 4),
  required LogUpdate logUpdate,
  required LogSnapshot? logSnapshot,
}) async {
  final startTime = DateTime.now();
  var failedCount = 0;
  while (true) {
    // 为何要update：因为[actualGetter]可能在变化
    logUpdate('ASSERT', '{${actualGetter()}} matches {${matcher.describe(StringDescription())}}',
        type: LogEntryType.ASSERT);

    final actual = actualGetter();
    try {
      expect(actual, matcher, reason: reason, skip: skip);
      await logSnapshot?.call(name: 'after');
      return;
    } on TestFailure catch (e, s) {
      failedCount++;

      final duration = DateTime.now().difference(startTime);
      if (duration >= timeout) {
        logUpdate(
          'ASSERT',
          'after $failedCount retries with ${duration.inMilliseconds} milliseconds',
          type: LogEntryType.ASSERT_FAIL,
          error: '$e\n${getTestFailureErrorExtraInfo(actual)}',
          stackTrace: '$s',
          printing: true,
        );
        await logSnapshot?.call(name: 'after');
        rethrow;
      }

      await t.pumpAndSettle();
      // TODO 是否加Future.delayed（可能不能随便用Future.delayed之类，因为小心test环境下的假时钟...）
    }
  }
}

String getTestFailureErrorExtraInfo(dynamic actual) {
  if (actual is Finder) {
    // ref: [Finder.toString]
    final elements = actual.evaluate().toList();
    final info = elements.mapIndexed((index, Element element) {
      final reversedAncestors = [element];
      element.visitAncestorElements((ancestorElement) {
        reversedAncestors.add(ancestorElement);
        return true;
      });
      return '[Found Element #$index]\n' + reversedAncestors.reversed.map((e) => '-> ${e.toString()}').join('\n');
    }).join('\n\n');
    return 'Extra Info: matched elements are:\n' + info;
  }
  return '';
}
