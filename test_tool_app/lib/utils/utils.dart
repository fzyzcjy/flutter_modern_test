import 'package:test_api/src/backend/state.dart'; // ignore: implementation_imports
import 'package:test_tool_proto/test_tool_proto.dart';

extension ExtTestEntryState on TestEntryState {
  State toState() => State(Status.parse(status), Result.parse(result));
}
