import 'dart:io';
import 'dart:math';

import '../BaseDay.dart';

class Day14 extends BaseDay {
  @override
  int number = 14;
  @override
  String name = "Regolith Reservoir";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    final cave = _Cave();
    _input.readAsLinesSync().forEach((line) { cave.buildMap(line); });

    if (withDebugPrint) {
      print(cave.toCaveVisualization());
    }

    int unitsOfSendCount =
        _runSimulation(cave, (x, y) => cave.isAbyssReached(y, x));

    if (withDebugPrint) {
      print(cave.toCaveVisualization());
    }

    return (unitsOfSendCount - 1).toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    final cave = _Cave();
    _input.readAsLinesSync().forEach((line) { cave.buildMap(line); });
    cave.addFilledRowToTheBottom(_Cell.air);
    cave.addFilledRowToTheBottom(_Cell.rock);

    if (withDebugPrint) {
      print(cave.toCaveVisualization());
    }

    int unitsOfSendCount =
    _runSimulation(cave, (x, y) => x == cave.sourceOffset && y == 1);

    if (withDebugPrint) {
      print(cave.toCaveVisualization());
    }

    return unitsOfSendCount.toString();
  }

  int _runSimulation(_Cave cave, simulationEndCheck(x, y)) {
    int unitsOfSendCount = 0;

    int x, y;
    while (true) {
      x = cave.sourceOffset;
      y = 1;

      comesToRest:
      while (!cave.isAbyssReached(y, x)) {
        if (cave.isBlockingAt(y, x)) {
          x += cave.adjustMapWidth(x - 1 + cave.startOffset, isBottomless: false);
          x += cave.adjustMapWidth(x + 1 + cave.startOffset, isBottomless: false);

          if (!cave.isBlockingAt(y, x - 1)) {
            x -= 1;
          } else if (!cave.isBlockingAt(y, x + 1)) {
            x += 1;
          } else {
            break comesToRest;
          }
        }
        ++y;
      }

      ++unitsOfSendCount;

      if (simulationEndCheck(x, y)) {
        break;
      } else {
        cave.updateCellAt(y - 1, x, _Cell.send);
      }
    }
    return unitsOfSendCount;
  }
}

enum _Cell {
  air, rock, send, source;

  bool get isBlocking => this != _Cell.air && this != _Cell.source;

  String toCaveVisualization() {
    switch (this) {
      case _Cell.air: return ".";
      case _Cell.rock: return "#";
      case _Cell.send: return "o";
      case _Cell.source: return "+";
    }
  }
}

class _Cave {
  var _startOffset = 500;
  var _sourceOffset = 0;
  final _map = [<_Cell>[_Cell.source]];

  int get startOffset => _startOffset;
  int get sourceOffset => _sourceOffset;

  void buildMap(String inputLine) {
    inputLine
        .split("->")
        .map((scan) => scan.trim())
        .map((scan) => scan.split(","))
        .map((coords) => Point(int.parse(coords.first), int.parse(coords.last)))
        .reduce((prevScan, scan) {
      _adjustMapBounds(prevScan.x, prevScan.y);
      _adjustMapBounds(scan.x, scan.y);

      if (prevScan != scan) {
        if (prevScan.x == scan.x) {
          var from = min(prevScan.y, scan.y);
          final to = max(prevScan.y, scan.y);
          final x = scan.x - _startOffset;
          while (from <= to) {
            _map[from][x] = _Cell.rock;
            ++from;
          }
        } else { // prevScan.y == scan.y
          var from = min(prevScan.x, scan.x) - _startOffset;
          final to = max(prevScan.x, scan.x) - _startOffset;
          while (from <= to) {
            _map[scan.y][from] = _Cell.rock;
            ++from;
          }
        }
      }

      return scan;
    });
  }

  void addFilledRowToTheBottom(_Cell filler) {
    _map.add(List.filled(_map.first.length, filler, growable: true));
  }

  void _adjustMapBounds(int x, int y) {
    adjustMapWidth(x);

    while (_map.length <= y) {
      _map.add(List.filled(_map.first.length, _Cell.air, growable: true));
    }
  }

  int adjustMapWidth(int x, {bool isBottomless = true}) {
    _Cell cellToAdd(int y, bool isBottomless) =>
        y + 1 >= _map.length && !isBottomless ? _Cell.rock : _Cell.air;

    int diff = 0;

    while (x - _startOffset < 0) {
      for (int i = 0; i < _map.length; ++i) {
        _map[i].insert(0, cellToAdd(i, isBottomless));
      }
      --_startOffset;
      ++_sourceOffset;
      ++diff;
    }

    while (x - (_startOffset + _map.first.length - 1) > 0) {
      for (int i = 0; i < _map.length; ++i) {
        _map[i].add(cellToAdd(i, isBottomless));
      }
    }

    return diff;
  }

  bool isAbyssReached(int y, int x) =>
      y >= _map.length || x < 0 || x >= _map.first.length;

  bool isBlockingAt(int y, int x) => _map[y][x].isBlocking;

  void updateCellAt(int y, int x, _Cell newCell) {
    _map[y][x] = newCell;
  }

  String toCaveVisualization() => _map
      .map((row) => row.map((cell) => cell.toCaveVisualization()))
      .map((row) => row.join())
      .join("\n");
}