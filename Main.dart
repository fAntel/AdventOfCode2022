import 'dart:io';

import 'package:collection/collection.dart';

const ROUNDS_COUNT = 20;

void main() {
  final input = File("input");
  final List<Monkey> monkeys = input.readAsLinesSync()
      .splitAfter((element) => element.isEmpty)
      .where((list) => list.isNotEmpty)
      .map((e) => Monkey.fromInput(e))
      .toList();

  MonkeyInspectionResult inspectionResult;
  for (int i = 0; i < ROUNDS_COUNT; ++i) {
    for (final Monkey monkey in monkeys) {
      while (monkey.hasItemsToInspect) {
        inspectionResult = monkey.inspectNextItem();
        monkeys[inspectionResult.otherMonkeyIndex]
            .catchItem(inspectionResult.itemToThrow);
      }
    }
  }

  final int monkeyBusiness = monkeys
      .sorted((a, b) => a.itemsInspected.compareTo(b.itemsInspected))
      .skip(monkeys.length - 2)
      .map((monkey) => monkey.itemsInspected)
      .fold(1, (int acc, int itemsInspected) => acc * itemsInspected);
  print(monkeyBusiness);
}

class Item {
  int worryLevel;

  Item(this.worryLevel);

  void applyInspection(int worryRaiseFun(int worryLevel)) {
    worryLevel = worryRaiseFun(worryLevel) ~/ 3;
  }

  @override
  String toString() => 'Item{worryLevel: $worryLevel}';
}

class Monkey {
  static const ITEMS_LIST_LINE = "Starting items:";
  static const OPERATION_LINE = "Operation:";
  static const TEST_LINE = "Test:";
  static const TRUE_TEST_RESULT_LINE = "If true:";
  static const FALSE_TEST_RESULT_LINE = "If false:";

  final List<Item> _items;
  Operation _worryLevelChangeOperation;
  int _divisibleBy;
  int _trueMonkeyIndex;
  int _falseMonkeyIndex;
  int _itemsInspected = 0;

  bool get hasItemsToInspect => _items.isNotEmpty;
  int get itemsInspected => _itemsInspected;

  Monkey(this._items, this._worryLevelChangeOperation, this._divisibleBy,
      this._trueMonkeyIndex, this._falseMonkeyIndex);

  MonkeyInspectionResult inspectNextItem() {
    final item = _items.removeAt(0);
    item.applyInspection(_worryLevelChangeOperation.apply);
    int otherMonkeyIndex = item.worryLevel % _divisibleBy == 0
        ? _trueMonkeyIndex
        : _falseMonkeyIndex;
    _itemsInspected += 1;
    return MonkeyInspectionResult(otherMonkeyIndex, item);
  }
  
  void catchItem(Item item) {
    _items.add(item);
  }


  @override
  String toString() {
    return 'Monkey{_items: ${_items.join(", ")}, _worryLevelChangeOperation: $_worryLevelChangeOperation, _divisibleBy: $_divisibleBy, _trueMonkeyIndex: $_trueMonkeyIndex, _falseMonkeyIndex: $_falseMonkeyIndex}';
  }

  factory Monkey.fromInput(List<String> inputLines) {
    List<Item> items = [];
    Operation? worryLevelChangeOperation = null;
    int? divisibleBy = null;
    int? trueMonkeyIndex = null;
    int? falseMonkeyIndex = null;

    String inputLine;
    for (int i = 0; i < inputLines.length; ++i) {
      inputLine = inputLines[i].trim();
      if (inputLine.startsWith(ITEMS_LIST_LINE)) {
        inputLine
            .substring(ITEMS_LIST_LINE.length)
            .split(",")
            .forEach((element) => items.add(Item(int.parse(element.trim()))));
      } else if (inputLine.startsWith(OPERATION_LINE)) {
        worryLevelChangeOperation = Operation.fromInputLine(inputLine);
      } else if (inputLine.startsWith(TEST_LINE)) {
        divisibleBy = int.parse(inputLine.split(" ").last);
      } else if (inputLine.startsWith(TRUE_TEST_RESULT_LINE)) {
        trueMonkeyIndex = int.parse(inputLine.split(" ").last);
      } else if (inputLine.startsWith(FALSE_TEST_RESULT_LINE)) {
        falseMonkeyIndex = int.parse(inputLine.split(" ").last);
      }
    }

    if (items.isNotEmpty &&
        worryLevelChangeOperation != null &&
        divisibleBy != null &&
        trueMonkeyIndex != null &&
        falseMonkeyIndex != null) {
      return Monkey(items, worryLevelChangeOperation, divisibleBy,
          trueMonkeyIndex, falseMonkeyIndex);
    } else {
      throw ArgumentError("Not enough data for monkey:\n${inputLines.join("\n")}");
    }
  }
}

abstract class Operation {
  static const ADD_INPUT_CHARACTER = "+";
  static const MULTIPLY_AND_DOUBLE_INPUT_CHARACTER = "*";
  static const DOUBLE_VALUE = "old";

  Operation();

  int apply(int oldValue);

  factory Operation.fromInputLine(String inputLine) {
    final operationData = inputLine.split(" ");
    if (operationData.length < 2)
      throw ArgumentError("Cannot parse input, not enough data: $inputLine");

    if (operationData[operationData.length - 2] == ADD_INPUT_CHARACTER) {
      return Add(int.parse(operationData.last));
    } else if (operationData[operationData.length - 2] == MULTIPLY_AND_DOUBLE_INPUT_CHARACTER) {
      if (operationData.last.trim() == DOUBLE_VALUE) {
        return Double();
      } else {
        return Multiply(int.parse(operationData.last));
      }
    } else {
      throw ArgumentError("Unknown operation: $inputLine");
    }
  }
}

class Add extends Operation {
  final int _addValue;

  Add(this._addValue);

  @override
  int apply(int oldValue) => oldValue + _addValue;

  @override
  String toString() => 'Add{_addValue: $_addValue}';
}

class Multiply extends Operation {
  final int _multiplyValue;

  Multiply(this._multiplyValue);

  @override
  int apply(int oldValue) => oldValue * _multiplyValue;

  @override
  String toString() => 'Multiply{_multiplyValue: $_multiplyValue}';
}

class Double extends Operation {
  Double();

  @override
  int apply(int oldValue) => oldValue * oldValue;

  @override
  String toString() => 'Double{}';
}

class MonkeyInspectionResult {
  final int otherMonkeyIndex;
  final Item itemToThrow;

  MonkeyInspectionResult(this.otherMonkeyIndex, this.itemToThrow);

  @override
  String toString() {
    return 'MonkeyInspectionResult{otherMonkeyIndex: $otherMonkeyIndex, itemToThrow: $itemToThrow}';
  }
}