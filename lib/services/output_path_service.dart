import 'dart:io';

import 'package:path/path.dart' as path;

import '../models/conversion_enums.dart';

class OutputPathService {
  const OutputPathService();

  Future<String> buildDestinationPath({
    required String sourcePath,
    required MediaKind mediaKind,
    required OutputMode outputMode,
  }) async {
    final extension = mediaKind == MediaKind.video ? '.mov' : '.wav';
    final sourceDirectory = path.dirname(sourcePath);
    final baseName = path.basenameWithoutExtension(sourcePath);

    final rawPath = switch (outputMode) {
      OutputMode.sameFolderSuffix =>
        path.join(sourceDirectory, '$baseName-for_resolve$extension'),
      OutputMode.resolveSubdirectory => path.join(
          sourceDirectory,
          'for_resolve',
          '$baseName$extension',
        ),
    };

    if (outputMode == OutputMode.resolveSubdirectory) {
      await Directory(path.dirname(rawPath)).create(recursive: true);
    }

    return _ensureUniquePath(rawPath);
  }

  Future<String> _ensureUniquePath(String candidatePath) async {
    final file = File(candidatePath);
    if (!await file.exists()) {
      return candidatePath;
    }

    final directory = path.dirname(candidatePath);
    final extension = path.extension(candidatePath);
    final baseName = path.basenameWithoutExtension(candidatePath);

    var counter = 1;
    while (true) {
      final numberedPath = path.join(directory, '$baseName-$counter$extension');
      if (!await File(numberedPath).exists()) {
        return numberedPath;
      }
      counter++;
    }
  }
}
