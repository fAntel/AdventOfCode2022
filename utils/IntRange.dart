class IntRange {
  final int first;
  final int last;

  IntRange(this.first, this.last) {
    assert(first <= last);
  }

  int get length => last - first + 1;

  bool isFullyContains(IntRange other) =>
      first <= other.first && other.last <= last;

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
  String toString() => "IntRange{first: $first, last: $last}";
}