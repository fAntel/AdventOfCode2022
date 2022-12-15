import 'dart:io';
import 'dart:math';

void main() {
  final input = File("input");
  final game = Game();
  input.readAsLinesSync().forEach((line) { game.buildMap(line); });

  print(game.toMapVisualization());
  game.runSimulation();

  print(game.unitsOfSendCount);
}

enum Cell {
  air, rock, send, source;

  bool get isBlocking => this != Cell.air && this != Cell.source;

  String toMapVisualization() {
    switch (this) {
      case Cell.air: return ".";
      case Cell.rock: return "#";
      case Cell.send: return "o";
      case Cell.source: return "+";
    }
  }
}

class Game {
  var _startOffset = 500;
  var _sourceOffset = 0;
  final _map = [<Cell>[Cell.source]];
  var _unitsOfSendCount = 0;

  get unitsOfSendCount => _unitsOfSendCount;

  void buildMap(String inputLine) {
    inputLine
        .split("->")
        .map((scan) => scan.trim())
        .map((scan) => scan.split(","))
        .map((coords) => Point(int.parse(coords.first), int.parse(coords.last)))
        .reduce((prevScan, scan) {
          _adjustMapBounds(prevScan);
          _adjustMapBounds(scan);

          if (prevScan != scan) {
            if (prevScan.x == scan.x) {
              var from = min(prevScan.y, scan.y);
              final to = max(prevScan.y, scan.y);
              final x = scan.x - _startOffset;
              while (from <= to) {
                _map[from][x] = Cell.rock;
                ++from;
              }
            } else { // prevScan.y == scan.y
              var from = min(prevScan.x, scan.x) - _startOffset;
              final to = max(prevScan.x, scan.x) - _startOffset;
              while (from <= to) {
                _map[scan.y][from] = Cell.rock;
                ++from;
              }
            }
          }

          return scan;        
        });
  }

  void _adjustMapBounds(Point<int> scan) {
    while (scan.x - _startOffset < 0) {
      for (final List<Cell> row in _map) {
        row.insert(0, Cell.air);
      }
      --_startOffset;
      ++_sourceOffset;
    }

    while (scan.x - (_startOffset + _map.first.length - 1) > 0) {
      for (final List<Cell> row in _map) {
        row.add(Cell.air);
      }
    }

    while (_map.length <= scan.y) {
      _map.add(List.filled(_map.first.length, Cell.air, growable: true));
    }
  }

  void runSimulation() {
    _unitsOfSendCount = 0;

    int x, y;
    while (true) {
      x = _sourceOffset;
      y = 1;

      comesToRest:
      while (!_isAbyssReached(y, x)) {
        if (_map[y][x].isBlocking) {
          if (_isAbyssReached(y, x - 1) || !_map[y][x - 1].isBlocking) {
            x -= 1;
          } else if (_isAbyssReached(y, x + 1) || !_map[y][x + 1].isBlocking) {
            x += 1;
          } else {
            break comesToRest;
          }
        }
        ++y;
      }

      if (_isAbyssReached(y, x)) {
        break;
      } else {
        _map[y - 1][x] = Cell.send;
      }

      ++_unitsOfSendCount;
    }
  }

  bool _isAbyssReached(int y, int x) =>
      y >= _map.length || x < 0 || x >= _map.first.length;

  String toMapVisualization() {
    return _map
        .map((row) => row.map((cell) => cell.toMapVisualization()))
        .map((row) => row.join())
        .join("\n");
  }
}