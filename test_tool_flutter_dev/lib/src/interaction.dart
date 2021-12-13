import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';

import 'core.dart';
import 'log.dart';

extension TestToolInteraction on TestTool {
  Future<void> visit(String routeName, {Object? arguments}) async {
    final log = this.log('VISIT', routeName + (arguments != null ? ' arg=${jsonEncode(arguments)}' : ''));

    await pump();
    await log.snapshot(name: 'before');

    // 如果await，会一直等到这个页面退出为止，当然不是我们想要的
    unawaited(Navigator.pushNamed(TestTool.slot.getNavContext(this)!, routeName, arguments: arguments));

    await pumpAndSettle();
    await log.snapshot(name: 'after');
  }

  Future<void> pageBack() async {
    final log = this.log('POP', '');

    await pump();
    await log.snapshot(name: 'before');

    await tester.pageBack();

    await pumpAndSettle();
    await log.snapshot(name: 'after');
  }

  Future<void> pullDownToRefresh() async {
    final log = this.log('PULL REFRESH', '');

    await pump();
    await log.snapshot(name: 'before');

    // ref https://github.com/peng8350/flutter_pulltorefresh/blob/master/test/refresh_test.dart
    await tester.drag(find.byType(MaterialApp), const Offset(0, 100));

    await pumpAndSettle();
    await log.snapshot(name: 'after');
  }

  Future<void> pump([Duration? duration]) => tester.pump(duration);

  Future<int> pumpAndSettle() => tester.pumpAndSettle();
}
