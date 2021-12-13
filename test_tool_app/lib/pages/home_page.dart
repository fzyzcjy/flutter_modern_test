import 'dart:math';

import 'package:collection/collection.dart';
import 'package:common_flutter_web/components/static_section_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:test_api/src/backend/state.dart' hide State; // ignore: implementation_imports
import 'package:test_tool_app/misc/proto_extensions.dart';
import 'package:test_tool_app/stores/log_store.dart';
import 'package:test_tool_app/stores/organization_store.dart';
import 'package:test_tool_app/utils/utils.dart';
import 'package:test_tool_proto/test_tool_proto.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderPanel(),
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: _CommandInfoPanel(),
              ),
              Container(width: 8),
              Container(width: 1, color: Colors.grey[200]),
              Container(width: 8),
              Expanded(
                flex: 1,
                child: _ScreenshotPanel(),
              ),
              _InputKeyHandler(),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final organizationStore = GetIt.I.get<OrganizationStore>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '自动展开\n最新内容',
            style: TextStyle(fontSize: 12, height: 1.2),
          ),
          Observer(
            builder: (_) => Switch(
              value: organizationStore.enableAutoExpand,
              onChanged: (v) => organizationStore.enableAutoExpand = v,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandInfoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final organizationStore = GetIt.I.get<OrganizationStore>();

    return Observer(builder: (_) {
      final adapter = StaticSectionListViewAdapter();

      if (organizationStore.testGroupIds.isEmpty) {
        adapter.sections.add(StaticSingleSection(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Center(
              child: Text('暂无内容'),
            ),
          ),
        ));
      } else {
        adapter.sections.add(StaticSingleSection(child: Container(height: 8)));

        for (final testGroupId in organizationStore.testGroupIds) {
          final testGroup = organizationStore.testGroupMap[testGroupId]!;
          adapter.sections.add(StaticSingleSection(
            child: InkWell(
              onTap: () {
                organizationStore.enableAutoExpand = false;
                organizationStore.expandTestGroupMap[testGroupId] = !organizationStore.expandTestGroupMap[testGroupId];
              },
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_drop_down, size: 20),
                      Text(
                        testGroup.briefName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ));

          if (organizationStore.expandTestGroupMap[testGroupId]) {
            final testEntryIds = organizationStore.testEntryInGroup[testGroupId]!;
            adapter.sections.add(StaticSection(
              count: testEntryIds.length,
              builder: (context, index) {
                return _TestEntryWidget(testEntryId: testEntryIds[index]);
              },
            ));
          }
        }

        adapter.sections.add(StaticSingleSection(child: Container(height: 8)));
      }

      return ListView.builder(
        itemCount: adapter.itemCount,
        itemBuilder: adapter.itemBuilder,
      );
    });
  }
}

class _TestEntryWidget extends StatelessWidget {
  final int testEntryId;

  const _TestEntryWidget({Key? key, required this.testEntryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final organizationStore = GetIt.I.get<OrganizationStore>();
    final logStore = GetIt.I.get<LogStore>();

    return Observer(builder: (_) {
      final testEntry = organizationStore.testEntryMap[testEntryId]!;
      final logEntryIds = logStore.logEntryInTest[testEntryId] ?? [];
      final state = organizationStore.testEntryStateMap[testEntryId].toState();

      // 暂时这样……性能当然不会太好
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              organizationStore.enableAutoExpand = false;
              organizationStore.expandTestEntryMap[testEntryId] = !organizationStore.expandTestEntryMap[testEntryId];
            },
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Builder(builder: (_) {
                      const kSize = 16.0;
                      switch (state.status) {
                        case Status.pending:
                          return Center(
                            child: SizedBox(
                              width: kSize,
                              height: kSize,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        case Status.running:
                          return _RotateAnimation(
                            duration: Duration(seconds: 2),
                            child: Icon(
                              Icons.autorenew,
                              size: 20,
                              color: Colors.grey,
                            ),
                          );
                        case Status.complete:
                          switch (state.result) {
                            case Result.success:
                              return Icon(Icons.check_circle_rounded, color: Colors.green, size: kSize);
                            case Result.skipped:
                              return Icon(Icons.minimize, color: Colors.orange, size: kSize);
                            case Result.failure:
                            case Result.error:
                              return Icon(Icons.error, color: Colors.red, size: kSize);
                            default:
                              throw Exception;
                          }
                        default:
                          throw Exception;
                      }
                    }),
                    Text(
                      testEntry.briefName,
                      style: TextStyle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (organizationStore.expandTestEntryMap[testEntryId])
            Stack(
              children: [
                Column(
                  children: [
                    ...logEntryIds.mapIndexed(
                      (i, logEntryId) => _LogEntryWidget(
                        order: i,
                        logEntryId: logEntryId,
                        running: state.status == Status.running && i == logEntryIds.length - 1,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 24,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 1,
                    color: Colors.grey[300],
                  ),
                )
              ],
            )
        ],
      );
    });
  }
}

class _LogEntryWidget extends StatelessWidget {
  final int order;
  final int logEntryId;
  final bool running;

  const _LogEntryWidget({
    Key? key,
    required this.order,
    required this.logEntryId,
    required this.running,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logStore = GetIt.I.get<LogStore>();

    // const kSkipTypes = [
    //   LogEntryType.TEST_START,
    //   LogEntryType.TEST_BODY,
    //   LogEntryType.TEST_END,
    // ];

    return Observer(builder: (_) {
      final logEntry = logStore.logEntryMap[logEntryId]!;

      // if (kSkipTypes.contains(logEntry.type)) {
      //   return Container();
      // }

      final active = logStore.activeLogEntryId == logEntryId;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              logStore.activeLogEntryId = active ? null : logEntryId;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.only(left: 32),
              decoration: BoxDecoration(
                color: active ? Colors.green[50] : (running ? Colors.blue[50] : Colors.blueGrey[50]!.withAlpha(150)),
                border: running ? Border(left: BorderSide(color: Colors.blue, width: 2)) : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: running //
                          ? _RotateAnimation(
                              duration: Duration(seconds: 1),
                              child: Icon(
                                Icons.autorenew,
                                size: 16,
                                color: Colors.grey,
                              ),
                            )
                          : Text(
                              '$order',
                              style: TextStyle(color: Colors.grey),
                            ),
                    ),
                  ),
                  Container(width: 12),
                  SizedBox(
                    width: 80,
                    child: Builder(
                      builder: (_) {
                        Color? backgroundColor;
                        var textColor = Colors.black;
                        if (logEntry.type == LogEntryType.ASSERT) {
                          backgroundColor = Colors.green;
                          textColor = Colors.white;
                        }
                        if (logEntry.type == LogEntryType.ASSERT_FAIL) {
                          backgroundColor = Colors.red;
                          textColor = Colors.white;
                        }

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding:
                                backgroundColor == null ? null : const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                            ),
                            child: Text(
                              logEntry.title,
                              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(width: 12),
                  Expanded(
                    child: Text(logEntry.message),
                  ),
                ],
              ),
            ),
          ),
          if (logEntry.error.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              margin: const EdgeInsets.only(left: 32),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border(left: BorderSide(color: Colors.red[200]!, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(logEntry.error),
                  Text(logEntry.stackTrace),
                ],
              ),
            )
        ],
      );
    });
  }
}

class _RotateAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _RotateAnimation({Key? key, required this.child, required this.duration}) : super(key: key);

  @override
  __RotateAnimationState createState() => __RotateAnimationState();
}

class __RotateAnimationState extends State<_RotateAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.rotate(
        angle: _controller.value * 2 * pi,
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _ScreenshotPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logStore = GetIt.I.get<LogStore>();

    return Observer(builder: (_) {
      final activeLogEntryId = logStore.activeLogEntryId;
      if (activeLogEntryId == null) {
        return Center(
          child: Text('点击左侧查看截图'),
        );
      }

      return Row(
        children: (logStore.snapshotInLog[activeLogEntryId]?.keys ?? []).map((snapshotName) {
          final image = logStore.snapshotInLog[activeLogEntryId]![snapshotName];

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$snapshotName',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: image != null ? Image.memory(image) : Text('[图片加载失败]'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _InputKeyHandler extends StatefulWidget {
  @override
  __InputKeyHandlerState createState() => __InputKeyHandlerState();
}

class __InputKeyHandlerState extends State<_InputKeyHandler> {
  static const _kTag = 'InputKeyHandler';

  final _logStore = GetIt.I.get<LogStore>();
  final _organizationStore = GetIt.I.get<OrganizationStore>();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() => _autoRequestFocus());
    WidgetsBinding.instance!.addPostFrameCallback((_) => _autoRequestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _autoRequestFocus() {
    if (!_focusNode.hasFocus) {
      print('InputKeyHandler requestFocus');
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    print('$_kTag _handleKeyEvent $event');
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveActiveLogEntry(1);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _moveActiveLogEntry(-1);
      }
    }
  }

  void _moveActiveLogEntry(int delta) {
    if (_logStore.activeLogEntryId == null) return;

    final activeLogEntry = _logStore.logEntryMap[_logStore.activeLogEntryId!]!;
    final activeTestEntryId = _organizationStore.testEntryNameToId(activeLogEntry.testEntryName);

    final siblingLogEntryIds = _logStore.logEntryInTest[activeTestEntryId]!;
    final oldIndex = siblingLogEntryIds.indexOf(activeLogEntry.id);
    final newIndex = (oldIndex + delta).clamp(0, siblingLogEntryIds.length - 1);

    print('$_kTag _moveActiveLogEntry delta=$delta old=${_logStore.activeLogEntryId} new=${_logStore.activeLogEntryId}');
    _logStore.activeLogEntryId = siblingLogEntryIds[newIndex];
  }

  @override
  Widget build(BuildContext context) {
    // NOTE ref https://api.flutter.dev/flutter/services/LogicalKeyboardKey-class.html
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: Container(),
    );
  }
}
