import 'dart:io';

import 'package:collection/collection.dart';

import '../BaseDay.dart';

class Day11 extends BaseDay {
  @override
  int number = 11;
  @override
  String name = "Monkey in the Middle";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) =>
    _solve(roundsCount: 20, worryReducerFactory: (_) => _PartOneWorryReducer());

  @override
  String partTwo({bool withDebugPrint = false}) =>
      _solve(
      roundsCount: 10000,
      worryReducerFactory: (monkeys) => _PartTwoWorryReducer(
          monkeys.fold(1, (int acc, monkey) => acc * monkey.divisibleBy)));

  String _solve(
      {required int roundsCount,
      required _WorryReducer worryReducerFactory(List<_Monkey> monkeys)}) {
    final List<_Monkey> monkeys = _input.readAsLinesSync()
        .splitAfter((element) => element.isEmpty)
        .where((list) => list.isNotEmpty)
        .map((e) => _Monkey.fromInput(e))
        .toList();

    final worryReducer = worryReducerFactory(monkeys);
    for (final _Monkey monkey in monkeys) {
      for (final _Item item in monkey.items) {
        item.worryReducer = worryReducer;
      }
    }

    _MonkeyInspectionResult inspectionResult;
    for (int i = 0; i < roundsCount; ++i) {
      for (final _Monkey monkey in monkeys) {
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

    return monkeyBusiness.toString();
  }
}

class _Item {
  int worryLevel;
  late _WorryReducer worryReducer;

  _Item(this.worryLevel);

  _Item.fromInput(String input) : worryLevel = int.parse(input.trim());

  void applyInspection(_Operation operation) {
    worryLevel = worryReducer.reduceWorry(operation.apply(worryLevel));
  }

  @override
  String toString() => 'Item{worryLevel: $worryLevel}';
}

class _Monkey {
  static const ITEMS_LIST_LINE = "Starting items:";
  static const OPERATION_LINE = "Operation:";
  static const TEST_LINE = "Test:";
  static const TRUE_TEST_RESULT_LINE = "If true:";
  static const FALSE_TEST_RESULT_LINE = "If false:";

  final List<_Item> _items;
  final _Operation _worryLevelChangeOperation;
  final int divisibleBy;
  final int _trueMonkeyIndex;
  final int _falseMonkeyIndex;
  int _itemsInspected = 0;

  bool get hasItemsToInspect => _items.isNotEmpty;
  int get itemsInspected => _itemsInspected;
  List<_Item> get items => List.unmodifiable(_items);

  _Monkey(this._items, this._worryLevelChangeOperation, this.divisibleBy,
      this._trueMonkeyIndex, this._falseMonkeyIndex);

  _MonkeyInspectionResult inspectNextItem() {
    final item = _items.removeAt(0);
    item.applyInspection(_worryLevelChangeOperation);
    int otherMonkeyIndex = item.worryLevel % divisibleBy == 0
        ? _trueMonkeyIndex
        : _falseMonkeyIndex;
    _itemsInspected += 1;
    return _MonkeyInspectionResult(otherMonkeyIndex, item);
  }

  void catchItem(_Item item) {
    _items.add(item);
  }


  @override
  String toString() =>
      "Monkey{"
          "items: ${_items.join(", ")}, "
          "worryLevelChangeOperation: $_worryLevelChangeOperation, "
          "divisibleBy: $divisibleBy, "
          "trueMonkeyIndex: $_trueMonkeyIndex, "
          "falseMonkeyIndex: $_falseMonkeyIndex}";

  factory _Monkey.fromInput(List<String> inputLines) {
    List<_Item> items = [];
    _Operation? worryLevelChangeOperation = null;
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
            .forEach((element) => items.add(_Item.fromInput(element)));
      } else if (inputLine.startsWith(OPERATION_LINE)) {
        worryLevelChangeOperation = _Operation.fromInputLine(inputLine);
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
      return _Monkey(items, worryLevelChangeOperation, divisibleBy,
          trueMonkeyIndex, falseMonkeyIndex);
    } else {
      throw ArgumentError("Not enough data for monkey:\n${inputLines.join("\n")}");
    }
  }
}

abstract class _Operation {
  static const ADD_INPUT_CHARACTER = "+";
  static const MULTIPLY_AND_DOUBLE_INPUT_CHARACTER = "*";
  static const DOUBLE_VALUE = "old";

  _Operation();

  int apply(int oldValue);

  factory _Operation.fromInputLine(String inputLine) {
    final operationData = inputLine.split(" ");
    if (operationData.length < 2)
      throw ArgumentError("Cannot parse input, not enough data: $inputLine");

    if (operationData[operationData.length - 2] == ADD_INPUT_CHARACTER) {
      return _Add(int.parse(operationData.last));
    } else if (operationData[operationData.length - 2] == MULTIPLY_AND_DOUBLE_INPUT_CHARACTER) {
      if (operationData.last.trim() == DOUBLE_VALUE) {
        return _Double();
      } else {
        return _Multiply(int.parse(operationData.last));
      }
    } else {
      throw ArgumentError("Unknown operation: $inputLine");
    }
  }
}

class _Add extends _Operation {
  final int _addValue;

  _Add(this._addValue);

  @override
  int apply(int oldValue) => oldValue + _addValue;

  @override
  String toString() => 'Add{_addValue: $_addValue}';
}

class _Multiply extends _Operation {
  final int _multiplyValue;

  _Multiply(this._multiplyValue);

  @override
  int apply(int oldValue) => oldValue * _multiplyValue;

  @override
  String toString() => 'Multiply{_multiplyValue: $_multiplyValue}';
}

class _Double extends _Operation {
  _Double();

  @override
  int apply(int oldValue) => oldValue * oldValue;

  @override
  String toString() => 'Double{}';
}

abstract class _WorryReducer {
  _WorryReducer();

  int reduceWorry(int worryLevel);
}

class _PartOneWorryReducer extends _WorryReducer {
  _PartOneWorryReducer();

  @override
  int reduceWorry(int worryLevel) => worryLevel ~/ 3;
}

class _PartTwoWorryReducer extends _WorryReducer {
  final int _divider;

  _PartTwoWorryReducer(this._divider);

  @override
  int reduceWorry(int worryLevel) => worryLevel % _divider;
}

class _MonkeyInspectionResult {
  final int otherMonkeyIndex;
  final _Item itemToThrow;

  _MonkeyInspectionResult(this.otherMonkeyIndex, this.itemToThrow);

  @override
  String toString() {
    return 'MonkeyInspectionResult{otherMonkeyIndex: $otherMonkeyIndex, itemToThrow: $itemToThrow}';
  }
}