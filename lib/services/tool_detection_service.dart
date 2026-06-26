import 'dart:io';

import 'package:path/path.dart' as path;

import '../models/conversion_enums.dart';
import '../models/tool_detection_result.dart';
import '../models/tool_paths_settings.dart';

class ToolDetectionService {
  const ToolDetectionService();

  Future<ToolDetectionResult> detectTools() async {
    final detectedFfmpegPath = await _detectTool('ffmpeg');
    final detectedFfprobePath = await _detectTool('ffprobe');

    return ToolDetectionResult(
      detectedFfmpegPath: detectedFfmpegPath,
      detectedFfprobePath: detectedFfprobePath,
    );
  }

  Future<ExecutableValidationResult> validateExecutable(
    String? executablePath,
  ) async {
    final normalizedPath = executablePath?.trim();

    if (normalizedPath == null || normalizedPath.isEmpty) {
      return const ExecutableValidationResult(
        status: ToolValidationStatus.invalid,
        message: 'Path is required.',
      );
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      return const ExecutableValidationResult(
        status: ToolValidationStatus.invalid,
        message: 'The executable does not exist.',
      );
    }

    try {
      final result = await Process.run(
        normalizedPath,
        const ['-version'],
        runInShell: Platform.isWindows,
      );

      if (result.exitCode != 0) {
        return ExecutableValidationResult(
          status: ToolValidationStatus.invalid,
          message: _errorText(result),
        );
      }

      final versionLine = _firstLine(result.stdout);
      return ExecutableValidationResult(
        status: ToolValidationStatus.valid,
        versionLine: versionLine,
      );
    } on ProcessException catch (error) {
      return ExecutableValidationResult(
        status: ToolValidationStatus.invalid,
        message: error.message,
      );
    }
  }

  String? effectiveFfmpegPath(
    ToolPathsSettings settings,
    ToolDetectionResult detectionResult,
  ) {
    return settings.effectiveFfmpegPath(detectionResult.detectedFfmpegPath);
  }

  String? effectiveFfprobePath(
    ToolPathsSettings settings,
    ToolDetectionResult detectionResult,
  ) {
    return settings.effectiveFfprobePath(detectionResult.detectedFfprobePath);
  }

  Future<String?> _detectTool(String toolName) async {
    final command = Platform.isWindows ? 'where' : 'which';
    try {
      final pathLookupResult = await Process.run(command, [toolName]);
      if (pathLookupResult.exitCode == 0) {
        final discoveredPath = _firstLine(pathLookupResult.stdout);
        if (discoveredPath != null && discoveredPath.isNotEmpty) {
          return discoveredPath;
        }
      }
    } on ProcessException {
      // Fall back to common install locations below.
    }

    for (final candidate in _fallbackCandidates(toolName)) {
      if (await File(candidate).exists()) {
        return candidate;
      }
    }

    return null;
  }

  Iterable<String> _fallbackCandidates(String toolName) sync* {
    final binaryName = Platform.isWindows ? '$toolName.exe' : toolName;

    if (Platform.isMacOS || Platform.isLinux) {
      yield '/usr/local/bin/$binaryName';
      yield '/usr/bin/$binaryName';
      yield '/opt/homebrew/bin/$binaryName';
    }

    if (Platform.isWindows) {
      final programFiles = Platform.environment['ProgramFiles'];
      final localAppData = Platform.environment['LOCALAPPDATA'];

      if (programFiles != null) {
        yield path.join(programFiles, 'ffmpeg', 'bin', binaryName);
      }

      if (localAppData != null) {
        yield path.join(localAppData, 'Microsoft', 'WinGet', 'Links', binaryName);
      }
    }
  }

  String? _firstLine(Object? output) {
    final lines = output
        .toString()
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    return lines.isEmpty ? null : lines.first;
  }

  String _errorText(ProcessResult result) {
    final stderrLine = _firstLine(result.stderr);
    if (stderrLine != null) {
      return stderrLine;
    }

    return 'The executable exited with code ${result.exitCode}.';
  }
}
