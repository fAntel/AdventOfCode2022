import 'dart:io';

import 'package:collection/collection.dart';

import '../../utils/Pair.dart';
import '../BaseDay.dart';

class Day03 extends BaseDay {
  @override
  int number = 3;
  @override
  String name = "Rucksack Reorganization";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    final priorities = _input
        .readAsLinesSync()
        .map((e) => Pair(e.substring(0, e.length ~/ 2), e.substring(e.length ~/ 2)))
        .map((e) => Pair(e.first.toSet(), e.second.toSet()))
        .map((e) => e.first.intersection(e.second))
        .map((e) => e.single)
        .map(itemToPriority)
        .sum;
    return priorities.toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    final priorities = _input
        .readAsLinesSync()
        .slices(3)
        .map((groupRucksacks) => groupRucksacks.map((rucksack) => rucksack.toSet()))
        .map((groupRucksacks) {
          var result = groupRucksacks.first;
          groupRucksacks.skip(1).forEach((rucksack) {
            result = result.intersection(rucksack);
          });
          return result;
        })
        .map((e) => e.single)
        .map(itemToPriority)
        .sum;
    return priorities.toString();
  }

  int itemToPriority(String item) {
    final itemCode = item.codeUnitAt(0);
    if ("a".codeUnitAt(0) <= itemCode && itemCode <= "z".codeUnitAt(0)) {
      return itemCode - "a".codeUnitAt(0) + 1;
    } else {
      return 27 + itemCode - "A".codeUnitAt(0);
    }
  }
}

extension StringExtenstions on String {
  Set<String> toSet() {
    final result = <String>{};
    for (var i = 0; i < length; ++i) {
      result.add(this[i]);
    }
    return result;
  }
}