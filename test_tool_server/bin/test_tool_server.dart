import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

Future<void> main(List<String> args) async {
  print('test_tool_server starting');
  final result = (ArgParser() //
        ..addOption('forFlutterPort', defaultsTo: '5678')
        ..addOption('forAppPort', defaultsTo: '5679'))
      .parse(args);
  await run(
    forFlutterPort: int.parse(result['forFlutterPort']!),
    forAppPort: int.parse(result['forAppPort']!),
  );
}

Future<void> run({
  String address = '0.0.0.0',
  required int forFlutterPort,
  required int forAppPort,
}) async {
  final forFlutterServer = _WebSocketServer('forFlutter', address, forFlutterPort);
  final forAppServer = _WebSocketServer('forApp', address, forAppPort);
  _bridgeWebSocket(forFlutterServer, forAppServer);
  _bridgeWebSocket(forAppServer, forFlutterServer);

  await forFlutterServer.init();
  await forAppServer.init();
}

void _bridgeWebSocket(_WebSocketServer src, _WebSocketServer dst) {
  src.onData = (data) {
    final targetConn = dst.activeConn;
    if (targetConn == null) {
      print('WARN drop message that ${src.name} receives, since ${dst.name} does not have activeConn');
      return;
    }

    print('${src.name}.recv data (len=${(data as List).length}) --bridge--> ${dst.name}.send');
    targetConn.add(data);
  };
}

/// NOTE ref https://stackoverflow.com/questions/52580311/echo-websocket-in-dart/52591092#52591092
class _WebSocketServer {
  final String name;
  final String address;
  final int port;

  late final void Function(dynamic data) onData;

  _WebSocketServer(this.name, this.address, this.port);

  WebSocket? activeConn;

  Future<void> init() async {
    final server = await HttpServer.bind(address, port);
    print('$name bind on $address $port');

    server.transform(WebSocketTransformer()).listen((ws) {
      print('$name new connection: ${ws.hashCode}');

      final oldActiveConn = activeConn;
      if (oldActiveConn != null) {
        print('$name close oldActiveConn(${oldActiveConn.hashCode})');
        oldActiveConn.close();
      }

      activeConn = ws;
      ws.listen(
        onData,
        onError: (e, s) {
          print('$name see error: $e $s');
        },
        onDone: () {
          print('$name end connection: ${ws.hashCode}');
          if (activeConn == ws) activeConn = null;
        },
      );
    });
  }
}
