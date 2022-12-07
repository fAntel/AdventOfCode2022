import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';

const MAX_SIZE_TO_DELETE = 100000;

void main() async {
  final input = File("input");
  final inputLines = input.readAsLinesSync();

  final filesystem = DirectoryInfo(null, DirectoryInfo.FILESYSTEM_ROOT_NAME);

  Command command;
  Node currentDirectory = filesystem;
  while (inputLines.isNotEmpty) {
    command = Command.fromInputLine(inputLines.removeAt(0));
    currentDirectory = command.run(currentDirectory, inputLines);
  }

  printDirectoryRecursive(filesystem, 0);

  final directoriesSizes = <int>[];
  final totalSize = sumToDeleteDirectoriesSizes(filesystem, directoriesSizes);

  final result = directoriesSizes.sum;
  print("Total size is $totalSize");
  print(result);
}

int sumToDeleteDirectoriesSizes(DirectoryInfo directory,
    List<int> directoriesSizes) {
  var sum = 0;

  for (final child in directory.children) {
    if (child is DirectoryInfo) {
      sum += sumToDeleteDirectoriesSizes(child, directoriesSizes);
    } else if (child is FileInfo) {
      sum += child.size;
    }
  }

  if (sum <= MAX_SIZE_TO_DELETE) {
    directoriesSizes.add(sum);
  }

  return sum;
}

void printDirectoryRecursive(Node currentDirectory, int depth) {
  var offset = " " * (depth * 2);
  print("$offset- ${currentDirectory.name} (dir)");
  offset += "  ";
  for (final child in currentDirectory.children) {
    if (child is DirectoryInfo) {
      printDirectoryRecursive(child, depth + 1);
    } else {
      print("$offset- $child");
    }
  }
}

abstract class Node {
  final String name;
  final Node? parent;
  final _children = <Node>[];
  List<Node> get children => List.unmodifiable(_children);

  Node(this.parent, this.name);

  void put(Node child) {
    _children.add(child);
  }

  factory Node.fromInputLine(Node currentDirectory, String inputLine) {
    if (DirectoryInfo.isDirectory(inputLine)) {
      return DirectoryInfo.fromInput(currentDirectory, inputLine);
    } else {
      return FileInfo.fromInput(currentDirectory, inputLine);
    }
  }
}

class FileInfo extends Node {
  final int size;

  FileInfo(super.parent, this.size, super.name);

  factory FileInfo.fromInput(Node currentDirectory, String input) {
    final firstSpaceIndex = input.indexOf(" ");
    return FileInfo(
        currentDirectory,
        int.tryParse(input.substring(0, min(firstSpaceIndex, input.length))) ??
            0,
        firstSpaceIndex + 1 < input.length
            ? input.substring(firstSpaceIndex + 1)
            : "");
  }

  @override
  void put(Node child) {
    throw UnsupportedError("File cannot have children.");
  }

  @override
  String toString() {
    return 'FileInfo{name: $name, size: $size}';
  }
}

class DirectoryInfo extends Node {
  static const _DIRECTORY_PREFIX = "dir ";
  static const FILESYSTEM_ROOT_NAME = "/";
  static const PARENT_DIRECTORY = "..";

  DirectoryInfo(super.parent, super.name);

  factory DirectoryInfo.fromInput(Node currentDirectory, String input) {
    return DirectoryInfo(
        currentDirectory, input.substring(_DIRECTORY_PREFIX.length));
  }

  static bool isDirectory(String input) {
    return input.startsWith(_DIRECTORY_PREFIX);
  }

  @override
  String toString() {
    return 'DirectoryInfo{name: $name, [${children.join(", ")}]}';
  }
}

abstract class Command {
  static const _COMMAND_PREFIX = r"$";
  final String args;

  Command(this.args);

  Node run(Node currentDirectory, List<String> inputLines);

  static bool isCommand(String inputLine) {
    return inputLine.startsWith(_COMMAND_PREFIX);
  }

  factory Command.fromInputLine(String inputLine) {
    final split = inputLine.split(" ");

    if (split.isEmpty || split.first != _COMMAND_PREFIX) {
      throw ArgumentError("It isn't command: $inputLine");
    }

    if (split.length < 2) {
      throw ArgumentError("Command is missing: $inputLine");
    }

    switch (split[1]) {
      case Ls.COMMAND_NAME: return Ls();
      case Cd.COMMAND_NAME: return Cd(split.skip(2).join(" "));
      default: throw ArgumentError("Unknown command ${split[1]}.");
    }
  }
}

class Ls extends Command {
  static const COMMAND_NAME = "ls";

  Ls() : super("");

  @override
  Node run(Node currentDirectory, List<String> inputLines) {
    while (inputLines.isNotEmpty && !Command.isCommand(inputLines.first)) {
      currentDirectory.put(
          Node.fromInputLine(currentDirectory, inputLines.removeAt(0)));
    }
    return currentDirectory;
  }
}

class Cd extends Command {
  static const COMMAND_NAME = "cd";

  Cd(super.args);

  @override
  Node run(Node currentDirectory, List<String> inputLines) {
    switch (args) {
      case DirectoryInfo.FILESYSTEM_ROOT_NAME:
        Node result = currentDirectory;
        while (result.parent != null) {
          result = result.parent!;
        }
        return result;
      case DirectoryInfo.PARENT_DIRECTORY:
        return currentDirectory.parent ?? currentDirectory;
      default:
        return currentDirectory.children.firstWhere((node) => node.name == args,
            orElse: () =>
            throw StateError(
                'Cannot find directory "$args" in current directory: $currentDirectory'));
    }
  }
}