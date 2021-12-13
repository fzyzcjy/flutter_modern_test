import 'package:flutter/material.dart';
import 'package:test_tool_app/misc/setup.dart';
import 'package:test_tool_app/pages/home_page.dart';

void main() {
  setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test_tool_app',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}
