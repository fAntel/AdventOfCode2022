import 'dart:io';

void main() {
  final input = File("input");
  final maxCalories = input.readAsLinesSync()
      .map((e) => Round(e))
      .fold(0, (int acc, Round round) => acc + round.score());
  print(maxCalories);
}

enum Shape {
  rock(score: 1), paper(score: 2), scissors(score: 3);

  const Shape({
    required this.score,
  });

  final int score;

  factory Shape.otherShape(String char) {
    switch (char) {
      case 'A': return rock;
      case 'B': return paper;
      case 'C': return scissors;
      default: throw ArgumentError("unknown shape type: $char");
    }
  }
}

class Round {
  late Shape _otherShape;
  late Shape _myShape;

  Round(String roundData) {
    _otherShape = Shape.otherShape(roundData[0]);
    _myShape = _guessMyShape(roundData[2]);
  }

  int score() {
    var result = _myShape.score;
    if (_myShape == _otherShape) {
      result += 3;
    } else if (_isWin(_myShape, _otherShape)) {
      result += 6;
    }
    return result;
  }

  Shape _guessMyShape(String roundResult) {
    switch (roundResult) {
      case 'X':
        return Shape.values.firstWhere((element) {
          return element != _otherShape && !_isWin(element, _otherShape);
        });
      case 'Y':
        return Shape.values.firstWhere((element) => element == _otherShape);
      case 'Z':
        return Shape.values.firstWhere((element) {
          return element != _otherShape && _isWin(element, _otherShape);
        });
      default: throw ArgumentError("unknown round result $roundResult");
    }
  }

  bool _isWin(Shape a, Shape b) {
    switch (a) {
      case Shape.rock:
        return b == Shape.scissors;
      case Shape.paper:
        return b == Shape.rock;
      case Shape.scissors:
        return b == Shape.paper;
    }
  }
}