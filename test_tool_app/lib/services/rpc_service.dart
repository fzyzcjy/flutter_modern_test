import 'dart:typed_data';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:test_tool_app/stores/log_store.dart';
import 'package:test_tool_app/stores/organization_store.dart';
import 'package:test_tool_proto/test_tool_proto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'rpc_service.g.dart';

class RpcService = _RpcService with _$RpcService;

final testToolServerAddr = () {
  const kTestToolServerAddrKey = 'TEST_TOOL_SERVER_ADDR';
  if (!const bool.hasEnvironment(kTestToolServerAddrKey)) {
    throw Exception('please provide compile-time constant $kTestToolServerAddrKey');
  }
  return const String.fromEnvironment(kTestToolServerAddrKey);
}();

abstract class _RpcService with Store {
  final channel = WebSocketChannel.connect(Uri.parse(testToolServerAddr));

  _RpcService() {
    _setUpListen();
  }

  @action
  Future<void> _setUpListen() async {
    await for (final data in channel.stream) {
      final event = Event.fromBuffer(data);

      switch (event.whichSubType()) {
        case Event_SubType.testSystemBoot:
          _handleTestSystemBoot(event.testSystemBoot);
          break;
        case Event_SubType.logEntry:
          _handleLogEntry(event.logEntry);
          break;
        case Event_SubType.testEntryInfo:
          _handleTestEntryInfo(event.testEntryInfo);
          break;
        case Event_SubType.runnerStateChange:
          _handleRunnerStateChange(event.runnerStateChange);
          break;
        case Event_SubType.runnerOnError:
          _handleRunnerOnError(event.runnerOnError);
          break;
        case Event_SubType.runnerOnMessage:
          _handleRunnerOnMessage(event.runnerOnMessage);
          break;
        case Event_SubType.snapshot:
          _handleSnapshot(event.snapshot);
          break;
        case Event_SubType.notSet:
        default:
          throw Exception('unknown ${event.whichSubType()}');
      }
    }
    print('finish stub.recvEvents');
  }

  void _handleTestSystemBoot(TestSystemBoot testSystemBoot) {
    _organizationStore.clear();
    _logStore.clear();
  }

  void _handleLogEntry(LogEntry logEntry) {
    _logStore.logEntryMap.addToIdObjMap(logEntry);

    final testGroupId = _organizationStore.testGroupNameToId(logEntry.testGroupName);
    final testEntryId = _organizationStore.testEntryNameToId(logEntry.testEntryName, testGroupId: testGroupId);

    if (!(_logStore.logEntryInTest[testEntryId]?.contains(logEntry.id) ?? false)) {
      _logStore.logEntryInTest.addRelation(testEntryId, logEntry.id);
    }

    if (_organizationStore.enableAutoExpand) {
      _organizationStore
        ..expandTestGroupMap.clear()
        ..expandTestGroupMap[testGroupId] = true
        ..expandTestEntryMap.clear()
        ..expandTestEntryMap[testEntryId] = true;
    }
  }

  void _handleTestEntryInfo(TestEntryInfo testEntryInfo) {
    final testGroupId = _organizationStore.testGroupNameToId(testEntryInfo.testGroupName);
    // ignore: unused_local_variable
    final testEntryId = _organizationStore.testEntryNameToId(testEntryInfo.testEntryName, testGroupId: testGroupId);
  }

  void _handleRunnerStateChange(RunnerStateChange runnerStateChange) {
    final testEntryId = _organizationStore.testEntryNameToId(runnerStateChange.testEntryName);
    _organizationStore.testEntryStateMap[testEntryId] = runnerStateChange.state;
  }

  void _handleRunnerOnError(RunnerOnError runnerOnError) {
    // TODO
    // TODO
    // TODO
  }

  void _handleRunnerOnMessage(RunnerOnMessage runnerOnMessage) {
    // TODO
    // TODO
    // TODO
  }

  void _handleSnapshot(Snapshot snapshot) {
    _logStore.snapshotInLog[snapshot.logEntryId] ??= ObservableMap();
    _logStore.snapshotInLog[snapshot.logEntryId]![snapshot.name] = snapshot.image as Uint8List;
  }

  final _logStore = GetIt.I.get<LogStore>();
  final _organizationStore = GetIt.I.get<OrganizationStore>();
}

extension ExtMapAddToIdObj<T> on Map<int, T> {
  void addToIdObjMap(T obj) {
    this[(obj as dynamic).id] = obj;
  }
}
