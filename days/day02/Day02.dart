import 'dart:io';

import '../BaseDay.dart';

class Day02 extends BaseDay {
  @override
  int number = 2;
  @override
  String name = "Rock Paper Scissors";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    final isWin = (_Shape a, _Shape b) => a.compareTo(b) > 0;

    final guessMyShape = (String roundResult, _Shape otherShape) =>
        _Shape.fromInt(roundResult.codeUnitAt(0) - "X".codeUnitAt(0));

    return _calculateScore(guessMyShape, isWin).toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    final isWin = (_Shape a, _Shape b) {
      switch (a) {
        case _Shape.rock:
          return b == _Shape.scissors;
        case _Shape.paper:
          return b == _Shape.rock;
        case _Shape.scissors:
          return b == _Shape.paper;
      }
    };

    final guessMyShape = (String roundResult, _Shape otherShape) {
      switch (roundResult) {
        case 'X':
          return _Shape.values.firstWhere((element) {
            return element != otherShape && !isWin(element, otherShape);
          });
        case 'Y':
          return _Shape.values.firstWhere((element) => element == otherShape);
        case 'Z':
          return _Shape.values.firstWhere((element) {
            return element != otherShape && isWin(element, otherShape);
          });
        default: throw ArgumentError("unknown round result $roundResult");
      }
    };

    return _calculateScore(guessMyShape, isWin).toString();
  }

  int _calculateScore(
      _Shape guessMyShape(String roundResult, _Shape otherShape),
      bool isWin(_Shape a, _Shape b)) {
    final score = _input.readAsLinesSync()
        .map((e) => _Round(e, guessMyShape))
        .fold(0, (int acc, _Round round) => acc + round.score(isWin));
    return score;
  }
}

enum _Shape implements Comparable<_Shape> {
  rock(score: 1), paper(score: 2), scissors(score: 3);

  const _Shape({
    required this.score,
  });

  final int score;

  @override
  int compareTo(_Shape other) {
    if (this == _Shape.rock && other == _Shape.scissors)
      return 1;

    if (this == _Shape.scissors && other == _Shape.rock)
      return -1;

    return this.score.compareTo(other.score);
  }

  factory _Shape.fromInt(int shapeType) {
    switch (shapeType) {
      case 0: return rock;
      case 1: return paper;
      case 2: return scissors;
      default: throw ArgumentError("unknown shape type: $shapeType");
    }
  }

  factory _Shape.otherShape(String char) {
    switch (char) {
      case 'A': return rock;
      case 'B': return paper;
      case 'C': return scissors;
      default: throw ArgumentError("unknown shape type: $char");
    }
  }
}

class _Round {
  late _Shape _otherShape;
  late _Shape _myShape;

  _Round(String roundData,
      _Shape guessMyShape(String roundResult, _Shape otherShape)) {
    _otherShape = _Shape.otherShape(roundData[0]);
    _myShape = guessMyShape(roundData[2], _otherShape);
  }

  int score(bool isWin(_Shape a, _Shape b)) {
    var result = _myShape.score;
    if (_myShape == _otherShape) {
      result += 3;
    } else if (isWin(_myShape, _otherShape)) {
      result += 6;
    }
    return result;
  }
}