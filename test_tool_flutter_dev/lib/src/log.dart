// 参考：https://docs.cypress.io/api/cypress-api/cypress-log#Arguments

// ignore_for_file: implementation_imports

import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'package:test_api/src/backend/live_test.dart';
import 'package:test_tool_flutter_dev/src/rpc.dart';
import 'package:test_tool_flutter_dev/src/snapshot.dart';
import 'package:test_tool_flutter_dev/src/util.dart';
import 'package:test_tool_proto/test_tool_proto.dart';

import 'core.dart';

extension TestToolLog on TestTool {
  // p.s. 关于emoji，可以去这里搜索 - https://emojipedia.org
  LogHandle log(String title, String message, {LogEntryType? type}) => testToolLog(title, message, type: type);
}

LogHandle testToolLog(
  String title,
  String message, {
  LogEntryType? type,
  String? error,
  String? stackTrace,
  LiveTest? liveTest,
}) {
  type ??= LogEntryType.GENERAL_MESSAGE;
  liveTest ??= Invoker.current!.liveTest;

  final log = LogHandle(
    TestToolIdGen.nextId(),
    testGroupsToName(liveTest.groups),
    liveTest.test.name,
  );

  log.update(
    title,
    message,
    type: type,
    error: error,
    stackTrace: stackTrace,
    printing: true, // <--
  );

  return log;
}

typedef LogUpdate = void Function(
  String title,
  String message, {
  String? error,
  String? stackTrace,
  required LogEntryType type,
  bool printing,
});
typedef LogSnapshot = Future<void> Function({
  String name,
});

class LogHandle {
  final int _id;
  final String _testGroupName;
  final String _testEntryName;

  LogHandle(this._id, this._testGroupName, this._testEntryName);

  void update(
    String title,
    String message, {
    String? error,
    String? stackTrace,
    required LogEntryType type,
    bool printing = false,
  }) {
    TestToolRpcClient.send(Event(
      logEntry: LogEntry(
        id: _id,
        testGroupName: _testGroupName,
        testEntryName: _testEntryName,
        type: type,
        title: title,
        message: message,
        error: error,
        stackTrace: stackTrace,
      ),
    ));

    if (printing) {
      printWrapped('${_typeToLeading(type)} $title $message $error $stackTrace');
    }
  }

  Future<void> snapshot({String name = 'default', List<int>? image}) async {
    image ??= await takeSnapshot();
    TestToolRpcClient.send(Event(
      snapshot: Snapshot(
        logEntryId: _id,
        name: name,
        image: image,
      ),
    ));
  }
}

String _typeToLeading(LogEntryType type) {
  switch (type) {
    case LogEntryType.TEST_START:
    case LogEntryType.TEST_END:
      return '🟤';
    case LogEntryType.GENERAL_MESSAGE:
    default:
      return '🔵';
  }
}

String testGroupsToName(List<Group> testGroups) {
  return testGroups //
      .map((g) => g.name)
      .where((name) => name.isNotEmpty)
      .join('-');
}

/// https://stackoverflow.com/questions/49138971/logging-large-strings-from-flutter
void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0))); // ignore: avoid_print
}
