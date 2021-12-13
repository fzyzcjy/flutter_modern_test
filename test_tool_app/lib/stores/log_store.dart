import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:common_dart/utils/relations.dart';
import 'package:mobx/mobx.dart';
import 'package:test_tool_proto/test_tool_proto.dart';

part 'log_store.g.dart';

class LogStore = _LogStore with _$LogStore;

abstract class _LogStore with Store {
  final logEntryInTest = RelationOneToMany();

  final logEntryMap = ObservableMap<int, LogEntry>();

  /// `snapshotInLog[logEntryId][name] == snapshot bytes`
  final snapshotInLog = ObservableMap<int, ObservableMap<String, Uint8List>>();

  @observable
  int? activeLogEntryId;

  @observable
  String? activeSnapshotName;

  @computed
  String? get effectiveActiveSnapshotName {
    if (activeSnapshotName != null) return activeSnapshotName;
    return snapshotInLog[activeLogEntryId]?.keys.firstOrNull;
  }

  void clear() {
    logEntryInTest.clear();
    logEntryMap.clear();
    snapshotInLog.clear();
    activeLogEntryId = null;
    activeSnapshotName = null;
  }
}
