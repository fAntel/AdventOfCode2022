import 'dart:io';

void main() {
  final input = File("input");
  final fullyContainedSum = input
      .readAsLinesSync()
      .map((groupAssignments) {
        final ranges = groupAssignments.split(",")
            .map((assignment) => assignment.trim());
        return Pair(ranges.first, ranges.last);
      })
      .map((groupAssignments) =>
        Pair(
          IntRange.fromStringPeriod(groupAssignments.first),
          IntRange.fromStringPeriod(groupAssignments.second)
        )
      )
      .where((groupRanges) =>
          groupRanges.first.isFullyContains(groupRanges.second) ||
          groupRanges.second.isFullyContains(groupRanges.first)
      )
      .length;
  print(fullyContainedSum);
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

class IntRange {
  final int first;
  final int last;

  IntRange(this.first, this.last) {
    assert(first <= last);
  }

  factory IntRange.fromStringPeriod(String period) {
    final values = period.split("-");
    return IntRange(int.parse(values.first), int.parse(values.last));
  }

  bool isFullyContains(IntRange other) {
    return first <= other.first && other.last <= last;
  }

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
  String toString() {
    return 'IntRange{first: $first, last: $last}';
  }
}