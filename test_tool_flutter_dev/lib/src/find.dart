import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recase/recase.dart';
import 'package:test_tool_flutter/test_tool_flutter.dart';
import 'package:test_tool_flutter_dev/src/util.dart';
import 'package:test_tool_proto/test_tool_proto.dart';

import 'core.dart';
import 'interaction.dart';
import 'log.dart';

extension TestToolFind on TestTool {
  TFinderCommand get(Object arg) => TFinderCommand(this, find.get(arg));

  TCommand routeName() => TRouteNameCommand(this);

  TRawCommand raw(Object value) => TRawCommand(this, value);
}

extension ExtCommonFinders on CommonFinders {
  /// 智能get
  Finder get(Object arg) {
    if (arg is Finder) return arg;
    if (arg is List) return byArray(arg.map((Object? e) => get(e!)).toList());
    return bySel(arg);
  }

  // 思路ref: cypress-realworld-app command: getBySel
  // 开发ref: [CommonFinders.byTooltip]
  Finder bySel(Object name, {bool skipOffstage = true, bool Function(Mark mark)? predicate}) {
    var description = '$name';
    // hacky, 美化形如[LoginMark.username]
    // NOTE 仅在代码未混淆时能用...
    if (_isEnum(name) && name.runtimeType.toString().endsWith('Mark')) {
      final cls = name.toString().split('.')[0];
      final modifiedCls = ReCase(cls.substring(0, cls.length - 'Mark'.length)).camelCase;
      description = '$modifiedCls#${describeEnum(name)}';
    }

    return byWidgetPredicate(
      (widget) => widget is Mark && widget.name == name && (predicate?.call(widget) ?? true),
      description: description + (predicate == null ? '' : ' with extra predicate'),
      skipOffstage: skipOffstage,
    );
  }

  Finder byArray(List<Finder> finders) {
    assert(finders.isNotEmpty);

    final description = finders.map((f) => f.description).join(' -> ');

    var ans = finders[0];
    for (var i = 1; i < finders.length; i++) {
      ans = find.descendant(of: ans, matching: finders[i]);
    }
    ans = DelegatingFinder(ans, overrideDescription: description);

    return ans;
  }

  /// 改编自[byTooltip]
  Finder myByTooltip(String message, {bool skipOffstage = true}) {
    return byWidgetPredicate(
      (Widget widget) => widget is Tooltip && widget.message == message,
      skipOffstage: skipOffstage,
      // NOTE XXX add
      description: 'Tooltip with `$message`',
    );
  }
}

class TFinderCommand extends TCommand {
  @protected
  final Finder finder;

  TFinderCommand(TestTool t, this.finder) : super(t);

  @override
  Object? getCurrentActual() => finder;

  Future<void> enterText(String text) => act(
        act: () => t.tester.enterText(finder, text),
        logTitle: 'TYPE',
        logMessage: '"$text" to ${finder.description}',
      );

  Future<void> tap() => act(
        act: () => t.tester.tap(finder),
        logTitle: 'TAP',
        logMessage: finder.description,
      );

  Future<void> longPress() => act(
        act: () => t.tester.longPress(finder),
        logTitle: 'LONG PRESS',
        logMessage: finder.description,
      );

  Future<void> drag(Offset offset) => act(
        act: () => t.tester.drag(finder, offset),
        logTitle: 'DRAG',
        logMessage: finder.description,
      );

  Future<void> act({
    required Future<void> Function() act,
    required String logTitle,
    required String logMessage,
  }) async {
    final log = t.log(logTitle, logMessage);

    await t.pump();
    await log.snapshot(name: 'before');

    // 在tap之类的操作前，首先等那个按钮可见
    // ref Cypress文档 https://docs.cypress.io/guides/core-concepts/retry-ability#Built-in-assertions
    await shouldRaw(
      findsOneWidget,
      logUpdate: (title, message, {error, stackTrace, required type, printing = false}) => log
          .update(logTitle + ' ASSERT', message, type: type, error: error, stackTrace: stackTrace, printing: printing),
      // 不take snapshot
      logSnapshot: null,
    );
    // 更新一下log，因为[should]会修改log内容
    log.update(logTitle, logMessage, type: LogEntryType.GENERAL_MESSAGE);

    await act();

    await t.pumpAndSettle();

    await log.snapshot(name: 'after');
  }
}

class TRouteNameCommand extends TCommand {
  TRouteNameCommand(TestTool t) : super(t);

  @override
  Object? getCurrentActual() {
    final context = TestTool.slot.getNavContext(t);
    if (context == null) return null;

    // https://stackoverflow.com/questions/50817086/how-to-check-which-the-current-route-is?rq=1
    late final Route currentRoute;
    Navigator.popUntil(context, (route) {
      currentRoute = route;
      return true;
    });
    return currentRoute.settings.name;
  }
}

class TRawCommand extends TCommand {
  final Object? value;

  TRawCommand(TestTool t, this.value) : super(t);

  @override
  Object? getCurrentActual() => value;
}

// https://stackoverflow.com/questions/53924131/how-to-check-if-value-is-enum
bool _isEnum(dynamic data) {
  final split = data.toString().split('.');
  return split.length > 1 && split[0] == data.runtimeType.toString();
}
