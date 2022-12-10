import 'dart:io';

void main() {
  final input = File("input");
  final commands =
      input.readAsLinesSync().map((e) => Command.fromInputLine(e)).toList();
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

  print(result);
}

abstract class Command {
  final int duration;

  Command(this.duration);

  int run(int currentX);

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
  int run(int currentX) {
    return currentX;
  }
}

class AddX extends Command {
  static const NAME = "addx";

  final int value;

  AddX(this.value) : super(2);

  @override
  int run(int currentX) {
    return currentX + value;
  }
}