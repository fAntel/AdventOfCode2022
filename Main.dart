import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';

const COORDINATE_MIN = 0;
const COORDINATE_MAX = 4000000;
const TUNING_FREQUENCY_X_MULTIPLIER = 4000000;

void main() {
  final input = File("input");
  final sensors = input.readAsLinesSync()
      .map((line) => Sensor.fromInputLine(line))
      .toList();

  for (int i = COORDINATE_MIN; i <= COORDINATE_MAX; ++i) {
    final coveragesForLine = sensors
        .map((sensor) => sensor.coverageForLine(i))
        .map((range) {
          if (range == null) {
            return null;
          } else if (range.last < COORDINATE_MIN || range.first > COORDINATE_MAX) {
            return null;
          } else if (range.first < COORDINATE_MIN && COORDINATE_MIN < range.last) {
            return IntRange(COORDINATE_MIN, min(range.last, COORDINATE_MAX));
          } else if (range.first < COORDINATE_MAX && COORDINATE_MAX < range.last) {
            return IntRange(max(range.first, COORDINATE_MIN), COORDINATE_MAX);
          } else {
            return range;
          }
        })
        .whereNotNull()
        .fold(<IntRange>[], (List<IntRange> acc, IntRange range) {
          if (acc.isEmpty) {
            acc.add(range);
          } else {
            int i = 0;
            while (i < acc.length) {
              if (IntRange.isOverlap(acc[i], range) || acc[i].last + 1 == range.first || range.last + 1 == acc[i].first) {
                range = IntRange(
                    min(acc[i].first, range.first),
                    max(acc[i].last, range.last));
                acc.removeAt(i);
                if (acc.isEmpty) {
                  acc.add(range);
                  break;
                } else {
                  if (i > 0) {
                    --i;
                  }
                  continue;
                }
              } else if (acc[i].first > range.first) {
                acc.insert(max(i, 0), range);
                break;
              } else if (i + 1 == acc.length) {
                acc.add(range);
                break;
              }
              ++i;
            }
          }
          return acc;
        });
    if (coveragesForLine.length > 1) {
      print((coveragesForLine.first.last + 1) * TUNING_FREQUENCY_X_MULTIPLIER + i); //7935413
      break;
    }
  }
}

class Beacon {
  final Point<int> position;

  Beacon(this.position);
  
  Beacon.fromCoordinates(int x, int y) : position = Point(x, y);


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Beacon &&
          runtimeType == other.runtimeType &&
          position == other.position;

  @override
  int get hashCode => position.hashCode;

  @override
  String toString() => "Beacon{position: $position}";
}

class Sensor {
  static const _SENSOR_X = "sensorX";
  static const _SENSOR_Y = "sensorY";
  static const _BEACON_X = "beaconX";
  static const _BEACON_Y = "beaconY";
  static const _INPUT_PATTERN = "Sensor at x=(?<$_SENSOR_X>-?\\d+), y=(?<$_SENSOR_Y>-?\\d+): closest beacon is at x=(?<$_BEACON_X>-?\\d+), y=(?<$_BEACON_Y>-?\\d+)";
  static final _INPUT_REGEXP = RegExp(_INPUT_PATTERN);

  final Point<int> position;
  final Beacon closestBeacon;
  final int _sensorRadius;

  Sensor(this.position, this.closestBeacon) :
        _sensorRadius = (position.x - closestBeacon.position.x).abs() +
            (position.y - closestBeacon.position.y).abs();

  factory Sensor.fromInputLine(String inputLine) {
    final match = _INPUT_REGEXP.firstMatch(inputLine);
    if (match == null)
      throw ArgumentError('Cannot parse input: "$inputLine".');
    if (!match.groupNames.contains(_SENSOR_X) ||
        !match.groupNames.contains(_SENSOR_Y) ||
        !match.groupNames.contains(_BEACON_X) ||
        !match.groupNames.contains(_BEACON_Y))
      throw ArgumentError("Some groups missed. There are only groups with names: ${match.groupNames.join(", ")}.");

    return Sensor(
      Point(int.parse(match.namedGroup(_SENSOR_X)!),
          int.parse(match.namedGroup(_SENSOR_Y)!)),
      Beacon.fromCoordinates(int.parse(match.namedGroup(_BEACON_X)!),
          int.parse(match.namedGroup(_BEACON_Y)!)),
    );
  }

  IntRange? coverageForLine(int line) {
    if (position.y + _sensorRadius < line || position.y - _sensorRadius > line)
      return null;

    final int linesFromCenter =
        line >= position.y ? line - position.y : position.y - line;
    final int lineRadius = _sensorRadius - linesFromCenter;
    return IntRange(position.x - lineRadius, position.x + lineRadius);
  }

  @override
  String toString() =>
      "Sensor{position: $position, closest beacon: $closestBeacon}";
}

class IntRange {
  final int first;
  final int last;

  IntRange(this.first, this.last) {
    assert(first <= last);
  }

  int get length => last - first + 1;

  static bool isOverlap(IntRange a, IntRange b) =>
      (a.first <= b.first && b.first <= a.last) ||
      (a.first <= b.last && b.last <= a.last) ||
      (b.first <= a.first && a.first <= b.last) ||
      (b.first <= a.first && a.first <= b.last);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is IntRange &&
              runtimeType == other.runtimeType &&
              first == other.first &&
              last == other.last;

  @override
  int get hashCode => first.hashCode ^ last.hashCode;

  @override
  String toString() => "IntRange{$first..$last}";
}