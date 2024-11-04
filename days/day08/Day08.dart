import 'dart:io';

import '../BaseDay.dart';

class Day08 extends BaseDay {
  @override
  int number = 8;
  @override
  String name = "Treetop Tree House";

  File get _input => File(defaultInputPath);

  @override
  String partOne({bool withDebugPrint = false}) {
    final inputLines = _input.readAsLinesSync();
    final gridWidth = inputLines.first.length;
    final gridHeight = inputLines.length;
    List<List<_Tree>> grid = _readGrid(gridHeight, gridWidth, inputLines);

    int k;
    _Tree currentTree;
    for (int i = 1; i + 1 < gridHeight; ++i) {
      for (int j = 1; j + 1 < gridWidth; ++j) {
        currentTree = grid[i][j];

        k = j - 1;
        while (k >= 0 && !currentTree.isHiddenBy(grid[i][k]) && !grid[i][k].leftVisible)
          --k;
        currentTree.leftVisible = k >= 0 && !currentTree.isHiddenBy(grid[i][k]);
        if (currentTree.isVisible)
          continue;

        k = i - 1;
        while (k >= 0 && !currentTree.isHiddenBy(grid[k][j]) && !grid[k][j].topVisible)
          --k;
        currentTree.topVisible = k >= 0 && !currentTree.isHiddenBy(grid[k][j]);
        if (currentTree.isVisible)
          continue;

        k = j + 1;
        while (k < gridWidth && !currentTree.isHiddenBy(grid[i][k]))
          ++k;
        currentTree.rightVisible = k >= gridWidth;
        if (currentTree.isVisible)
          continue;

        k = i + 1;
        while (k < gridHeight && !currentTree.isHiddenBy(grid[k][j])) ++k;
        currentTree.bottomVisible = k >= gridHeight;
      }
    }

    if (withDebugPrint) {
      for (int i = 0; i < gridHeight; ++i) {
        print(grid[i].join("\t"));
      }
    }

    var visibleTreesCount = gridHeight * 2 + (gridWidth - 2) * 2;
    for (int i = 1; i + 1 < gridHeight; ++i) {
      for (int j = 1; j + 1 < gridWidth; ++j) {
        if (grid[i][j].isVisible) {
          visibleTreesCount += 1;
        }
      }
    }

    return visibleTreesCount.toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    final inputLines = _input.readAsLinesSync();
    final gridWidth = inputLines.first.length;
    final gridHeight = inputLines.length;
    List<List<_Tree>> grid = _readGrid(gridHeight, gridWidth, inputLines);

    var maxScenicScore = 0;
    int k;
    _Tree currentTree;
    _Tree anotherTree;
    int maxPossibleHorizontalScorePart = gridWidth % 2 == 0
        ? (gridWidth ~/ 2) * (gridWidth ~/ 2 - 1)
        : (gridWidth ~/ 2) << 1;
    for (int i = 1; i + 1 < gridHeight; ++i) {
      if (i > gridHeight ~/ 2) {
        // gridHeight - i - 2 because -1 for current row and -1 for counting from 0
        final int maxPossibleScenicScoreForCurrentRow =
            maxPossibleHorizontalScorePart * i * (gridHeight - i - 2);
        if (maxPossibleScenicScoreForCurrentRow <= maxScenicScore)
          // drop low rows calculation because there could not be more score then current max
          break;
      }

      for (int j = 1; j + 1 < gridWidth; ++j) {
        currentTree = grid[i][j];

        anotherTree = grid[i][j - 1];
        if (currentTree.isHiddenBy(anotherTree)) {
          currentTree.leftViewingDistance = 1;
        } else if (currentTree.isHiddenBy(grid[i][j - anotherTree.leftViewingDistance - 1])) {
          currentTree.leftViewingDistance = anotherTree.leftViewingDistance + 1;
        } else {
          k = j - anotherTree.leftViewingDistance - 2;
          while (k >= 0 && !currentTree.isHiddenBy(grid[i][k]))
            --k;
          currentTree.leftViewingDistance = k < 0 ? j : j - k;
        }

        anotherTree = grid[i - 1][j];
        if (currentTree.isHiddenBy(anotherTree)) {
          currentTree.topViewingDistance = 1;
        } else if (currentTree.isHiddenBy(grid[i - anotherTree.topViewingDistance - 1][j])) {
          currentTree.topViewingDistance = anotherTree.topViewingDistance + 1;
        } else {
          k = i - anotherTree.topViewingDistance - 2;
          while (k >= 0 && !currentTree.isHiddenBy(grid[i][k]))
            --k;
          currentTree.topViewingDistance = k < 0 ? i : i - k;
        }

        k = j + 1;
        while (k < gridWidth && !currentTree.isHiddenBy(grid[i][k]))
          ++k;
        currentTree.rightViewingDistance = k >= gridWidth ? gridWidth - j - 1 : k - j;

        k = i + 1;
        while (k < gridHeight && !currentTree.isHiddenBy(grid[k][j])) ++k;
        currentTree.bottomViewingDistance = k >= gridHeight ? gridHeight - i - 1 : k - i;

        if (grid[i][j].scenicScore > maxScenicScore) {
          maxScenicScore = grid[i][j].scenicScore;
        }
      }
    }

    if (withDebugPrint) {
      for (int i = 0; i < gridHeight; ++i) {
        print(grid[i].join("\t"));
      }
    }

    return maxScenicScore.toString();
  }

  List<List<_Tree>> _readGrid(int gridHeight, int gridWidth, List<String> inputLines) {
    final grid = List<List<_Tree>>.generate(gridHeight, (row) {
      return List<_Tree>.generate(
          gridWidth, (column) {
        final result = _Tree(int.parse(inputLines[row][column]));
        result.topVisible = row == 0;
        result.leftVisible = column == 0;
        return result;
      },
          growable: false);
    },
        growable: false);
    return grid;
  }
}

class _Tree {
  final int height;
  var topVisible = false;
  var bottomVisible = false;
  var leftVisible = false;
  var rightVisible = false;

  var topViewingDistance = 0;
  var bottomViewingDistance = 0;
  var leftViewingDistance = 0;
  var rightViewingDistance = 0;

  get isVisible => topVisible || bottomVisible || leftVisible || rightVisible;

  get scenicScore =>
      topViewingDistance *
      bottomViewingDistance *
      leftViewingDistance *
      rightViewingDistance;

  _Tree(this.height);

  bool isHiddenBy(_Tree other) => other.height >= height;

  @override
  String toString() =>
      "Tree{height: $height, isVisible: $isVisible, scenic score: $scenicScore}";
}