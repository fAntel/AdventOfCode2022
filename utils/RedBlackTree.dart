import 'dart:collection';

import 'Stack.dart';

enum _Color { black, red }

enum _Direction {
  left, right;

  _Direction get otherDirection {
    switch (this) {
      case _Direction.left: return _Direction.right;
      case _Direction.right: return _Direction.left;
    }
  }
}

class _Node<Key, Value> {
  final Key key;
  Value value;

  _Node<Key, Value>? parent = null;
  _Node<Key, Value>? left = null;
  _Node<Key, Value>? right = null;

  _Color color = _Color.red;

  _Node<Key, Value> get grandparent {
    assert(parent != null);
    assert(parent!.parent != null);
    return parent!.parent!;
  }

  _Node<Key, Value>? get sibling {
    assert(parent != null);
    return this == parent!.left ? parent!.right : parent!.left;
  }

  _Node<Key, Value>? get uncle {
    assert(parent != null);
    assert(parent!.parent != null);
    return parent! == parent!.parent!.left
        ? parent!.parent!.right
        : parent!.parent!.left;
  }

  _Node(this.key, this.value);

  factory _Node.newNode(Key key, Value value, _Color color,
      _Node<Key, Value>? left, _Node<Key, Value>? right) {
    final _Node<Key, Value> result = _Node(key, value);
    result.color = color;
    result.left = left;
    result.right = right;
    left?.parent = result;
    right?.parent = result;
    return result;
  }

  @override
  String toString() => "Node{key: $key, value: $value}";
}

class RedBlackTree<Key extends Comparable, Value> {
  _Node<Key, Value>? _root = null;

  Iterable<Key> get keys => _KeysIterable<Key, Value>(this);

  _Node<Key, Value>? lookup(Key key) {
    _Node<Key, Value>? node = _root;
    while (node != null) {
      final int comparisonResult = key.compareTo(node.key);
      if (comparisonResult == 0) {
        return node;
      } else if (comparisonResult < 0) {
        node = node.left;
      } else {
        node = node.right;
      }
    }
    return node;
  }

  Value? lookupValue(Key key) {
    final _Node<Key, Value>? node = lookup(key);
    return node?.value;
  }

  void insert(Key key, Value value) {
    final _Node<Key, Value> insertedNode =
        _Node.newNode(key, value, _Color.red, null, null);
    final root = _root;
    if (root == null) {
      _root = insertedNode;
    } else {
      _Node<Key, Value> n = root;
      while (true) {
        var comparisonResult = key.compareTo(n.key);
        if (comparisonResult == 0) {
          n.value = value;
          return;
        } else if (comparisonResult < 0) {
          final _Node<Key, Value>? l = n.left;
          if (l == null) {
            n.left = insertedNode;
            break;
          } else {
            n = l;
          }
        } else {
          final _Node<Key, Value>? r = n.right;
          if (r == null) {
            n.right = insertedNode;
            break;
          } else {
            n = r;
          }
        }
      }
      insertedNode.parent = n;
    }
    _insertCase1(insertedNode);
  }

  void _insertCase1(_Node<Key, Value> n) {
    if (n.parent == null) {
      n.color = _Color.black;
    } else {
      _insertCase2(n);
    }
  }

  void _insertCase2(_Node<Key, Value> n) {
    if (_getColor(n.parent) == _Color.black) {
      return;
    } else {
      _insertCase3(n);
    }
  }

  void _insertCase3(_Node<Key, Value> n) {
    if (_getColor(n.uncle) == _Color.red) {
      n.parent!.color = _Color.black;
      n.uncle!.color = _Color.black;
      n.grandparent.color = _Color.red;
      _insertCase1(n.grandparent);
    } else {
      _insertCase4(n);
    }
  }

  void _insertCase4(_Node<Key, Value> n) {
    if (n == n.parent!.right && n.parent == n.grandparent.left) {
      _rotateLeft(n.parent!);
      n = n.left!;
    } else if (n == n.parent!.left && n.parent == n.grandparent.right) {
      _rotateRight(n.parent!);
      n = n.right!;
    }
    _insertCase5(n);
  }

  void _insertCase5(_Node<Key, Value> n) {
    n.parent!.color = _Color.black;
    n.grandparent.color = _Color.red;
    if (n == n.parent!.left && n.parent == n.grandparent.left) {
      _rotateRight(n.grandparent);
    } else {
      _rotateLeft(n.grandparent);
    }
  }

  _Color _getColor(_Node<Key, Value>? n) => n == null ? _Color.black : n.color;

  void _rotateLeft(_Node<Key, Value> n) {
    final r = n.right;
    _replaceNode(n, r);
    n.right = r?.left;
    r?.left?.parent = n;
    r?.left = n;
    n.parent = r;
  }

  void _rotateRight(_Node<Key, Value> n) {
    final l = n.left;
    _replaceNode(n, l);
    n.left = l?.right;
    l?.right?.parent = n;
    l?.right = n;
    n.parent = l;
  }

  void _replaceNode(_Node<Key, Value> oldN, _Node<Key, Value>? newN) {
    var oldNParent = oldN.parent;
    if (oldNParent == null) {
      _root = newN;
    } else {
      if (oldN == oldNParent.left) {
        oldNParent.left = newN;
      } else {
        oldNParent.right = newN;
      }
    }
    newN?.parent = oldNParent;
  }
}

class _KeysIterable<Key extends Comparable, Value>
    extends IterableBase<Key> {
  final RedBlackTree<Key, Value> _tree;

  _KeysIterable(this._tree);

  @override
  Iterator<Key> get iterator => _RedBlackTreeKeysIterator(_tree);
}

class _RedBlackTreeKeysIterator<Key extends Comparable, Value> implements Iterator<Key> {
  final RedBlackTree<Key, Value> _tree;
  _Node<Key, Value>? _current = null;
  Stack<_Node<Key, Value>> _stack = Stack();

  _RedBlackTreeKeysIterator(this._tree) {
    _Node<Key, Value>? n = _tree._root;
    while (n != null) {
      _stack.push(n);
      n = n.left;
    }
  }

  @override
  Key get current => _current?.key as Key;

  @override
  bool moveNext() {
    if (_stack.isEmpty)
      return false;

    _Node<Key, Value>? n = _stack.pop();
    _current = n;
    if (n.right != null) {
      n = n.right;
      while (n != null) {
        _stack.push(n);
        n = n.left;
      }
    }
    return true;
  }
}