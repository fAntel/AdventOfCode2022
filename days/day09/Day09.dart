import 'dart:io';
import 'dart:math';

import '../BaseDay.dart';

class Day09 extends BaseDay {
  @override
  int number = 9;
  @override
  String name = "Rope Bridge";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) =>
      _simulateRopeMovement(ropeLength: 2);

  @override
  String partTwo({bool withDebugPrint = false}) =>
      _simulateRopeMovement(ropeLength: 10);

  String _simulateRopeMovement({required int ropeLength}) {
    final motions = _input.readAsLinesSync().map((e) => _Motion.fromInputLine(e));
    final knots = List<Point<int>>.generate(ropeLength, (index) => Point<int>(0, 0));
    final tailPositions = {knots.last};

    for (final motion in motions) {
      for (int i = 0; i < motion.count; ++i) {
        switch (motion.direction) {
          case _Direction.left:
            knots[0] = Point(knots.first.x - 1, knots.first.y);
            break;
          case _Direction.up:
            knots[0] = Point(knots.first.x, knots.first.y - 1);
            break;
          case _Direction.right:
            knots[0] = Point(knots.first.x + 1, knots.first.y);
            break;
          case _Direction.down:
            knots[0] = Point(knots.first.x, knots.first.y + 1);
            break;
        }

        knots.pullWholeTail();

        tailPositions.add(knots.last);
      }
    }

    return tailPositions.length.toString();
  }
}

class _Motion {
  final _Direction direction;
  final int count;

  _Motion(this.direction, this.count) : assert(count >= 0);

  _Motion.fromInputLine(String input) :
        direction = _Direction.fromInput(input),
        count = int.parse(input.substring(2));
}

enum _Direction {
  left, up, right, down;

  factory _Direction.fromInput(String input) {
    var directionPart = input.substring(0, 1);
    switch (directionPart) {
      case "L": return _Direction.left;
      case "U": return _Direction.up;
      case "R": return _Direction.right;
      case "D": return _Direction.down;
      default: throw ArgumentError("Unknown direction: $directionPart. Full input: $input");
    }
  }
}

extension PointExtenstions on Point<int> {
  bool isTouching(Point<int> other) {
    return (x - other.x).abs() <= 1 && (y - other.y).abs() <= 1;
  }

  Point<int> pull(Point<int> other) {
    return Point(
        other.x + (x - other.x).sign,
        other.y + (y - other.y).sign);
  }
}

extension KnotsExtentions on List<Point<int>> {
  void pullWholeTail() {
    for (int i = 1; i < length; ++i) {
      if (!this[i].isTouching(this[i - 1])) {
        this[i] = this[i - 1].pull(this[i]);
      }
    }
  }
}