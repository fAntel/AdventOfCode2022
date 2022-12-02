import 'dart:io';

void main() {
  final input = File("input");
  final maxCalories = input.readAsLinesSync()
      .map((e) => Round(e))
      .fold(0, (acc, round) => acc + round.score());
  print(maxCalories);
}

abstract class Shape extends Comparable<Shape> {
  int get score;

  factory Shape.fromInt(int shapeType) {
    switch (shapeType) {
      case 0: return Rock();
      case 1: return Paper();
      case 2: return Scissors();
      default: throw ArgumentError("unknown shape type: $shapeType");
    }
  }
}

class Rock implements Shape {
  @override
  int get score => 1;

  @override
  int compareTo(Shape other) {
    if (other is Scissors) return 1;
    if (other is Paper) return -1;
    if (other is Rock) return 0;
    throw ArgumentError("Unknown class ${other.runtimeType.toString()}");
  }
}

class Paper implements Shape {
  @override
  int get score => 2;

  @override
  int compareTo(Shape other) {
    if (other is Rock) return 1;
    if (other is Scissors) return -1;
    if (other is Paper) return 0;
    throw ArgumentError("Unknown class ${other.runtimeType.toString()}");
  }
}

class Scissors implements Shape {
  @override
  int get score => 3;

  @override
  int compareTo(Shape other) {
    if (other is Paper) return 1;
    if (other is Rock) return -1;
    if (other is Scissors) return 0;
    throw ArgumentError("Unknown class ${other.runtimeType.toString()}");
  }
}

class Round {
  Shape _otherShape;
  Shape _myShape;

  Round(String roundData) {
    _otherShape = Shape.fromInt(roundData.codeUnitAt(0) - "A".codeUnitAt(0));
    _myShape = Shape.fromInt(roundData.codeUnitAt(2) - "X".codeUnitAt(0));
  }

  int score() {
    var result = _myShape.score;
    final compareResult = _myShape.compareTo(_otherShape);
    if (compareResult == 0) {
      result += 3;
    } else if (compareResult > 0) {
      result += 6;
    }
    return result;
  }
}