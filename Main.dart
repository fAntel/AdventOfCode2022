import 'dart:io';

import 'package:collection/collection.dart';

void main() {
  final input = File("input");
  final priorities = input
      .readAsLinesSync()
      .map((e) => Pair(e.substring(0, e.length ~/ 2), e.substring(e.length ~/ 2)))
      .map((e) => Pair(e.first.toSet(), e.second.toSet()))
      .map((e) => e.first.intersection(e.second))
      .map((e) => e.single.codeUnitAt(0))
      .map((e) {
        if ("a".codeUnitAt(0) <= e && e <= "z".codeUnitAt(0)) {
          return e - "a".codeUnitAt(0) + 1;
        } else {
          return 27 + e - "A".codeUnitAt(0);
        }
      })
      .sum;
  print(priorities);
}

class Pair<T> {
  final T first;
  final T second;

  Pair(T this.first, T this.second);

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
  String toString() {
    return 'Pair{first: $first, second: $second}';
  }
}

extension StringExtenstions on String {
  Set<String> toSet() {
    final result = <String>{};
    for (var i = 0; i < length; ++i) {
      result.add(this[i]);
    }
    return result;
  }
}