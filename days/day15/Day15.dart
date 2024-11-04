import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';

import '../../utils/IntRange.dart';
import '../BaseDay.dart';

const _ANSWER_ROW = 2000000;
const _COORDINATE_MIN = 0;
const _COORDINATE_MAX = 4000000;
const _TUNING_FREQUENCY_X_MULTIPLIER = 4000000;

class Day15 extends BaseDay {
  @override
  int number = 15;
  @override
  String name = "Beacon Exclusion Zone";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    final List<Sensor> sensors = _parseInput();

    final coveragesForLine = sensors
        .map((sensor) => sensor.coverageForLine(_ANSWER_ROW))
        .whereNotNull();
    final coveredCells = _findCoveredCells(coveragesForLine)
        .fold(0, (int acc, IntRange range) => acc + range.length);
    final foundBeaconsCount = sensors
        .map((sensor) => sensor.closestBeacon.position.y)
        .toSet()
        .fold(0, (int acc, beaconY) => acc + (beaconY == _ANSWER_ROW ? 1 : 0));

    return (coveredCells - foundBeaconsCount).toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    final List<Sensor> sensors = _parseInput();

    int result = 0;
    for (int i = _COORDINATE_MIN; i <= _COORDINATE_MAX; ++i) {
      final coveragesForLine = sensors
          .map((sensor) => sensor.coverageForLine(i))
          .map((range) {
            if (range == null) {
              return null;
            } else if (range.last < _COORDINATE_MIN || range.first > _COORDINATE_MAX) {
              return null;
            } else if (range.first < _COORDINATE_MIN && _COORDINATE_MIN < range.last) {
              return IntRange(_COORDINATE_MIN, min(range.last, _COORDINATE_MAX));
            } else if (range.first < _COORDINATE_MAX && _COORDINATE_MAX < range.last) {
              return IntRange(max(range.first, _COORDINATE_MIN), _COORDINATE_MAX);
            } else {
              return range;
            }
          })
          .whereNotNull();
      final coveredCells = _findCoveredCells(coveragesForLine);
      if (coveredCells.length > 1) {
        result = (coveredCells.first.last + 1) * _TUNING_FREQUENCY_X_MULTIPLIER + i;
        break;
      }
    }

    return result.toString();
  }

  List<Sensor> _parseInput() =>
    _input.readAsLinesSync()
        .map((line) => Sensor.fromInputLine(line))
        .toList();

  List<IntRange> _findCoveredCells(Iterable<IntRange> coveragesForLine) =>
    coveragesForLine.fold(<IntRange>[], (List<IntRange> acc, IntRange range) {
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