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
  String toString() => "Pair{first: $first, second: $second}";
}