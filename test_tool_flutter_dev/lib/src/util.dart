// ignore_for_file: implementation_imports

import 'package:flutter/material.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:test_api/src/backend/state.dart';
import 'package:test_tool_proto/test_tool_proto.dart';

class DelegatingFinder implements Finder {
  final Finder target;
  final String? overrideDescription;

  DelegatingFinder(this.target, {this.overrideDescription});

  @override
  String get description => overrideDescription ?? target.description;

  @override
  Iterable<Element> apply(Iterable<Element> candidates) => target.apply(candidates);

  @override
  bool get skipOffstage => target.skipOffstage;

  @override
  Iterable<Element> get allCandidates => target.allCandidates;

  @override
  Iterable<Element> evaluate() => target.evaluate();

  @override
  bool precache() => target.precache();

  @override
  Finder get first => target.first;

  @override
  Finder get last => target.last;

  @override
  Finder at(int index) => target.at(index);

  @override
  Finder hitTestable({Alignment at = Alignment.center}) => target.hitTestable(at: at);

  @override
  String toString() => target.toString();
}

class TestToolIdGen {
  static var _nextId = 10000;

  static int nextId() => _nextId++;
}

extension ExtState on State {
  TestEntryState toProto() {
    return TestEntryState(
      status: status.name,
      result: result.name,
      // status: status.toProto(),
      // result: result.toProto(),
    );
  }
}

// extension ExtStatus on Status {
//   StateStatus toProto() {
//     switch (this) {
//       case Status.pending:
//         return StateStatus.PENDING;
//       case Status.running:
//         return StateStatus.RUNNING;
//       case Status.complete:
//         return StateStatus.COMPLETE;
//       default:
//         throw ArgumentError('Invalid result name "$name".');
//     }
//   }
// }
//
// extension ExtResult on Result {
//   StateResult toProto() {
//     switch (this) {
//       case Result.success:
//         return StateResult.SUCCESS;
//       case Result.skipped:
//         return StateResult.SKIPPED;
//       case Result.failure:
//         return StateResult.FAILURE;
//       case Result.error:
//         return StateResult.ERROR;
//       default:
//         throw ArgumentError('Invalid result name "$name".');
//     }
//   }
// }
