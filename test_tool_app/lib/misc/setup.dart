import 'package:get_it/get_it.dart';
import 'package:test_tool_app/services/rpc_service.dart';
import 'package:test_tool_app/stores/log_store.dart';
import 'package:test_tool_app/stores/organization_store.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<LogStore>(LogStore());
  getIt.registerSingleton<OrganizationStore>(OrganizationStore());

  getIt.registerSingleton<RpcService>(RpcService());
}
