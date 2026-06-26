import 'package:shared_preferences/shared_preferences.dart';

import '../models/tool_paths_settings.dart';

class AppSettingsService {
  static const _ffmpegPathKey = 'tool_paths.ffmpeg';
  static const _ffprobePathKey = 'tool_paths.ffprobe';

  Future<ToolPathsSettings> loadToolPathsSettings() async {
    final preferences = await SharedPreferences.getInstance();
    return ToolPathsSettings(
      manualFfmpegPath: preferences.getString(_ffmpegPathKey),
      manualFfprobePath: preferences.getString(_ffprobePathKey),
    );
  }

  Future<void> saveToolPathsSettings(ToolPathsSettings settings) async {
    final preferences = await SharedPreferences.getInstance();

    final ffmpegPath = settings.manualFfmpegPath?.trim();
    final ffprobePath = settings.manualFfprobePath?.trim();

    if (ffmpegPath == null || ffmpegPath.isEmpty) {
      await preferences.remove(_ffmpegPathKey);
    } else {
      await preferences.setString(_ffmpegPathKey, ffmpegPath);
    }

    if (ffprobePath == null || ffprobePath.isEmpty) {
      await preferences.remove(_ffprobePathKey);
    } else {
      await preferences.setString(_ffprobePathKey, ffprobePath);
    }
  }
}
