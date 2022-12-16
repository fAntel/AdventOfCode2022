import 'dart:io';
import 'dart:math';

void main() {
  final input = File("input");
  final game = Game();
  input.readAsLinesSync().forEach((line) { game.buildMap(line); });

  print(game.toMapVisualization());
  game.runSimulation();
  print(game.toMapVisualization());

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
  final _map = [<Cell>[Cell.source], [Cell.air], [Cell.rock]];
  var _unitsOfSendCount = 0;

  get unitsOfSendCount => _unitsOfSendCount;

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

  void _adjustMapBounds(int x, int y) {
    _adjustMapWidth(x);

    while (_map.length <= y + 2) {
      _map.insert(_map.length - 2,
          List.filled(_map.first.length, Cell.air, growable: true));
    }
  }

  int _adjustMapWidth(int x) {
    int diff = 0;

    while (x - _startOffset < 0) {
      for (int i = 0; i < _map.length; ++i) {
        _map[i].insert(
            0, i + 1 >= _map.length ? Cell.rock : Cell.air);
      }
      --_startOffset;
      ++_sourceOffset;
      ++diff;
    }

    while (x - (_startOffset + _map.first.length - 1) > 0) {
      for (int i = 0; i < _map.length; ++i) {
        _map[i].add(i + 1 >= _map.length ? Cell.rock : Cell.air);
      }
    }

    return diff;
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
          x += _adjustMapWidth(x - 1 + _startOffset);
          x += _adjustMapWidth(x + 1 + _startOffset);

          if (!_map[y][x - 1].isBlocking) {
            x -= 1;
          } else if (!_map[y][x + 1].isBlocking) {
            x += 1;
          } else {
            break comesToRest;
          }
        }
        ++y;
      }

      ++_unitsOfSendCount;

      if (x == _sourceOffset && y == 1) {
        break;
      } else {
        _map[y - 1][x] = Cell.send;
      }
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