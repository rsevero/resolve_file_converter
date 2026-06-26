import 'dart:io';

import '../models/conversion_enums.dart';
import '../models/source_resolution_result.dart';

class SourceResolutionService {
  const SourceResolutionService();

  Future<SourceResolutionResult> resolve({
    required String sourcePath,
    required SourceType sourceType,
  }) async {
    if (sourceType == SourceType.file) {
      final file = File(sourcePath);
      if (await file.exists()) {
        return SourceResolutionResult(
          candidatePaths: [file.path],
          skippedPaths: const [],
        );
      }

      return SourceResolutionResult(
        candidatePaths: const [],
        skippedPaths: [sourcePath],
      );
    }

    final directory = Directory(sourcePath);
    if (!await directory.exists()) {
      return SourceResolutionResult(
        candidatePaths: const [],
        skippedPaths: [sourcePath],
      );
    }

    final candidatePaths = <String>[];
    final skippedPaths = <String>[];

    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File) {
        candidatePaths.add(entity.path);
      } else {
        skippedPaths.add(entity.path);
      }
    }

    candidatePaths.sort();
    skippedPaths.sort();

    return SourceResolutionResult(
      candidatePaths: candidatePaths,
      skippedPaths: skippedPaths,
    );
  }
}
