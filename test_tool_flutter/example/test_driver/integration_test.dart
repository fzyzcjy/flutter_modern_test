// @dart=2.9

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  print('(pid=$pid) test_driver/integration_test.dart::main called');
  return integrationDriver();
}
