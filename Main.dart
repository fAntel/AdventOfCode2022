import 'dart:io';
import 'dart:math';

void main() {
  final input = File("input");
  final motions = input.readAsLinesSync().map((e) => Motion.fromInputLine(e));
  final knots = List<Point<int>>.generate(10, (index) => Point<int>(0, 0));
  final tailPositions = {knots.last};

  for (final motion in motions) {
    for (int i = 0; i < motion.count; ++i) {
      switch (motion.direction) {
        case Direction.left:
          knots[0] = Point(knots.first.x - 1, knots.first.y);
          break;
        case Direction.up:
          knots[0] = Point(knots.first.x, knots.first.y - 1);
          break;
        case Direction.right:
          knots[0] = Point(knots.first.x + 1, knots.first.y);
          break;
        case Direction.down:
          knots[0] = Point(knots.first.x, knots.first.y + 1);
          break;
      }

      knots.pullWholeTail();

      tailPositions.add(knots.last);
    }
  }

  print(tailPositions.length);
}

class Motion {
  final Direction direction;
  final int count;

  Motion(this.direction, this.count) : assert(count >= 0);

  Motion.fromInputLine(String input) :
        direction = Direction.fromInput(input),
        count = int.parse(input.substring(2));
}

enum Direction {
  left, up, right, down;

  factory Direction.fromInput(String input) {
    var directionPart = input.substring(0, 1);
    switch (directionPart) {
      case "L": return Direction.left;
      case "U": return Direction.up;
      case "R": return Direction.right;
      case "D": return Direction.down;
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