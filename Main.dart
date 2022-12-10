import 'dart:io';

const SCREEN_WIDTH = 40;
const SCREEN_HEIGHT = 6;

void main() {
  final input = File("input");
  final commands =
      input.readAsLinesSync().map((e) => Command.fromInputLine(e)).toList();
  final screen = List<List<String>>.generate(SCREEN_HEIGHT,
          (index) => List<String>.generate(SCREEN_WIDTH, (n) => ""));

  var cp = 0;
  var x = 1;
  for (int currentCycle = 0; currentCycle < SCREEN_HEIGHT * SCREEN_WIDTH; ++currentCycle) {
    if (x - 1 <= currentCycle % SCREEN_WIDTH && currentCycle % SCREEN_WIDTH <= x + 1) {
      screen[currentCycle ~/ SCREEN_WIDTH][currentCycle % SCREEN_WIDTH] = "#";
    } else {
      screen[currentCycle ~/ SCREEN_WIDTH][currentCycle % SCREEN_WIDTH] = ".";
    }
    x = commands[cp].run(x);
    if (commands[cp].done) {
      ++cp;
    }
  }

  for (final row in screen) {
    print(row.join());
  }
}

abstract class Command {
  final int duration;
  int _alreadyRunning = 0;

  get done => _alreadyRunning >= duration;

  Command(this.duration);

  int run(int currentX) {
    _alreadyRunning += 1;
    if (done) {
      return _produceResult(currentX);
    } else {
      return currentX;
    }
  }

  int _produceResult(int currentX);

  factory Command.fromInputLine(String inputLine) {
    final parts = inputLine.split(" ");
    switch (parts.first) {
      case Noop.NAME: return Noop();
      case AddX.NAME: return AddX(int.parse(parts[1]));
      default: throw ArgumentError("Unknown command ${parts.first}. Full input: $inputLine");
    }
  }
}

class Noop extends Command {
  static const NAME = "noop";

  Noop() : super(1);

  @override
  int _produceResult(int currentX) {
    return currentX;
  }
}

class AddX extends Command {
  static const NAME = "addx";

  final int value;

  AddX(this.value) : super(2);

  @override
  int _produceResult(int currentX) {
    return currentX + value;
  }
}