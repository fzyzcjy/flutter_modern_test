import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:test_tool_flutter/src/gesture_visualizer.dart';

var enableTestToolVisualization = false;

class TestToolWrapperWidget extends StatelessWidget {
  final Widget child;

  const TestToolWrapperWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enableTestToolVisualization) return child;

    return TestToolImageCaptureWrapper(
      child: GestureVisualizer(child: child),
    );
  }
}

/// ref: Flutter的"golden test"(截图测试)的相关实现
class TestToolImageCaptureWrapper extends StatelessWidget {
  final Widget child;

  const TestToolImageCaptureWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // take snapshot需要[RepaintBoundary]
    return RepaintBoundary(
      child: child,
    );
  }
}

/// 类似cypress常用的方式 - 在html中增加"<mytag data-test="hello"/>"，在测试时通过cy.get('[data-test=hello]')来找到这个widget
/// 为什么作为单独的widget：因为html中的padding/margin/...在Flutter中都成为了单独的widget，所以这回html中的data-test属性也被我们拆成了widget
/// 注：所述cypress的用法，可以参见cypress入门文档，或参见cypress-realworld-app的cy.getGySel自定义命令
class Mark extends StatelessWidget {
  final Object name;
  final Object? data;
  final Widget child;

  const Mark({Key? key, required this.name, this.data, required this.child}) : super(key: key);

  T childTyped<T>() => child as T;

  @override
  Widget build(BuildContext context) {
    if (!enableTestToolVisualization) return child;

    final color = kColorList['$name'.hashCode % kColorList.length];

    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 1.0),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: IgnorePointer(
            child: Text(
              _nameBrief,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String get _nameBrief {
    final nameFull = '$name'.replaceAll('Mark.', '.');
    final nameChunks = nameFull.split('.');
    return nameChunks.map(_onlyUpperOrFirstLetter).join('.');
  }

  String _onlyUpperOrFirstLetter(String s) {
    return s.split('').whereIndexed((i, ch) => i == 0 || ch.toUpperCase() == ch).join('');
  }
}

const kColorList = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  // Colors.indigo,
  // Colors.blue,
  // Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  // Colors.brown,
  // Colors.grey,
  // Colors.blueGrey,
  // Colors.black,
];
