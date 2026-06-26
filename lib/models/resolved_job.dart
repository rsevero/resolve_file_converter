import 'conversion_enums.dart';

class ResolvedJob {
  const ResolvedJob({
    required this.sourcePath,
    required this.destinationPath,
    required this.mediaKind,
    required this.arguments,
  });

  final String sourcePath;
  final String destinationPath;
  final MediaKind mediaKind;
  final List<String> arguments;
}
