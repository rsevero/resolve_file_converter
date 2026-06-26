import 'conversion_enums.dart';

class ConversionResult {
  const ConversionResult({
    required this.sourcePath,
    required this.destinationPath,
    required this.status,
    this.errorMessage,
    this.elapsed,
  });

  final String sourcePath;
  final String destinationPath;
  final ConversionStatus status;
  final String? errorMessage;
  final Duration? elapsed;
}
