import 'dart:io';
import 'dart:math';

import '../BaseDay.dart';

class Day06 extends BaseDay {
  @override
  int number = 6;
  @override
  String name = "Tuning Trouble";

  File get _input => File(defaultInputPath);

  final _PACKET_BEGINNING_MARKER_LENGTH = 4;
  final _MESSAGE_BEGINNING_MARKER_LENGTH = 14;

  @override
  String partOne({bool withDebugPrint = false}) {
    final operations = (file) => _findMarkerStart(file, _PACKET_BEGINNING_MARKER_LENGTH);
    return _findBeginning(operations).toString();
  }

  @override
  String partTwo({bool withDebugPrint = false}) {
    final operations = (file) =>
        _findMarkerStart(file, _PACKET_BEGINNING_MARKER_LENGTH) +
        _findMarkerStart(file, _MESSAGE_BEGINNING_MARKER_LENGTH);
    return _findBeginning(operations).toString();
  }

  int _findBeginning(int Function(RandomAccessFile file) operations) {
    final file = _input.openSync();
    try {
      if (file.lengthSync() < max(_PACKET_BEGINNING_MARKER_LENGTH, _MESSAGE_BEGINNING_MARKER_LENGTH))
        throw AssertionError("File is too short.");

      return operations(file);
    } finally {
      file.closeSync();
    }
  }

  int _findMarkerStart(RandomAccessFile file, int markerLength) {
    assert(markerLength > 0);

    int i = markerLength - 1;

    final buffer = <int>[];
    buffer.addAll(file.readSync(i));

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
}