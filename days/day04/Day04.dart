import 'dart:io';

import '../../utils/IntRange.dart';
import '../../utils/Pair.dart';
import '../BaseDay.dart';

class Day04 extends BaseDay {
  @override
  int number = 4;
  @override
  String name = "Camp Cleanup";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    final fullyContainedSum = readGroupAssignments()
        .where((groupRanges) =>
          groupRanges.first.isFullyContains(groupRanges.second) ||
              groupRanges.second.isFullyContains(groupRanges.first)
        )
        .length;
    return fullyContainedSum.toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    final fullyContainedSum = readGroupAssignments()
        .where((groupRanges) => IntRange.isOverlap(groupRanges.first, groupRanges.second))
        .length;
    return fullyContainedSum.toString();
  }

  Iterable<Pair<IntRange, IntRange>> readGroupAssignments() {
    return _input
        .readAsLinesSync()
        .map((groupAssignments) {
          final ranges = groupAssignments.split(",").map((assignment) => assignment.trim());
          return Pair(ranges.first, ranges.last);
        })
        .map((groupAssignments) => Pair(
        _createRangeFromStringPeriod(groupAssignments.first),
        _createRangeFromStringPeriod(groupAssignments.second)));
  }

  IntRange _createRangeFromStringPeriod(String period) {
    final values = period.split("-");
    return IntRange(int.parse(values.first), int.parse(values.last));
  }
}