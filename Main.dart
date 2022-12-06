import 'dart:io';

void main() async {
  final input = File("input");
  final file = await input.open();
  try {
    if (file.lengthSync() < 4) {
      print("File to short.");
      return;
    }

    int packetBeginning = await findBeginning(file, 4);
    int messageBeginning = await findBeginning(file, 14) + packetBeginning;

    print(messageBeginning);
  } catch (e) {
    print("Error: $e");
  } finally {
    file.closeSync();
  }
}

Future<int> findBeginning(RandomAccessFile file, int beginningLength) async {
  assert(beginningLength > 0);

  final buffer = <int>[];
  buffer.addAll(await file.read(beginningLength - 1));
  
  int i = beginningLength - 1;
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
  return i;
}