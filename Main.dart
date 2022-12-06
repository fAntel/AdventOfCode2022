import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';

void main() {
  final input = File("input");
  var inputLines = input.readAsLinesSync();

  final stacksOfCratesInput = <String>[];
  final i = retrieveStacksOfCratesInput(inputLines, stacksOfCratesInput);
  final stackOfCrates = StacksOfCrates.fromInputLines(stacksOfCratesInput);

  final operations = retrieveOperations(inputLines, i);
  operations.run(stackOfCrates);

  final topCrates = stackOfCrates.getTopCrates();
  print(topCrates.join());
}

int retrieveStacksOfCratesInput(final List<String> inputLines,
    final List<String> stacksOfCratesInput) {
  var i = 0;
  while (i < inputLines.length) {
    if (inputLines[i].isNotEmpty) {
      stacksOfCratesInput.add(inputLines[i]);
      ++i;
    } else {
      ++i;
      break;
    }
  }
  return i;
}

Operations retrieveOperations(final List<String> inputLines, final int from) {
  final Operations result = Operations.empty();
  var i = from;
  while (i < inputLines.length) {
    result.addOperationFromInputLine(inputLines[i]);
    ++i;
  }
  return result;
}

class _Stack<T> {
  final List<T> _stack = List.empty(growable: true);
  bool get isEmpty => _stack.isEmpty;

  void push(T element) {
    _stack.add(element);
  }

  T pop() {
    if (_stack.isEmpty) {
      throw StateError("Nothing to pop. Stack is empty.");
    } else {
      return _stack.removeLast();
    }
  }
  
  T peek() {
    if (_stack.isEmpty) {
      throw StateError("Nothing to pop. Stack is empty.");
    } else {
      return _stack.last;
    }
  }
}

class StacksOfCrates {
  final List<_Stack<String>> _stacks;

  StacksOfCrates.fromInputLines(List<String> inputLines) :
      _stacks = _inputLinesToStacks(inputLines);

  static List<_Stack<String>> _inputLinesToStacks(List<String> inputLines) {
    final stacksCount =
        inputLines.removeLast().replaceAll(RegExp(r"\s+"), "").length;
    final List<_Stack<String>> result =
        List.generate(stacksCount, (index) => _Stack());

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

    var i = 0;
    while (i < count && !_stacks[from].isEmpty) {
      _stacks[to].push(_stacks[from].pop());
      ++i;
    }
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

  void run(StacksOfCrates stacksOfCrates) {
    stacksOfCrates.moveCrates(
        _fromStackIndex, _toStackIndex, _cratesToMoveCount);
  }

  @override
  String toString() {
    return '_Operation{_fromStackIndex: $_fromStackIndex, _toStackIndex: $_toStackIndex, _cratesToMoveCount: $_cratesToMoveCount}';
  }
}

class Operations {
  final List<_Operation> _operations;
  
  Operations(this._operations);

  Operations.empty() :
        _operations = List<_Operation>.empty(growable: true);
  
  factory Operations.fromInputLines(List<String> operationsInput) {
    return Operations(List.from(operationsInput
        .map((inputLine) => _Operation.fromInputLine(inputLine))));
  }
  
  void addOperationFromInputLine(String inputLine) {
    _operations.add(_Operation.fromInputLine(inputLine));
  }

  void run(StacksOfCrates stacksOfCrates) {
    for (final operation in _operations) {
      operation.run(stacksOfCrates);
    }
  }

  @override
  String toString() {
    return 'Operations{_operations: $_operations}';
  }
}