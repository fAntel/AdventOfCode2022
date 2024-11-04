import 'days/BaseDay.dart';
import 'days/day18/Day18.dart';

void main() async {
  await _printDayResults(Day18());
}

Future<void> _printDayResults(final BaseDay day) async {
  print("Day ${day.number}: ${day.name}");
  print("Part 1\n${await day.partOne()}");
  print("Part 2\n${await day.partTwo()}");
}