import 'dart:io';

import 'package:path/path.dart' as path;

import '../models/conversion_enums.dart';

class OutputPathService {
  const OutputPathService();

  Future<String> buildDestinationPath({
    required String sourcePath,
    required MediaKind mediaKind,
    required OutputMode outputMode,
    Duration? startTime,
    Duration? endTime,
  }) async {
    final extension = mediaKind == MediaKind.video ? '.mxf' : '.wav';
    final sourceDirectory = path.dirname(sourcePath);
    final baseName = path.basenameWithoutExtension(sourcePath);
    final trimmedBaseName = '$baseName${_trimSuffix(startTime: startTime, endTime: endTime)}';

    final rawPath = switch (outputMode) {
      OutputMode.sameFolderSuffix =>
        path.join(sourceDirectory, '$trimmedBaseName-for_resolve$extension'),
      OutputMode.resolveSubdirectory => path.join(
          sourceDirectory,
          'for_resolve',
          '$trimmedBaseName$extension',
        ),
    };

    if (outputMode == OutputMode.resolveSubdirectory) {
      await Directory(path.dirname(rawPath)).create(recursive: true);
    }

    return _ensureUniquePath(rawPath);
  }

  String _trimSuffix({
    Duration? startTime,
    Duration? endTime,
  }) {
    if (startTime == null && endTime == null) {
      return '';
    }

    if (startTime != null && endTime != null) {
      return '-trim-${_formatDurationForFileName(startTime)}-to-${_formatDurationForFileName(endTime)}';
    }

    if (startTime != null) {
      return '-trim-from-${_formatDurationForFileName(startTime)}';
    }

    return '-trim-to-${_formatDurationForFileName(endTime!)}';
  }

  String _formatDurationForFileName(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '${hours}h${minutes}m${seconds}s${milliseconds}ms';
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
