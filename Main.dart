import 'dart:io';

import 'package:collection/collection.dart';

const CHAMBER_WIDTH = 7;

void main() {
  final input = File("input");
  final gasJetsPattern = input.readAsStringSync();

  final game = Game(gasJetsPattern, 2022);
  game.run();
  print(game.map.toString());
  print(game.map.map.length);
}

class Game {
  final _map = Map();
  final _maxFiguresToAppear;
  Figure _currentFigure = Figure.horizontalLine;
  int _figuresAppeared = 0;
  final String _gasJetsPattern;
  int _currentGasJetIndex = 0;

  Game(this._gasJetsPattern, this._maxFiguresToAppear);
  
  Map get map => _map;

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

    while (_map.map[0].none((cell) => cell != Cell.empty)) {
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
          ? _map.map[y].lastIndexWhere((cell) => cell == Cell.fallingRock)
          : _map.map[y].indexWhere((cell) => cell == Cell.fallingRock);

      final possiblePositionAfterMove = fallingIndex + gasJetDirection;
      if (possiblePositionAfterMove < 0 ||
          possiblePositionAfterMove >= CHAMBER_WIDTH ||
          _map.map[y][possiblePositionAfterMove] != Cell.empty) {
        canBeMoved = false;
        break;
      }
    }

    if (canBeMoved) {
      for (int i = 0, y = fallingFigureTopLine; i < _currentFigure.height; ++i, ++y) {
        for (int j = 0, x = gasJetDirection > 0 ? CHAMBER_WIDTH - 2 : 1;
            j < _map.map[y].length - 1;
            ++j, x -= gasJetDirection) {
          if (_map.map[y][x] == Cell.fallingRock) {
            _map.map[y][x] = Cell.empty;
            _map.map[y][x + gasJetDirection] = Cell.fallingRock;
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
        if (_map.map[y][j] == Cell.fallingRock) {
          if (_map.map[y + 1][j] == Cell.stoppedRock) {
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
          if (_map.map[y - 1][j] == Cell.fallingRock) {
            _map.map[y - 1][j] = Cell.empty;
            _map.map[y][j] = Cell.fallingRock;
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
        if (_map.map[y][j] == Cell.fallingRock) {
          _map.map[y][j] = Cell.stoppedRock;
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

class Map {
  static const _DEFAULT_GAP = 3;

  final List<List<Cell>> _data = List.empty(growable: true);

  List<List<Cell>> get map => _data;

  void appear(Figure figure) {
    for (int i = 0; i < _DEFAULT_GAP; ++i) {
      _data.insert(0, List.filled(CHAMBER_WIDTH, Cell.empty));
    }

    figure.toAppearPart().reversed.forEach((row) { _data.insert(0, row); });
  }

  @override
  String toString() =>
      _data
          .map((row) => row.map((cell) => cell.toVisualization()))
          .map((row) => "|${row.join()}|")
          .join("\n") + "\n+${List.filled(CHAMBER_WIDTH, "-").join()}+";
}

enum Cell {
  empty, stoppedRock, fallingRock;

  String toVisualization() {
    switch (this) {
      case Cell.empty: return ".";
      case Cell.stoppedRock: return "#";
      case Cell.fallingRock: return "@";
    }
  }
}

enum Figure {
  horizontalLine, cross, reverseLShape, verticalLine, qube;

  static const _START_OFFSET = 2;

  int get height {
    switch (this) {
      case Figure.horizontalLine: return 1;
      case Figure.cross: return 3;
      case Figure.reverseLShape: return 3;
      case Figure.verticalLine: return 4;
      case Figure.qube: return 2;
    }
  }

  Figure next() {
    switch (this) {
      case Figure.horizontalLine: return Figure.cross;
      case Figure.cross: return Figure.reverseLShape;
      case Figure.reverseLShape: return Figure.verticalLine;
      case Figure.verticalLine: return Figure.qube;
      case Figure.qube: return Figure.horizontalLine;
    }
  }

  List<List<Cell>> toAppearPart() {
    final result =
        List.generate(height, (i) => List.filled(CHAMBER_WIDTH, Cell.empty));
    switch (this) {
      case Figure.horizontalLine:
        for (int i = 0; i < 4; ++i) {
          result[0][_START_OFFSET + i] = Cell.fallingRock;
        }
        break;
      case Figure.cross:
        result[0][_START_OFFSET + 1] = Cell.fallingRock;
        for (int i = 0; i < 3; ++i) {
          result[1][_START_OFFSET + i] = Cell.fallingRock;
        }
        result[2][_START_OFFSET + 1] = Cell.fallingRock;
        break;
      case Figure.reverseLShape:
        for (int i = 0; i < 2; ++i) {
          result[i][_START_OFFSET + 2] = Cell.fallingRock;
        }
        for (int i = 0; i < 3; ++i) {
          result[2][_START_OFFSET + i] = Cell.fallingRock;
        }
        break;
      case Figure.verticalLine:
        for (int i = 0; i < result.length; ++i) {
          result[i][_START_OFFSET] = Cell.fallingRock;
        }
        break;
      case Figure.qube:
        for (int i = 0; i < result.length; ++i) {
          for (int j = 0; j < result.length; ++j) {
            result[i][_START_OFFSET + j] = Cell.fallingRock;
          }
        }
        break;
    }
    return result;
  }

  String toVisualization() {
    List<List<Cell>> appearPart = toAppearPart();
    return appearPart
        .map((row) => row.map((cell) => cell.toVisualization()).join())
        .join("\n");
  }
}