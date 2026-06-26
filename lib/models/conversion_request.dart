import 'conversion_enums.dart';

class ConversionRequest {
  const ConversionRequest({
    required this.sourcePath,
    required this.sourceType,
    required this.outputMode,
    required this.ffmpegPath,
    required this.ffprobePath,
    this.startTime,
    this.endTime,
  });

  final String sourcePath;
  final SourceType sourceType;
  final OutputMode outputMode;
  final Duration? startTime;
  final Duration? endTime;
  final String ffmpegPath;
  final String ffprobePath;
}
