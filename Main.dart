import 'dart:io';

void main() {
  final input = File("input");
  final inputLines = input.readAsLinesSync();
  final gridWidth = inputLines.first.length;
  final gridHeight = inputLines.length;
  final grid = List<List<Tree>>.generate(gridHeight, (row) {
    return List<Tree>.generate(
        gridWidth, (column) {
          final result = Tree(int.parse(inputLines[row][column]));
          result.topVisible = row == 0;
          result.leftVisible = column == 0;
          return result;
    },
        growable: false);
  },
      growable: false);

  int k;
  Tree currentTree;
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

  for (int i = 0; i < gridHeight; ++i) {
    print(grid[i].join("\t"));
  }

  var visibleTreesCount = gridHeight * 2 + (gridWidth - 2) * 2;
  for (int i = 1; i + 1 < gridHeight; ++i) {
    for (int j = 1; j + 1 < gridWidth; ++j) {
      if (grid[i][j].isVisible) {
        visibleTreesCount += 1;
      }
    }
  }

  print("Visible trees count: $visibleTreesCount");
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