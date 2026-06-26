class SourceResolutionResult {
  const SourceResolutionResult({
    required this.candidatePaths,
    required this.skippedPaths,
  });

  final List<String> candidatePaths;
  final List<String> skippedPaths;
}
