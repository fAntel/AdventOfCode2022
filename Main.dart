import 'dart:io';
import 'dart:math';

void main() {
  final input = File("input");
  final maxCalories = input.readAsLinesSync()
      .fold([<int>[]], splitBags)
      .map((e) => e.reduce((value, element) => value + element))
      .reduce((value, element) => max(value, element));
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