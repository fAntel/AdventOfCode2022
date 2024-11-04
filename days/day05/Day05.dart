import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';

import '../../utils/Pair.dart';
import '../../utils/Stack.dart';
import '../BaseDay.dart';

class Day05 extends BaseDay {
  @override
  int number = 5;
  @override
  String name = "Supply Stacks";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    final moveCratesFun = (stacks, from, to, count) {
      var i = 0;
      while (i < count && !stacks[from].isEmpty) {
        stacks[to].push(stacks[from].pop());
        ++i;
      }
    };

    return _findTopCrates(moveCratesFun);
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    final moveCratesFun = (stacks, from, to, count) {
      if (stacks[from].isEmpty)
        return;

      var i = 0;
      final poppedCrates = List.empty(growable: true);
      while (i < count && !stacks[from].isEmpty) {
        poppedCrates.add(stacks[from].pop());
        ++i;
      }

      if (poppedCrates.isNotEmpty) {
        for (final crate in poppedCrates.reversed) {
          stacks[to].push(crate);
        }
      }
    };

    return _findTopCrates(moveCratesFun);
  }

  String _findTopCrates(void moveCratesFun(dynamic stacks, dynamic from, dynamic to, dynamic count)) {
    final input = _parseInput(moveCratesFun);
    final stackOfCrates = input.first;
    final operations = input.second;

    operations.run(stackOfCrates);

    final topCrates = stackOfCrates.getTopCrates();
    return topCrates.join();
  }

  Pair<_StacksOfCrates, _Operations> _parseInput(
      void Function(List<Stack<String>> stacks, int from, int to, int count) moveCratesFun
  ) {
    var inputLines = _input.readAsLinesSync();

    final stacksOfCratesInput = inputLines.takeWhile((value) => value.isNotEmpty);
    final stackOfCrates = _StacksOfCrates.fromInputLines(stacksOfCratesInput, moveCratesFun);

    final operationsInput = inputLines.skip(stacksOfCratesInput.length + 1);
    final operations = _Operations.fromInputLines(operationsInput);

    return Pair(stackOfCrates, operations);
  }
}

class _StacksOfCrates {
  final List<Stack<String>> _stacks;
  final void Function(List<Stack<String>> stacks, int from, int to, int count) _moveCratesFun;

  _StacksOfCrates.fromInputLines(
      Iterable<String> inputLines,
      void Function(List<Stack<String>> stacks, int from, int to, int count)
          moveCratesFun)
      : _stacks = _inputLinesToStacks(inputLines.toList()),
        _moveCratesFun = moveCratesFun;

  static List<Stack<String>> _inputLinesToStacks(List<String> inputLines) {
    final stacksCount = inputLines.removeLast().replaceAll(RegExp(r"\s+"), "").length;
    final List<Stack<String>> result = List.generate(stacksCount, (index) => Stack());

    String crate;
    for (final inputLine in inputLines.reversed) {
      for (int i = 0, j = 0; i < inputLine.length; i += 4, ++j) {
        crate = inputLine.substring(i, min(i + 4, inputLine.length)).trim();
        if (crate.isNotEmpty) {
          result[j].push(crate.substring(1, 2));
        }
      }
    }

    return result;
  }

  void moveCrates(final int from, final int to, final int count) {
    assert(from >= 0 && from < _stacks.length);
    assert(to >= 0 && to < _stacks.length);

    _moveCratesFun(_stacks, from, to, count);
  }

  List<String> getTopCrates() {
    final List<String> result = List.empty(growable: true);
    for (int i = 0; i < _stacks.length; ++i) {
      if (!_stacks[i].isEmpty) {
        result.add(_stacks[i].peek());
      }
    }
    return result;
  }
}

class _Operation {
  final int _fromStackIndex;
  final int _toStackIndex;
  final int _cratesToMoveCount;

  _Operation(this._fromStackIndex, this._toStackIndex, this._cratesToMoveCount);

  factory _Operation.fromInputLine(String input) {
    final data = input
        .split(" ")
        .map((element) => int.tryParse(element))
        .whereNotNull();
    return _Operation(
        data.elementAt(1) - 1,
        data.elementAt(2) - 1,
        data.elementAt(0)
    );
  }

  void run(_StacksOfCrates stacksOfCrates) {
    stacksOfCrates.moveCrates(
        _fromStackIndex, _toStackIndex, _cratesToMoveCount);
  }

  @override
  String toString() =>
      "_Operation{" +
      "_fromStackIndex: $_fromStackIndex, " +
      "_toStackIndex: $_toStackIndex, " +
      "_cratesToMoveCount: $_cratesToMoveCount}";
}

class _Operations {
  final List<_Operation> _operations;

  _Operations(this._operations);

  factory _Operations.fromInputLines(Iterable<String> operationsInput) {
    return _Operations(List.from(operationsInput.map((inputLine) => _Operation.fromInputLine(inputLine))));
  }

  void run(_StacksOfCrates stacksOfCrates) {
    for (final operation in _operations) {
      operation.run(stacksOfCrates);
    }
  }

  @override
  String toString() => "Operations{_operations: $_operations}";
}