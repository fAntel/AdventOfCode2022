abstract class BaseDay {
  abstract final int number;
  abstract final String name;

  String partOne({bool withDebugPrint = false});
  String partTwo({bool withDebugPrint = false});

  String get defaultInputPath =>
      "days/day${number.toString().padLeft(2, '0')}/input";
}