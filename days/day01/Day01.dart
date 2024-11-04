import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';

import '../BaseDay.dart';

class Day01 extends BaseDay {
  @override
  int number = 1;
  @override
  String name = "Calorie Counting";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    final maxCalories = _maxCaloriesPerBag()
        .reduce((value, element) => max(value, element));
    return(maxCalories.toString());
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    final maxCalories = _maxCaloriesPerBag()
        .sorted((a, b) => b.compareTo(a))
        .take(3)
        .sum;
    return maxCalories.toString();
  }

  Iterable<int> _maxCaloriesPerBag() =>
      _input.readAsLinesSync()
        .fold([<int>[]], _splitBags)
        .map((e) => e.reduce((value, element) => value + element));

  List<List<int>> _splitBags(List<List<int>> acc, String value) {
    if (value.isEmpty) {
      acc.add([]);
    } else {
      acc.last.add(int.parse(value));
    }
    return acc;
  }
}