import 'package:flutter/foundation.dart';

import '../../../models/conversion_enums.dart';
import '../../../models/tool_detection_result.dart';
import '../../../models/tool_paths_settings.dart';
import '../../../services/app_settings_service.dart';
import '../../../services/tool_detection_service.dart';

class ToolPathsController extends ChangeNotifier {
  ToolPathsController({
    required this._settingsService,
    required this._toolDetectionService,
  });

  final AppSettingsService _settingsService;
  final ToolDetectionService _toolDetectionService;

  ToolPathsSettings _settings = const ToolPathsSettings();
  ToolDetectionResult _detectionResult = const ToolDetectionResult();
  ExecutableValidationResult _ffmpegValidation = const ExecutableValidationResult(
    status: ToolValidationStatus.unknown,
  );
  ExecutableValidationResult _ffprobeValidation = const ExecutableValidationResult(
    status: ToolValidationStatus.unknown,
  );
  bool _isLoading = true;

  ToolPathsSettings get settings => _settings;
  ToolDetectionResult get detectionResult => _detectionResult;
  ExecutableValidationResult get ffmpegValidation => _ffmpegValidation;
  ExecutableValidationResult get ffprobeValidation => _ffprobeValidation;
  bool get isLoading => _isLoading;

  String? get effectiveFfmpegPath =>
      _toolDetectionService.effectiveFfmpegPath(_settings, _detectionResult);

  String? get effectiveFfprobePath =>
      _toolDetectionService.effectiveFfprobePath(_settings, _detectionResult);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _settingsService.loadToolPathsSettings();
    _detectionResult = await _toolDetectionService.detectTools();
    await _refreshValidation();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateManualFfmpegPath(String value) async {
    _settings = _settings.copyWith(manualFfmpegPath: value);
    notifyListeners();
    await _persistAndRefresh();
  }

  Future<void> updateManualFfprobePath(String value) async {
    _settings = _settings.copyWith(manualFfprobePath: value);
    notifyListeners();
    await _persistAndRefresh();
  }

  Future<void> clearManualFfmpegPath() async {
    _settings = _settings.copyWith(clearManualFfmpegPath: true);
    notifyListeners();
    await _persistAndRefresh();
  }

  Future<void> clearManualFfprobePath() async {
    _settings = _settings.copyWith(clearManualFfprobePath: true);
    notifyListeners();
    await _persistAndRefresh();
  }

  Future<void> redetectTools() async {
    _detectionResult = await _toolDetectionService.detectTools();
    await _refreshValidation();
    notifyListeners();
  }

  Future<void> _persistAndRefresh() async {
    await _settingsService.saveToolPathsSettings(_settings);
    await _refreshValidation();
    notifyListeners();
  }

  Future<void> _refreshValidation() async {
    _ffmpegValidation = await _toolDetectionService.validateExecutable(
      effectiveFfmpegPath,
    );
    _ffprobeValidation = await _toolDetectionService.validateExecutable(
      effectiveFfprobePath,
    );
  }
}
