import 'dart:io';

void main() {
  final input = File("input");
  final inputLines = input.readAsLinesSync();
  final gridWidth = inputLines.first.length;
  final gridHeight = inputLines.length;
  final grid = List<List<Tree>>.generate(gridHeight, (row) {
    return List<Tree>.generate(
        gridWidth, (column) => Tree(int.parse(inputLines[row][column])),
        growable: false);
  },
      growable: false);

  int k;
  Tree currentTree;
  for (int i = 0; i < gridHeight; ++i) {
    for (int j = 0; j < gridWidth; ++j) {
      currentTree = grid[i][j];

      k = j - 1;
      while (k >= 0 && !currentTree.isHiddenBy(grid[i][k])) --k;
      currentTree.leftVisible = k < 0;
      currentTree.leftViewingDistance = currentTree.leftVisible ? j : j - k;

      k = j + 1;
      while (k < gridWidth && !currentTree.isHiddenBy(grid[i][k])) ++k;
      currentTree.rightVisible = k >= gridWidth;
      currentTree.rightViewingDistance =
          currentTree.rightVisible ? gridWidth - j - 1 : k - j;

      k = i - 1;
      while (k >= 0 && !currentTree.isHiddenBy(grid[k][j])) --k;
      currentTree.topVisible = k < 0;
      currentTree.topViewingDistance = currentTree.topVisible ? i : i - k;

      k = i + 1;
      while (k < gridHeight && !currentTree.isHiddenBy(grid[k][j])) ++k;
      currentTree.bottomVisible = k >= gridHeight;
      currentTree.bottomViewingDistance =
          currentTree.bottomVisible ? gridHeight - i - 1 : k - i;
    }
  }

  for (int i = 0; i < gridHeight; ++i) {
    print(grid[i].join("\t"));
  }

  var visibleTreesCount = 0;
  var maxScenicScore = 0;
  for (int i = 0; i < gridHeight; ++i) {
    for (int j = 0; j < gridWidth; ++j) {
      if (grid[i][j].isVisible) {
        visibleTreesCount += 1;
      }
      if (grid[i][j].scenicScore > maxScenicScore) {
        maxScenicScore = grid[i][j].scenicScore;
      }
    }
  }

  print("Visible trees count: $visibleTreesCount, max scenic score: $maxScenicScore");
}

class Tree {
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

  Tree(this.height);

  bool isHiddenBy(Tree other) {
    return other.height >= height;
  }

  @override
  String toString() {
    return 'Tree{height: $height, isVisible: $isVisible, scenic score: $scenicScore}';
  }
}