import 'dart:io';

import 'package:collection/collection.dart';

void main() {
  final input = File("input");
  final priorities = input
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
      .map((e) => e.single.codeUnitAt(0))
      .map((e) {
        if ("a".codeUnitAt(0) <= e && e <= "z".codeUnitAt(0)) {
          return e - "a".codeUnitAt(0) + 1;
        } else {
          return 27 + e - "A".codeUnitAt(0);
        }
      })
      .sum;
  print(priorities);
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