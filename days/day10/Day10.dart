import 'dart:io';

import '../BaseDay.dart';

const _SCREEN_WIDTH = 40;
const _SCREEN_HEIGHT = 6;

class Day10 extends BaseDay {
  @override
  int number = 10;
  @override
  String name = "Cathode-Ray Tube";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    List<_Command> commands = _getCommandsFromInput();
    final importantCycles =
        List.generate(6, (index) => index == 0 ? 20 : 20 + index * 40);

    var result = 0;
    var cp = 0;
    var x = 1;
    var currentCycle = 0;
    for (final nextCycle in importantCycles) {
      while (cp < commands.length && currentCycle + commands[cp].duration < nextCycle) {
        x = commands[cp].run(x);
        currentCycle += commands[cp].duration;
        ++cp;
      }
      result += nextCycle * x;
    }

    return result.toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    List<_Command> commands = _getCommandsFromInput();
    final screen = List<List<String>>.generate(_SCREEN_HEIGHT,
            (index) => List<String>.generate(_SCREEN_WIDTH, (n) => ""));

    var cp = 0;
    var x = 1;
    for (int currentCycle = 0; currentCycle < _SCREEN_HEIGHT * _SCREEN_WIDTH; ++currentCycle) {
      if (x - 1 <= currentCycle % _SCREEN_WIDTH && currentCycle % _SCREEN_WIDTH <= x + 1) {
        screen[currentCycle ~/ _SCREEN_WIDTH][currentCycle % _SCREEN_WIDTH] = "#";
      } else {
        screen[currentCycle ~/ _SCREEN_WIDTH][currentCycle % _SCREEN_WIDTH] = ".";
      }
      x = commands[cp].run(x);
      if (commands[cp].done) {
        ++cp;
      }
    }

    return screen.map((row) => row.join()).join("\n");
  }

  List<_Command> _getCommandsFromInput() {
    final commands =
    _input.readAsLinesSync().map((e) => _Command.fromInputLine(e)).toList();
    return commands;
  }
}

abstract class _Command {
  final int duration;
  int _alreadyRunning = 0;

  get done => _alreadyRunning >= duration;

  _Command(this.duration);

  int run(int currentX) {
    _alreadyRunning += 1;
    if (done) {
      return _produceResult(currentX);
    } else {
      return currentX;
    }
  }

  int _produceResult(int currentX);

  factory _Command.fromInputLine(String inputLine) {
    final parts = inputLine.split(" ");
    switch (parts.first) {
      case _Noop.NAME: return _Noop();
      case _AddX.NAME: return _AddX(int.parse(parts[1]));
      default: throw ArgumentError("Unknown command ${parts.first}. Full input: $inputLine");
    }
  }
}

class _Noop extends _Command {
  static const NAME = "noop";

  _Noop() : super(1);

  @override
  int _produceResult(int currentX) => currentX;
}

class _AddX extends _Command {
  static const NAME = "addx";

  final int value;

  _AddX(this.value) : super(2);

  @override
  int _produceResult(int currentX) => currentX + value;
}