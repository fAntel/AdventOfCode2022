import 'dart:io';

import 'package:collection/collection.dart';

const ROUNDS_COUNT = 10000;

void main() {
  final input = File("input");
  final List<Monkey> monkeys = input.readAsLinesSync()
      .splitAfter((element) => element.isEmpty)
      .where((list) => list.isNotEmpty)
      .map((e) => Monkey.fromInput(e))
      .toList();

  final worryReducer = BigIntWorryReducer();
  for (final Monkey monkey in monkeys)   {
    for (final Item item in monkey.items) {
      item.worryReducer = worryReducer;
    }
  }

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
      .map((monkey) => monkey.itemsInspected)
      .sorted((a, b) => a.compareTo(b))
      .skip(monkeys.length - 2)
      .fold(1, (int acc, int itemsInspected) => acc * itemsInspected);
  print(monkeyBusiness);
}

class Item {
  BigInt worryLevel;
  late WorryReducer worryReducer;

  Item(this.worryLevel);

  Item.fromInput(String input) : worryLevel = BigInt.parse(input.trim());

  void applyInspection(Operation operation) {
    worryLevel = worryReducer.reduceWorry(operation.apply(worryLevel));
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
  final Operation _worryLevelChangeOperation;
  final BigInt divisibleBy;
  final int _trueMonkeyIndex;
  final int _falseMonkeyIndex;
  int _itemsInspected = 0;

  bool get hasItemsToInspect => _items.isNotEmpty;
  int get itemsInspected => _itemsInspected;
  List<Item> get items => List.unmodifiable(_items);

  Monkey(this._items, this._worryLevelChangeOperation, int divisibleBy,
      this._trueMonkeyIndex, this._falseMonkeyIndex)
      : this.divisibleBy = BigInt.from(divisibleBy);

  MonkeyInspectionResult inspectNextItem() {
    final item = _items.removeAt(0);
    item.applyInspection(_worryLevelChangeOperation);
    int otherMonkeyIndex = item.worryLevel % divisibleBy == BigInt.zero
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
    return 'Monkey{_items: ${_items.join(", ")}, _worryLevelChangeOperation: $_worryLevelChangeOperation, _divisibleBy: $divisibleBy, _trueMonkeyIndex: $_trueMonkeyIndex, _falseMonkeyIndex: $_falseMonkeyIndex}';
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
            .forEach((element) => items.add(Item.fromInput(element)));
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

  BigInt apply(BigInt oldValue);

  factory Operation.fromInputLine(String inputLine) {
    final operationData = inputLine.split(" ");
    if (operationData.length < 2)
      throw ArgumentError("Cannot parse input, not enough data: $inputLine");

    if (operationData[operationData.length - 2] == ADD_INPUT_CHARACTER) {
      return Add(BigInt.parse(operationData.last));
    } else if (operationData[operationData.length - 2] == MULTIPLY_AND_DOUBLE_INPUT_CHARACTER) {
      if (operationData.last.trim() == DOUBLE_VALUE) {
        return Double();
      } else {
        return Multiply(BigInt.parse(operationData.last));
      }
    } else {
      throw ArgumentError("Unknown operation: $inputLine");
    }
  }
}

class Add extends Operation {
  final BigInt _addValue;

  Add(this._addValue);

  @override
  BigInt apply(BigInt oldValue) => oldValue + _addValue;

  @override
  String toString() => 'Add{_addValue: $_addValue}';
}

class Multiply extends Operation {
  final BigInt _multiplyValue;

  Multiply(this._multiplyValue);

  @override
  BigInt apply(BigInt oldValue) => oldValue * _multiplyValue;

  @override
  String toString() => 'Multiply{_multiplyValue: $_multiplyValue}';
}

class Double extends Operation {
  Double();

  @override
  BigInt apply(BigInt oldValue) => oldValue * oldValue;

  @override
  String toString() => 'Double{}';
}

abstract class WorryReducer {
  WorryReducer();

  BigInt reduceWorry(BigInt worryLevel);
}

class PartOneWorryReducer extends WorryReducer {
  final BigInt _divider = BigInt.from(3);

  PartOneWorryReducer();

  @override
  BigInt reduceWorry(BigInt worryLevel) => worryLevel ~/ _divider;
}

class PartTwoWorryReducer extends WorryReducer {
  final BigInt _divider;

  PartTwoWorryReducer(this._divider);

  @override
  BigInt reduceWorry(BigInt worryLevel) => worryLevel % _divider;
}

class BigIntWorryReducer extends WorryReducer {
  @override
  BigInt reduceWorry(BigInt worryLevel) => worryLevel;
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