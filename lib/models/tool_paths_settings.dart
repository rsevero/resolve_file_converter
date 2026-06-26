class ToolPathsSettings {
  const ToolPathsSettings({
    this.manualFfmpegPath,
    this.manualFfprobePath,
  });

  final String? manualFfmpegPath;
  final String? manualFfprobePath;

  String? effectiveFfmpegPath(String? detectedPath) =>
      _normalize(manualFfmpegPath) ?? _normalize(detectedPath);

  String? effectiveFfprobePath(String? detectedPath) =>
      _normalize(manualFfprobePath) ?? _normalize(detectedPath);

  ToolPathsSettings copyWith({
    String? manualFfmpegPath,
    String? manualFfprobePath,
    bool clearManualFfmpegPath = false,
    bool clearManualFfprobePath = false,
  }) {
    return ToolPathsSettings(
      manualFfmpegPath:
          clearManualFfmpegPath ? null : (manualFfmpegPath ?? this.manualFfmpegPath),
      manualFfprobePath:
          clearManualFfprobePath ? null : (manualFfprobePath ?? this.manualFfprobePath),
    );
  }

  static String? _normalize(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
