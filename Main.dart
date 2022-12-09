import 'dart:io';
import 'dart:math';

void main() {
  final input = File("input");
  final motions = input.readAsLinesSync().map((e) => Motion.fromInputLine(e));

  var headPosition = Point(0, 0);
  var tailPosition = Point(0, 0);
  final tailPositions = {tailPosition};

  for (final motion in motions) {
    for (int i = 0; i < motion.count; ++i) {
      switch (motion.direction) {
        case Direction.left:
          headPosition = Point(headPosition.x - 1, headPosition.y);
          break;
        case Direction.up:
          headPosition = Point(headPosition.x, headPosition.y - 1);
          break;
        case Direction.right:
          headPosition = Point(headPosition.x + 1, headPosition.y);
          break;
        case Direction.down:
          headPosition = Point(headPosition.x, headPosition.y + 1);
          break;
      }

      if (!tailPosition.isTouching(headPosition)) {
        tailPosition = Point(
            tailPosition.x + (headPosition.x - tailPosition.x).sign,
            tailPosition.y + (headPosition.y - tailPosition.y).sign);
      }

      tailPositions.add(tailPosition);
    }
  }

  print(tailPositions.length);
}

extension PointExtenstions on Point {
  bool isTouching(Point other) {
    return (x - other.x).abs() <= 1 && (y - other.y).abs() <= 1;
  }
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