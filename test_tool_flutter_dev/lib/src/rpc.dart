import 'package:test_tool_flutter_dev/test_tool_flutter_dev.dart';
import 'package:test_tool_proto/test_tool_proto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TestToolRpcClient {
  static final instance = TestToolRpcClient._();

  final channel = WebSocketChannel.connect(TestTool.slot.getServerUri());

  TestToolRpcClient._();

  static void send(Event event) => instance.channel.sink.add(event.writeToBuffer());
}
