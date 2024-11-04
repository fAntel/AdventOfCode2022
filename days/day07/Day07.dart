import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';

import '../BaseDay.dart';

const _MAX_SIZE_TO_DELETE = 100000;
const _FILESYSTEM_MAX_SIZE = 70000000;
const _UPDATE_SIZE = 30000000;

class Day07 extends BaseDay {
  @override
  int number = 7;
  @override
  String name = "No Space Left On Device";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    _DirectoryInfo filesystem = _readFilesystem(withDebugPrint);

    final directoriesSizes = <int>[];
    final totalSize = _sumToDeleteDirectoriesSizes(filesystem, directoriesSizes);

    final result = directoriesSizes.sum;
    if (withDebugPrint) {
      print("Total size is $totalSize");
    }
    return result.toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    _DirectoryInfo filesystem = _readFilesystem(withDebugPrint);

    final directoriesSizes = <_Node, int>{};
    final totalSize = _calculateDirectoriesSizes(filesystem, directoriesSizes);

    final needToFree = _UPDATE_SIZE - (_FILESYSTEM_MAX_SIZE - totalSize);
    int result = _UPDATE_SIZE;
    _Node? directoryToDelete = null;
    for (final entry in directoriesSizes.entries) {
      if (entry.value >= needToFree && entry.value < result) {
        result = entry.value;
        directoryToDelete = entry.key;
      }
    }

    if (withDebugPrint) {
      print("Total size is $totalSize, need to free $needToFree");
      print('Remove directory "${directoryToDelete?.name ??
          "<unknown>"} with size $result');
    }
    return result.toString();
  }

  _DirectoryInfo _readFilesystem(bool withDebugPrint) {
    final inputLines = _input.readAsLinesSync();

    final filesystem = _DirectoryInfo(null, _DirectoryInfo.FILESYSTEM_ROOT_NAME);

    _Command command;
    _Node currentDirectory = filesystem;
    while (inputLines.isNotEmpty) {
      command = _Command.fromInputLine(inputLines.removeAt(0));
      currentDirectory = command.run(currentDirectory, inputLines);
    }

    if (withDebugPrint) {
      _printDirectoryRecursive(filesystem, 0);
    }

    return filesystem;
  }

  int _sumToDeleteDirectoriesSizes(_DirectoryInfo directory,
      List<int> directoriesSizes) {
    var sum = 0;

    for (final child in directory.children) {
      if (child is _DirectoryInfo) {
        sum += _sumToDeleteDirectoriesSizes(child, directoriesSizes);
      } else if (child is _FileInfo) {
        sum += child.size;
      }
    }

    if (sum <= _MAX_SIZE_TO_DELETE) {
      directoriesSizes.add(sum);
    }

    return sum;
  }

  int _calculateDirectoriesSizes(
      _DirectoryInfo directory, Map<_Node, int> directoriesSizes) {
    var sum = 0;

    for (final child in directory.children) {
      if (child is _DirectoryInfo) {
        sum += _calculateDirectoriesSizes(child, directoriesSizes);
      } else if (child is _FileInfo) {
        sum += child.size;
      }
    }

    directoriesSizes[directory] = sum;
    return sum;
  }

  void _printDirectoryRecursive(_Node currentDirectory, int depth) {
    var offset = " " * (depth * 2);
    print("$offset- ${currentDirectory.name} (dir)");
    offset += "  ";
    for (final child in currentDirectory.children) {
      if (child is _DirectoryInfo) {
        _printDirectoryRecursive(child, depth + 1);
      } else {
        print("$offset- $child");
      }
    }
  }
}

abstract class _Node {
  final String name;
  final _Node? parent;
  final _children = <_Node>[];
  List<_Node> get children => List.unmodifiable(_children);

  _Node(this.parent, this.name);

  void put(_Node child) {
    _children.add(child);
  }

  factory _Node.fromInputLine(_Node currentDirectory, String inputLine) {
    if (_DirectoryInfo.isDirectory(inputLine)) {
      return _DirectoryInfo.fromInput(currentDirectory, inputLine);
    } else {
      return _FileInfo.fromInput(currentDirectory, inputLine);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _Node &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              parent == other.parent;

  @override
  int get hashCode => name.hashCode ^ parent.hashCode;
}

class _FileInfo extends _Node {
  final int size;

  _FileInfo(super.parent, this.size, super.name);

  factory _FileInfo.fromInput(_Node currentDirectory, String input) {
    final firstSpaceIndex = input.indexOf(" ");
    return _FileInfo(
        currentDirectory,
        int.tryParse(input.substring(0, min(firstSpaceIndex, input.length))) ??
            0,
        firstSpaceIndex + 1 < input.length
            ? input.substring(firstSpaceIndex + 1)
            : "");
  }

  @override
  void put(_Node child) {
    throw UnsupportedError("File cannot have children.");
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _FileInfo &&
              runtimeType == other.runtimeType &&
              size == other.size &&
              name == other.name &&
              parent == other.parent;

  @override
  int get hashCode => size.hashCode ^ name.hashCode ^ parent.hashCode;

  @override
  String toString() {
    return 'FileInfo{name: $name, size: $size}';
  }
}

class _DirectoryInfo extends _Node {
  static const _DIRECTORY_PREFIX = "dir ";
  static const FILESYSTEM_ROOT_NAME = "/";
  static const PARENT_DIRECTORY = "..";

  _DirectoryInfo(super.parent, super.name);

  factory _DirectoryInfo.fromInput(_Node currentDirectory, String input) {
    return _DirectoryInfo(
        currentDirectory, input.substring(_DIRECTORY_PREFIX.length));
  }

  static bool isDirectory(String input) {
    return input.startsWith(_DIRECTORY_PREFIX);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          super == other &&
              other is _DirectoryInfo &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() {
    return 'DirectoryInfo{name: $name, [${children.join(", ")}]}';
  }
}

abstract class _Command {
  static const _COMMAND_PREFIX = r"$";
  final String args;

  _Command(this.args);

  _Node run(_Node currentDirectory, List<String> inputLines);

  static bool isCommand(String inputLine) {
    return inputLine.startsWith(_COMMAND_PREFIX);
  }

  factory _Command.fromInputLine(String inputLine) {
    final split = inputLine.split(" ");

    if (split.isEmpty || split.first != _COMMAND_PREFIX) {
      throw ArgumentError("It isn't command: $inputLine");
    }

    if (split.length < 2) {
      throw ArgumentError("Command is missing: $inputLine");
    }

    switch (split[1]) {
      case _Ls.COMMAND_NAME: return _Ls();
      case Cd.COMMAND_NAME: return Cd(split.skip(2).join(" "));
      default: throw ArgumentError("Unknown command ${split[1]}.");
    }
  }
}

class _Ls extends _Command {
  static const COMMAND_NAME = "ls";

  _Ls() : super("");

  @override
  _Node run(_Node currentDirectory, List<String> inputLines) {
    while (inputLines.isNotEmpty && !_Command.isCommand(inputLines.first)) {
      currentDirectory.put(
          _Node.fromInputLine(currentDirectory, inputLines.removeAt(0)));
    }
    return currentDirectory;
  }
}

class Cd extends _Command {
  static const COMMAND_NAME = "cd";

  Cd(super.args);

  @override
  _Node run(_Node currentDirectory, List<String> inputLines) {
    switch (args) {
      case _DirectoryInfo.FILESYSTEM_ROOT_NAME:
        _Node result = currentDirectory;
        while (result.parent != null) {
          result = result.parent!;
        }
        return result;
      case _DirectoryInfo.PARENT_DIRECTORY:
        return currentDirectory.parent ?? currentDirectory;
      default:
        return currentDirectory.children.firstWhere((node) => node.name == args,
            orElse: () =>
            throw StateError(
                'Cannot find directory "$args" in current directory: $currentDirectory'));
    }
  }
}