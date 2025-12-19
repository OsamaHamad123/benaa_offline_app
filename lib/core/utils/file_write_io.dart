import 'dart:io';

Future<void> writeBytesToPath(String path, List<int> bytes) {
  return File(path).writeAsBytes(bytes, flush: true);
}
