class Stack<T> {
  final List<T> _stack = List.empty(growable: true);
  bool get isEmpty => _stack.isEmpty;

  void push(T element) {
    _stack.add(element);
  }

  T pop() {
    if (_stack.isEmpty) {
      throw StateError("Nothing to pop. Stack is empty.");
    } else {
      return _stack.removeLast();
    }
  }

  T peek() {
    if (_stack.isEmpty) {
      throw StateError("Nothing to pop. Stack is empty.");
    } else {
      return _stack.last;
    }
  }
}