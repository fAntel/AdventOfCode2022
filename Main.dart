import 'dart:io';

import 'package:collection/collection.dart';

const ROUNDS_COUNT = 10000;

void main() {
  final input = File("input");
  final pairsOfPackets = input.readAsLinesSync()
      .splitAfter((element) => element.isEmpty)
      .map((list) => Pair<Packet, Packet>(
          Packet.fromInputLine(list.first), Packet.fromInputLine(list[1])))
      .toList();

  int result = 0;
  for (int i = 0; i < pairsOfPackets.length; ++i) {
    if (pairsOfPackets[i].isOrderRight()) {
      result += i + 1;
    }
  }

  print(result);
}

class Pair<F, S> {
  final F first;
  final S second;

  Pair(F this.first, S this.second);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Pair &&
              runtimeType == other.runtimeType &&
              first == other.first &&
              second == other.second;

  @override
  int get hashCode => first.hashCode ^ second.hashCode;

  @override
  String toString() => 'Pair{first: $first, second: $second}';
}

class Packet {
  final List<dynamic> data;

  Packet(this.data);

  factory Packet.fromInputLine(String inputLine) {
    final parsedPacket = [];
    _parseInput(inputLine, parsedPacket, 0);
    return Packet(parsedPacket);
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
}

extension PairOfPacketsExtenstions on Pair<Packet, Packet> {
  bool isOrderRight() {
    bool? result = _checkListOrder(first.data, second.data);
    if (result != null) {
      return result;
    } else {
      throw ArgumentError("Cannot find out order: $this");
    }
  }

  bool? _checkListOrder(List<dynamic> first, List<dynamic> second) {
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

  bool? _checkIntOrder(int first, int second) {
    if (first < second) {
      return true;
    } else if (first > second) {
      return false;
    } else {
      return null;
    }
  }
}