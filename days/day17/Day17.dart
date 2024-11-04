import 'dart:io';

import 'package:collection/collection.dart';

import '../BaseDay.dart';

const _CHAMBER_WIDTH = 7;

class Day17 extends BaseDay {
  @override
  int number = 17;
  @override
  String name = "Pyroclastic Flow";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    final gasJetsPattern = _input.readAsStringSync();

    final game = _Game(gasJetsPattern, 2022);
    game.run();

    if (withDebugPrint) {
      print(game.map.toString());
    }
    return game.map.map.length.toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    // TODO: implement partTwo
    throw UnimplementedError();
  }
}

class _Game {
  final _map = _Map();
  final _maxFiguresToAppear;
  _Figure _currentFigure = _Figure.horizontalLine;
  int _figuresAppeared = 0;
  final String _gasJetsPattern;
  int _currentGasJetIndex = 0;

  _Game(this._gasJetsPattern, this._maxFiguresToAppear);

  _Map get map => _map;

  void run() {
    _figuresAppeared = 0;
    while (_figuresAppeared < _maxFiguresToAppear) {
      _map.appear(_currentFigure);
      _emulateFigureFalling();
      _currentFigure = _currentFigure.next();
      ++_figuresAppeared;
    }
  }

  void _emulateFigureFalling() {
    int fallingFigureTopLine = 0;
    int prevFallingFigureTopLine = -1;
    while (fallingFigureTopLine != prevFallingFigureTopLine) {
      prevFallingFigureTopLine = fallingFigureTopLine;
      _moveFallingFigureIfPossible(fallingFigureTopLine);
      fallingFigureTopLine = _fall(fallingFigureTopLine);
    }
    _markComingToRest(fallingFigureTopLine);

    while (_map.map[0].none((cell) => cell != _Cell.empty)) {
      _map.map.removeAt(0);
    }
  }

  void _moveFallingFigureIfPossible(int fallingFigureTopLine) {
    final gasJetChar = _gasJetsPattern[_currentGasJetIndex++];
    if (_currentGasJetIndex >= _gasJetsPattern.length) {
      _currentGasJetIndex = 0;
    }
    final int gasJetDirection;
    switch (gasJetChar) {
      case ">":
        gasJetDirection = 1;
        break;
      case "<":
        gasJetDirection = -1;
        break;
      default: throw(StateError("Unknown direction $gasJetChar"));
    }
    bool canBeMoved = true;
    for (int i = 0, y = fallingFigureTopLine; i < _currentFigure.height; ++i, ++y) {
      final int fallingIndex = gasJetDirection > 0
          ? _map.map[y].lastIndexWhere((cell) => cell == _Cell.fallingRock)
          : _map.map[y].indexWhere((cell) => cell == _Cell.fallingRock);

      final possiblePositionAfterMove = fallingIndex + gasJetDirection;
      if (possiblePositionAfterMove < 0 ||
          possiblePositionAfterMove >= _CHAMBER_WIDTH ||
          _map.map[y][possiblePositionAfterMove] != _Cell.empty) {
        canBeMoved = false;
        break;
      }
    }

    if (canBeMoved) {
      for (int i = 0, y = fallingFigureTopLine; i < _currentFigure.height; ++i, ++y) {
        for (int j = 0, x = gasJetDirection > 0 ? _CHAMBER_WIDTH - 2 : 1;
        j < _map.map[y].length - 1;
        ++j, x -= gasJetDirection) {
          if (_map.map[y][x] == _Cell.fallingRock) {
            _map.map[y][x] = _Cell.empty;
            _map.map[y][x + gasJetDirection] = _Cell.fallingRock;
          }
        }
      }
    }
  }

  int _fall(int fallingFigureTopLine) {
    if (fallingFigureTopLine + _currentFigure.height >= _map.map.length)
      return fallingFigureTopLine;

    bool canBeMoved = true;
    for (int i = 0, y = fallingFigureTopLine; i < _currentFigure.height; ++i, ++y) {
      for (int j = 0; j < _map.map[y].length; ++j) {
        if (_map.map[y][j] == _Cell.fallingRock) {
          if (_map.map[y + 1][j] == _Cell.stoppedRock) {
            canBeMoved = false;
            break;
          }
        }
      }
    }

    if (canBeMoved) {
      for (int i = 0, y = fallingFigureTopLine + _currentFigure.height;
      i < _currentFigure.height;
      ++i, --y) {
        for (int j = 0; j < _map.map[y].length; ++j) {
          if (_map.map[y - 1][j] == _Cell.fallingRock) {
            _map.map[y - 1][j] = _Cell.empty;
            _map.map[y][j] = _Cell.fallingRock;
          }
        }
      }

      ++fallingFigureTopLine;
    }

    return fallingFigureTopLine;
  }

  void _markComingToRest(int fallingFigureTopLine) {
    for (int i = 0, y = fallingFigureTopLine; i < _currentFigure.height; ++i, ++y) {
      for (int j = 0; j < _map.map[y].length; ++j) {
        if (_map.map[y][j] == _Cell.fallingRock) {
          _map.map[y][j] = _Cell.stoppedRock;
        }
      }
    }
  }

  @override
  String toString() =>
      "Game{" +
          "figures appeared: $_figuresAppeared of $_maxFiguresToAppear, " +
          "current figure: $_currentFigure, " +
          "gas jets pattern: $_gasJetsPattern, " +
          "current gas jet: ${_gasJetsPattern[_currentGasJetIndex]} ($_currentGasJetIndex), " +
          "map:\n$_map,}";
}

class _Map {
  static const _DEFAULT_GAP = 3;

  final List<List<_Cell>> _data = List.empty(growable: true);

  List<List<_Cell>> get map => _data;

  void appear(_Figure figure) {
    for (int i = 0; i < _DEFAULT_GAP; ++i) {
      _data.insert(0, List.filled(_CHAMBER_WIDTH, _Cell.empty));
    }

    figure.toAppearPart().reversed.forEach((row) { _data.insert(0, row); });
  }

  @override
  String toString() =>
      _data
          .map((row) => row.map((cell) => cell.toVisualization()))
          .map((row) => "|${row.join()}|")
          .join("\n") + "\n+${List.filled(_CHAMBER_WIDTH, "-").join()}+";
}

enum _Cell {
  empty, stoppedRock, fallingRock;

  String toVisualization() {
    switch (this) {
      case _Cell.empty: return ".";
      case _Cell.stoppedRock: return "#";
      case _Cell.fallingRock: return "@";
    }
  }
}

enum _Figure {
  horizontalLine, cross, reverseLShape, verticalLine, qube;

  static const _START_OFFSET = 2;

  int get height {
    switch (this) {
      case _Figure.horizontalLine: return 1;
      case _Figure.cross: return 3;
      case _Figure.reverseLShape: return 3;
      case _Figure.verticalLine: return 4;
      case _Figure.qube: return 2;
    }
  }

  _Figure next() {
    switch (this) {
      case _Figure.horizontalLine: return _Figure.cross;
      case _Figure.cross: return _Figure.reverseLShape;
      case _Figure.reverseLShape: return _Figure.verticalLine;
      case _Figure.verticalLine: return _Figure.qube;
      case _Figure.qube: return _Figure.horizontalLine;
    }
  }

  List<List<_Cell>> toAppearPart() {
    final result =
    List.generate(height, (i) => List.filled(_CHAMBER_WIDTH, _Cell.empty));
    switch (this) {
      case _Figure.horizontalLine:
        for (int i = 0; i < 4; ++i) {
          result[0][_START_OFFSET + i] = _Cell.fallingRock;
        }
        break;
      case _Figure.cross:
        result[0][_START_OFFSET + 1] = _Cell.fallingRock;
        for (int i = 0; i < 3; ++i) {
          result[1][_START_OFFSET + i] = _Cell.fallingRock;
        }
        result[2][_START_OFFSET + 1] = _Cell.fallingRock;
        break;
      case _Figure.reverseLShape:
        for (int i = 0; i < 2; ++i) {
          result[i][_START_OFFSET + 2] = _Cell.fallingRock;
        }
        for (int i = 0; i < 3; ++i) {
          result[2][_START_OFFSET + i] = _Cell.fallingRock;
        }
        break;
      case _Figure.verticalLine:
        for (int i = 0; i < result.length; ++i) {
          result[i][_START_OFFSET] = _Cell.fallingRock;
        }
        break;
      case _Figure.qube:
        for (int i = 0; i < result.length; ++i) {
          for (int j = 0; j < result.length; ++j) {
            result[i][_START_OFFSET + j] = _Cell.fallingRock;
          }
        }
        break;
    }
    return result;
  }

  String toVisualization() {
    List<List<_Cell>> appearPart = toAppearPart();
    return appearPart
        .map((row) => row.map((cell) => cell.toVisualization()).join())
        .join("\n");
  }
}