import 'dart:io';

void main() async {
  final input = File("input");
  final file = await input.open();
  try {
    if (file.lengthSync() < 4) {
      print("File to short.");
      return;
    }

    final buffer = <int>[];
    buffer.addAll(await file.read(3));

    int i = 3;
    int b;
    int removed;
    final notUniqueElements = <int>[];
    while ((b = file.readByteSync()) >= 0) {
      ++i;
      if (buffer.contains(b)) {
        notUniqueElements.add(b);
      }
      buffer.add(b);
      if (notUniqueElements.isEmpty) {
        break;
      } else {
        removed = buffer.removeAt(0);
        notUniqueElements.remove(removed);
      }
    }

    print(i);
  } catch (e) {
    print("Error: $e");
  } finally {
    file.closeSync();
  }
}