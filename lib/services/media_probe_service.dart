import 'dart:convert';
import 'dart:io';

import '../models/conversion_enums.dart';
import '../models/media_probe_result.dart';

class MediaProbeService {
  const MediaProbeService();

  Future<MediaProbeResult> probe({
    required String ffprobePath,
    required String sourcePath,
  }) async {
    try {
      final result = await Process.run(ffprobePath, [
        '-v',
        'error',
        '-show_entries',
        'stream=codec_type,width,height,channels,sample_rate',
        '-of',
        'json',
        sourcePath,
      ], runInShell: Platform.isWindows);

      if (result.exitCode != 0) {
        return MediaProbeResult(
          sourcePath: sourcePath,
          mediaKind: MediaKind.unsupported,
          errorMessage: _firstLine(result.stderr) ?? 'ffprobe failed.',
        );
      }

      return parseProbeOutput(sourcePath: sourcePath, jsonOutput: result.stdout.toString());
    } on ProcessException catch (error) {
      return MediaProbeResult(
        sourcePath: sourcePath,
        mediaKind: MediaKind.unsupported,
        errorMessage: error.message,
      );
    } on FormatException catch (error) {
      return MediaProbeResult(
        sourcePath: sourcePath,
        mediaKind: MediaKind.unsupported,
        errorMessage: error.message,
      );
    }
  }

  MediaProbeResult parseProbeOutput({
    required String sourcePath,
    required String jsonOutput,
  }) {
    final decoded = jsonDecode(jsonOutput) as Map<String, dynamic>;
    final streams = (decoded['streams'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final hasVideo = streams.any((stream) => stream['codec_type'] == 'video');
    final hasAudio = streams.any((stream) => stream['codec_type'] == 'audio');

    final mediaKind = hasVideo
        ? MediaKind.video
        : hasAudio
            ? MediaKind.audio
            : MediaKind.unsupported;

    return MediaProbeResult(
      sourcePath: sourcePath,
      mediaKind: mediaKind,
      details: {
        'streamCount': streams.length,
        'hasAudio': hasAudio,
        'hasVideo': hasVideo,
      },
      errorMessage:
          mediaKind == MediaKind.unsupported ? 'No audio or video stream found.' : null,
    );
  }

  String? _firstLine(Object? value) {
    return value
        .toString()
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .firstWhere(
          (line) => line.isNotEmpty,
          orElse: () => '',
        )
        .ifEmptyToNull();
  }
}

extension on String {
  String? ifEmptyToNull() => isEmpty ? null : this;
}
