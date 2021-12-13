import 'package:collection/collection.dart';
import 'package:common_dart/utils/relations.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:test_tool_proto/test_tool_proto.dart';

part 'organization_store.g.dart';

class OrganizationStore = _OrganizationStore with _$OrganizationStore;

abstract class _OrganizationStore with Store {
  static var _nextId = 1000000;

  final testGroupIds = ObservableList<int>();
  final testEntryInGroup = RelationOneToMany();

  final testGroupMap = ObservableMap<int, TestGroup>();
  final testEntryMap = ObservableMap<int, TestEntry>();

  final testEntryStateMap =
      ObservableDefaultMap<int, TestEntryState>(defaultValue: TestEntryState(status: 'pending', result: 'success'));

  final expandTestGroupMap = ObservableDefaultMap<int, bool>(defaultValue: false);
  final expandTestEntryMap = ObservableDefaultMap<int, bool>(defaultValue: false);

  @observable
  bool enableAutoExpand = true;

  @computed
  List<int> get allTestEntryIds => testGroupIds.expand((testGroupId) => testEntryInGroup[testGroupId]!).toList();

  int testGroupNameToId(String name) {
    final item = testGroupMap.values.singleWhereOrNull((item) => item.name == name);
    if (item != null) return item.id;

    final id = _nextId++;
    testGroupMap[id] = TestGroup(id: id, name: name);
    testGroupIds.add(id);
    return id;
  }

  int testEntryNameToId(String name, {int? testGroupId}) {
    final item = testEntryMap.values.singleWhereOrNull((item) => item.name == name);
    if (item != null) return item.id;

    if (testGroupId == null) throw Exception('need to implicitly create test entry, but no testGroupId provided');
    final id = _nextId++;
    testEntryMap[id] = TestEntry(id: id, name: name, testGroupId: testGroupId);
    testEntryInGroup.addRelation(testGroupId, id);
    return id;
  }

  void clear() {
    testGroupIds.clear();
    testEntryInGroup.clear();
    testGroupMap.clear();
    testEntryMap.clear();
    expandTestGroupMap.clear();
    expandTestEntryMap.clear();
  }
}

@immutable
class TestGroup {
  final int id;
  final String name;

  TestGroup({required this.id, required this.name});
}

@immutable
class TestEntry {
  final int id;
  final int testGroupId;
  final String name;

  TestEntry({required this.id, required this.testGroupId, required this.name});
}
