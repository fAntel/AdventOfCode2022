import 'dart:io';

import 'package:collection/collection.dart';

import '../../utils/Pair.dart';
import '../BaseDay.dart';

class Day13 extends BaseDay {
  @override
  int number = 13;
  @override
  String name = "Distress Signal";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    final pairsOfPackets = _input.readAsLinesSync()
        .splitAfter((element) => element.isEmpty)
        .map((list) => Pair<_Packet, _Packet>(
            _Packet.fromInputLine(list.first), _Packet.fromInputLine(list[1])))
        .toList();

    int result = 0;
    for (int i = 0; i < pairsOfPackets.length; ++i) {
      if (pairsOfPackets[i].isOrderRight()) {
        result += i + 1;
      }
    }

    return result.toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    final firstDividerPacket = _Packet([[2]]);
    final secondDividerPacket = _Packet([[6]]);
    final packets = _input.readAsLinesSync()
        .where((line) => line.isNotEmpty)
        .map((line) => _Packet.fromInputLine(line))
        .toList();

    packets.addAll([firstDividerPacket, secondDividerPacket]);
    packets.sort();

    int decoderKey = (packets.indexOf(firstDividerPacket) + 1) *
        (packets.indexOf(secondDividerPacket) + 1);
    return decoderKey.toString();
  }
}

class _Packet implements Comparable<_Packet> {
  final List<dynamic> data;

  _Packet(this.data);

  factory _Packet.fromInputLine(String inputLine) {
    final parsedPacket = [];
    _parseInput(inputLine, parsedPacket, 0);
    return _Packet(parsedPacket);
  }

  static int _parseInput(final String input, final List<dynamic> result, int i) {
    while (i < input.length) {
      if (input[i] == '[') {
        var list = [];
        result.add(list);
        i = _parseInput(input, list, i + 1);
      } else if (input[i] == ']') {
        return i + 1;
      } else if (int.tryParse(input[i]) != null) {
        int n = 0;
        int j = 1;
        int? parsed = null;
        do {
          parsed = int.tryParse(input[i]);
          if (parsed != null) {
            n = n * j + parsed;
            j *= 10;
            ++i;
          }
        } while (i < input.length && parsed != null);
        result.add(n);
      } else {
        ++i;
      }
    }
    return i;
  }

  @override
  String toString() {
    final buf = StringBuffer("Packet{data: ");
    prepareToString(buf, data);
    buf.write("}");
    return buf.toString();
  }

  void prepareToString(StringBuffer buf, List<dynamic> list) {
    buf.write("[");
    for (int i = 0; i < data.length; ++i) {
      if (data[i] is int) {
        buf.write(data[i].toString());
      } else if (data[i] is List) {
        prepareToString(buf, data[i]);
      } else {
        buf.write("${data[i]} (${data[i].runtimeType.toString()})");
      }
      if (i + 1 < data.length) {
        buf.write(", ");
      }
    }
    buf.write("]");
  }

  @override
  int compareTo(_Packet other) {
    bool? result = _checkListOrder(this.data, other.data);
    switch (result) {
      case true:  return -1;
      case false: return 1;
      default:    return 0;
    }
  }

  static bool? _checkListOrder(List<dynamic> first, List<dynamic> second) {
    int i = 0;
    dynamic f, s;
    bool? possibleResult;
    while (i < first.length && i < second.length) {
      if (first[i].runtimeType == second[i].runtimeType) {
        f = first[i];
        s = second[i];
      } else {
        f = first[i] is int ? [first[i]] : first[i];
        s = second[i] is int ? [second[i]] : second[i];
      }

      if (f is int) {
        possibleResult = _checkIntOrder(f, s);
        if (possibleResult != null) {
          return possibleResult;
        }
      } else if (f is List<dynamic>) {
        possibleResult = _checkListOrder(f, s);
        if (possibleResult != null) {
          return possibleResult;
        }
      } else {
        throw ArgumentError("Unknown type: ${f.runtimeType.toString()}");
      }

      ++i;
    }
    if (first.length < second.length) {
      return true;
    } else if (first.length > second.length) {
      return false;
    } else {
      return null;
    }
  }

  static bool? _checkIntOrder(int first, int second) {
    if (first < second) {
      return true;
    } else if (first > second) {
      return false;
    } else {
      return null;
    }
  }
}

extension _PairOfPacketsExtenstions on Pair<_Packet, _Packet> {
  bool isOrderRight() {
    bool? result = _Packet._checkListOrder(first.data, second.data);
    if (result != null) {
      return result;
    } else {
      throw ArgumentError("Cannot find out order: $this");
    }
  }
}