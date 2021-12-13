// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_tool_flutter/test_tool_flutter.dart';

typedef ExampleArg = String Function();

void main({ExampleArg? exampleArg}) {
  print('(pid=$pid) lib/main.dart::main called exampleArg=$exampleArg');
  runApp(MyApp(exampleArg: exampleArg));
}

class MyApp extends StatelessWidget {
  final ExampleArg? exampleArg;

  const MyApp({Key? key, this.exampleArg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureVisualizer(
      child: MaterialApp(home: MyHomePage(exampleArg: exampleArg)),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ExampleArg? exampleArg;

  const MyHomePage({Key? key, this.exampleArg}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    print('(pid=$pid) lib/main.dart::_MyHomePageState::build called counter=$_counter');

    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Count: '),
            Text('$_counter'),
            const Text('ExampleArg: '),
            Text(widget.exampleArg?.call() ?? ''),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _counter++),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
