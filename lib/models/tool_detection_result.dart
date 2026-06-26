import 'conversion_enums.dart';

class ToolDetectionResult {
  const ToolDetectionResult({
    this.detectedFfmpegPath,
    this.detectedFfprobePath,
  });

  final String? detectedFfmpegPath;
  final String? detectedFfprobePath;
}

class ExecutableValidationResult {
  const ExecutableValidationResult({
    required this.status,
    this.message,
    this.versionLine,
  });

  final ToolValidationStatus status;
  final String? message;
  final String? versionLine;

  bool get isValid => status == ToolValidationStatus.valid;
}
