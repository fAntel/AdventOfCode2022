import 'dart:io';

import 'package:collection/collection.dart';

void main() {
  final input = File("input");
  final maxCalories = input.readAsLinesSync()
      .fold([<int>[]], splitBags)
      .map((e) => e.reduce((value, element) => value + element))
      .sorted((a, b) => a.compareTo(b) * -1)
      .take(3)
      .sum;
  print(maxCalories);
}

List<List<int>> splitBags(List<List<int>> acc, String value) {
  if (value.isEmpty) {
    acc.add([]);
  } else {
    acc.last.add(int.parse(value));
  }
  return acc;
}