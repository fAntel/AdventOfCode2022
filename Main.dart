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

      k = j + 1;
      while (k < gridWidth && !currentTree.isHiddenBy(grid[i][k])) ++k;
      currentTree.rightVisible = k >= gridWidth;

      k = i - 1;
      while (k >= 0 && !currentTree.isHiddenBy(grid[k][j])) --k;
      currentTree.topVisible = k < 0;

      k = i + 1;
      while (k < gridHeight && !currentTree.isHiddenBy(grid[k][j])) ++k;
      currentTree.bottomVisible = k >= gridHeight;
    }
  }

  for (int i = 0; i < gridHeight; ++i) {
    print(grid[i].join("\t"));
  }

  var sum = 0;
  for (int i = 0; i < gridHeight; ++i) {
    for (int j = 0; j < gridWidth; ++j) {
      if (grid[i][j].isVisible) {
        sum += 1;
      }
    }
  }

  print(sum);
}

class Tree {
  final int height;
  var topVisible = false;
  var bottomVisible = false;
  var leftVisible = false;
  var rightVisible = false;

  get isVisible => topVisible || bottomVisible || leftVisible || rightVisible;

  Tree(this.height);

  bool isHiddenBy(Tree other) {
    return other.height >= height;
  }

  @override
  String toString() {
    return 'Tree{height: $height, isVisible: $isVisible}';
  }
}