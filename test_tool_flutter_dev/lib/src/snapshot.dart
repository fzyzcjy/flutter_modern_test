import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_tool_flutter/test_tool_flutter.dart';

Future<List<int>> takeSnapshot() async {
  final element = _findElement();
  final image = await _captureImageFromElement(element);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

/// NOTE ref [flutter_test :: _matchers_io.dart :: MatchesGoldenFile :: matchAsync]
Element _findElement() {
  final finder = find.byType(TestToolImageCaptureWrapper);
  return finder.evaluate().single;
}

/// NOTE ref [flutter_test :: _matchers_io.dart :: captureImage]
Future<ui.Image> _captureImageFromElement(Element element) async {
  assert(element.renderObject != null);
  var renderObject = element.renderObject!;
  while (!renderObject.isRepaintBoundary) {
    renderObject = renderObject.parent! as RenderObject;
  }
  assert(!renderObject.debugNeedsPaint);
  final layer = renderObject.debugLayer! as OffsetLayer;
  return layer.toImage(renderObject.paintBounds);
}
