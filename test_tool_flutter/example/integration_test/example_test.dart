// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  print('(pid=$pid) integration_test/example_test.dart::main called');

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('e2e test', () {
    testWidgets('TODO', (tester) async {
      // TODO
    });
  });

  print('(pid=$pid) integration_test/example_test.dart::main end');
}

// testWidgets('example one', (tester) async {
//   print('(pid=$pid) integration_test/example_test.dart::main::exampleOne called');
//
//   _printInfo();
//   print('call app.main');
//   app.main(exampleArg: () {
//     print('(pid=$pid) integration_test/example_test.dart::main exampleArg callback is called');
//     return 'exampleOne';
//   });
//
//   _printInfo();
//   print('call pumpAndSettle (before)');
//   await tester.pumpAndSettle();
//
//   _printInfo();
//   print('call pumpAndSettle (after)');
//
//   // print('debug try finder (before)');
//   // _printInfo();
//   // find.text('1');
//   // print('debug try finder (after)');
//   // _printInfo();
//
//   _printInfo();
//   print('call finder');
//   final Finder fab = find.byTooltip('Increment');
//
//   _printInfo();
//   print('call tap');
//   await tester.tap(fab);
//
//   _printInfo();
//   print('call pumpAndSettle');
//   await tester.pumpAndSettle();
//
//   _printInfo();
//   print('call expect');
//   expect(find.text('1'), findsOneWidget);
//   // {
//   //   var finder = find.text('1');
//   //   print('after finder, before expect');
//   //   _printInfo();
//   //   expect(finder, findsOneWidget);
//   // }
//
//   _printInfo();
//   print('end of one test');
//
//   // hack!
//   debugDefaultTargetPlatformOverride = null;
// });
//
// testWidgets('example two', (tester) async {
//   print('integration_test/example_test.dart::main::exampleTwo called');
//   _printInfo();
//
//   print('call app.main');
//   app.main(exampleArg: () {
//     print('integration_test/example_test.dart::main exampleArg callback is called');
//     return 'exampleTwo';
//   });
//   await tester.pumpAndSettle();
//
//   expect(find.text('exampleTwo'), findsOneWidget);
//
//   final Finder fab = find.byTooltip('Increment');
//
//   await tester.tap(fab);
//   await tester.pumpAndSettle();
//   await tester.tap(fab);
//   await tester.pumpAndSettle();
//   expect(find.text('2'), findsOneWidget);
//
//   // hack!
//   // debugDefaultTargetPlatformOverride = null;
// });
//
// testWidgets('fail it', (tester) async {
//   app.main(exampleArg: () => 'exampleThree');
//   await tester.pumpAndSettle();
//
//   expect(find.text('this should fail'), findsOneWidget);
// });
//
// void _printInfo() {
//   print('debugPrint=$debugPrint '
//       'debugDefaultTargetPlatformOverride=$debugDefaultTargetPlatformOverride '
//       'debugDoublePrecision=$debugDoublePrecision '
//       'debugBrightnessOverride=$debugBrightnessOverride ');
// }
//
