import 'package:get_it/get_it.dart';
import 'package:test_tool_app/stores/organization_store.dart';

extension ExtTestGroup on TestGroup {
  String get briefName => name;
}

extension ExtTestEntry on TestEntry {
  String get briefName {
    final organizationStore = GetIt.I.get<OrganizationStore>();
    final testGroup = organizationStore.testGroupMap[testGroupId];
    if (testGroup == null) return name;

    final prefix = testGroup.briefName;
    if (name.startsWith(prefix)) return name.substring(prefix.length);
    return name;
  }
}
