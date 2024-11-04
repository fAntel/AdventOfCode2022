import 'dart:io';

import 'package:collection/collection.dart';

import '../../utils/RedBlackTree.dart';
import '../BaseDay.dart';

class Day18 extends BaseDay {
  @override
  int number = 18;
  @override
  String name = "Boiling Boulders";

  File get _input => File("days/day18/input");
  
  @override
  String partOne({bool withDebugPrint = false}) {
    final qubes = _input.readAsLinesSync()
        .map((line) => _Coordinate.fromInputLine(line))
        .map((coord) => _Qube(coord))
        .toList(growable: false);

    final _SparseIntArray<_SparseIntArray<_SparseIntArray<_Qube>>> bitOfLava =
    _SparseIntArray();
    qubes.forEach((qube) {
      final x = qube.coordinate.x;
      final y = qube.coordinate.y;
      final z = qube.coordinate.z;
      if (!bitOfLava.containsIndex(z)) {
        bitOfLava[z] = _SparseIntArray<_SparseIntArray<_Qube>>();
      }
      if (!bitOfLava[z]!.containsIndex(x)) {
        bitOfLava[z]![x] = _SparseIntArray<_Qube>();
      }
      bitOfLava[z]![x]![y] = qube;
    });

    if (withDebugPrint) {
      _printQubeBySurfaces(bitOfLava);
    }

    int prevZ = -1;
    for (final int z in bitOfLava.indexes) {
      final zSurface = bitOfLava[z];
      if (zSurface == null || zSurface.isEmpty)
        continue;

      int prevX = -1;
      for (final int x in zSurface.indexes) {
        final yLine = zSurface[x];
        if (yLine == null || yLine.isEmpty)
          continue;

        int prevY = -1;
        for (final int y in yLine.indexes) {
          final _Qube currentQube = yLine[y]!;

          if (prevY >= 0 && y - prevY <= 1) {
            final _Qube? bottomQube = yLine[prevY];
            if (bottomQube != null) {
              bottomQube.markSideHidden(_Side.top);
              currentQube.markSideHidden(_Side.bottom);
            }
          }

          if (prevX >= 0 && x - prevX <= 1) {
            final _Qube? leftQube = zSurface[prevX]?[y];
            if (leftQube != null) {
              leftQube.markSideHidden(_Side.right);
              currentQube.markSideHidden(_Side.left);
            }
          }

          if (prevZ >= 0 && z - prevZ <= 1) {
            final _Qube? frontQube = bitOfLava[prevZ]?[x]?[y];
            if (frontQube != null) {
              frontQube.markSideHidden(_Side.back);
              currentQube.markSideHidden(_Side.front);
            }
          }

          prevY = y;
        }

        prevX = x;
      }

      prevZ = z;
    }

    final result = qubes.fold(0, (int sum, qube) => sum + qube.visibleSidesCount);
    return result.toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    throw UnimplementedError();
  }

  void _printQubeBySurfaces(
      _SparseIntArray<_SparseIntArray<_SparseIntArray<_Qube>>> bitOfLava) {
    int minX = 1 << 32 - 1, maxX = -1, minY = 1 << 32 - 1, maxY = -1;
    for (final int z in bitOfLava.indexes) {
      final zSurface = bitOfLava[z];
      if (zSurface == null || zSurface.isEmpty)
        continue;

      for (final int x in zSurface.indexes) {
        final yLine = zSurface[x];
        if (yLine == null || yLine.isEmpty)
          continue;

        if (x < minX) {
          minX = x;
        }
        if (x > maxX) {
          maxX = x;
        }

        int n = yLine.indexes.min;
        if (n < minY) {
          minY = n;
        }
        n = yLine.indexes.max;
        if (n > maxY) {
          maxY = n;
        }
      }
    }

    final zs = bitOfLava.indexes.sorted((a, b) => a.compareTo(b));
    for (final int z in zs) {
      print("z = $z:");

      final zSurface = bitOfLava[z];
      if (zSurface == null || zSurface.isEmpty) {
        print("empty!\n");
        continue;
      }

      final square = List.generate(maxY - minY + 1,
              (index) => List.generate(maxX - minX + 1, (index) => "."));

      for (final int x in zSurface.indexes) {
        final yLine = zSurface[x];
        if (yLine == null || yLine.isEmpty)
          continue;

        for (final int y in yLine.indexes) {
          square[y - minY][x - minX] = "#";
        }
      }

      print(square.map((row) => row.join()).join("\n"));
      print("");
    }
  }
}

enum _Side {
  top(bit: 1), bottom(bit: 2), left(bit: 4), right(bit: 8), front(bit: 16),
  back(bit: 32);

  static const ALL_SIDES_VISIBLE_MAP = 0x3F;

  final int bit;

  const _Side({
    required this.bit,
  });
}

class _Qube {
  final _Coordinate coordinate;
  int visibleSidesBitMap = _Side.ALL_SIDES_VISIBLE_MAP;
  
  int get visibleSidesCount {
    int n = (visibleSidesBitMap >> 1) & 0x1B;
    int result = visibleSidesBitMap - n;
    n = (n >> 1) & 0x1B;
    result -= n;
    result = (result + (result >> 3)) & 7;
    return result;
  }

  _Qube(this.coordinate);

  bool isSideVisible(_Side side) => visibleSidesBitMap & side.bit != 0;

  void markSideHidden(_Side side) {
    visibleSidesBitMap &= ~side.bit;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Qube &&
          runtimeType == other.runtimeType &&
          coordinate == other.coordinate;

  @override
  int get hashCode => coordinate.hashCode;

  @override
  String toString() =>
      "Qube{coordinate: $coordinate, sidesVisible: ${visibleSidesBitMap.toRadixString(16)}}";
}

class _Coordinate {
  final int x;
  final int y;
  final int z;

  _Coordinate(this.x, this.y, this.z);

  factory _Coordinate.fromInputLine(String inputLine) {
    final numbers = inputLine.split(",").map((i) => int.parse(i)).toList();
    return _Coordinate(numbers[0], numbers[1], numbers[2]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Coordinate &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;

  @override
  String toString() => "Coordinate{x: $x, y: $y, z: $z}";
}

class _SparseIntArray<T> {
  final _data = RedBlackTree<int, T>();

  void add(int index, T value) => _data.insert(index, value);

  bool containsIndex(int index) => _data.lookup(index) != null;

  T? operator [](int index) => _data.lookupValue(index);

  void operator []=(int index, T value) => _data.insert(index, value);

  Iterable<int> get indexes => _data.keys;

  bool get isEmpty => _data.keys.isEmpty;
}