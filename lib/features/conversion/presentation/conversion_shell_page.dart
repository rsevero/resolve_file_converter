import 'package:flutter/material.dart';

import '../../../models/conversion_enums.dart';
import '../../../models/tool_detection_result.dart';
import '../../../services/app_settings_service.dart';
import '../../../services/tool_detection_service.dart';
import '../../settings/application/tool_paths_controller.dart';

class ConversionShellPage extends StatefulWidget {
  const ConversionShellPage({super.key});

  @override
  State<ConversionShellPage> createState() => _ConversionShellPageState();
}

class _ConversionShellPageState extends State<ConversionShellPage> {
  late final ToolPathsController _toolPathsController;
  late final TextEditingController _ffmpegTextController;
  late final TextEditingController _ffprobeTextController;

  @override
  void initState() {
    super.initState();
    _ffmpegTextController = TextEditingController();
    _ffprobeTextController = TextEditingController();
    _toolPathsController = ToolPathsController(
      settingsService: AppSettingsService(),
      toolDetectionService: const ToolDetectionService(),
    )..addListener(_syncTextControllers);

    _toolPathsController.load();
  }

  @override
  void dispose() {
    _toolPathsController
      ..removeListener(_syncTextControllers)
      ..dispose();
    _ffmpegTextController.dispose();
    _ffprobeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _toolPathsController,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderBanner(isLoading: _toolPathsController.isLoading),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          SizedBox(
                            width: 520,
                            child: _WorkflowCard(
                              title: 'Conversion workflow',
                              description:
                                  'Steps 1 to 4 prepare the shell, models, settings, '
                                  'and tool detection layer before we add file picking '
                                  'and actual transcoding.',
                              bullets: const [
                                'Single file or top-level directory input',
                                'Resolve-safe WAV and DNxHR output targets',
                                'Optional trim support planned next',
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 520,
                            child: _ToolPathsCard(
                              controller: _toolPathsController,
                              ffmpegTextController: _ffmpegTextController,
                              ffprobeTextController: _ffprobeTextController,
                            ),
                          ),
                          SizedBox(
                            width: 520,
                            child: const _WorkflowCard(
                              title: 'What is ready now',
                              description:
                                  'The app can persist manual tool paths, re-detect '
                                  'system tools, and validate the effective ffmpeg '
                                  'and ffprobe executables independently.',
                              bullets: [
                                'Separate ffmpeg and ffprobe overrides',
                                'Override takes precedence over detected path',
                                'Validation runs against the effective tool path',
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 520,
                            child: const _WorkflowCard(
                              title: 'Next implementation block',
                              description:
                                  'The next steps will add source pickers, output '
                                  'mode selection, trim validation, and directory scanning.',
                              bullets: [
                                'File and directory selection',
                                'Output naming preview',
                                'Top-level directory scan service',
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _syncTextControllers() {
    final ffmpegPath = _toolPathsController.settings.manualFfmpegPath ?? '';
    final ffprobePath = _toolPathsController.settings.manualFfprobePath ?? '';

    if (_ffmpegTextController.text != ffmpegPath) {
      _ffmpegTextController.value = _ffmpegTextController.value.copyWith(
        text: ffmpegPath,
        selection: TextSelection.collapsed(offset: ffmpegPath.length),
      );
    }

    if (_ffprobeTextController.text != ffprobePath) {
      _ffprobeTextController.value = _ffprobeTextController.value.copyWith(
        text: ffprobePath,
        selection: TextSelection.collapsed(offset: ffprobePath.length),
      );
    }
  }
}

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E3B43), Color(0xFF176A75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resolve Media Converter',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Desktop shell ready for Steps 1 to 4: structure, models, '
            'settings persistence, and ffmpeg / ffprobe detection.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                isLoading ? Icons.sync : Icons.check_circle,
                color: const Color(0xFFF4C95D),
              ),
              const SizedBox(width: 10),
              Text(
                isLoading ? 'Checking tools and stored settings...' : 'Ready for the next implementation block',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard({
    required this.title,
    required this.description,
    required this.bullets,
  });

  final String title;
  final String description;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(description, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            for (final bullet in bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(Icons.fiber_manual_record, size: 10),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(bullet)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolPathsCard extends StatelessWidget {
  const _ToolPathsCard({
    required this.controller,
    required this.ffmpegTextController,
    required this.ffprobeTextController,
  });

  final ToolPathsController controller;
  final TextEditingController ffmpegTextController;
  final TextEditingController ffprobeTextController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tool paths',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: controller.isLoading ? null : controller.redetectTools,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Re-detect'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Auto-detection is available, but the user can always override '
              'ffmpeg and ffprobe independently.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _ToolField(
              label: 'FFmpeg',
              detectedPath: controller.detectionResult.detectedFfmpegPath,
              effectivePath: controller.effectiveFfmpegPath,
              validation: controller.ffmpegValidation,
              controller: ffmpegTextController,
              onChanged: controller.updateManualFfmpegPath,
              onClear: controller.clearManualFfmpegPath,
            ),
            const SizedBox(height: 18),
            _ToolField(
              label: 'FFprobe',
              detectedPath: controller.detectionResult.detectedFfprobePath,
              effectivePath: controller.effectiveFfprobePath,
              validation: controller.ffprobeValidation,
              controller: ffprobeTextController,
              onChanged: controller.updateManualFfprobePath,
              onClear: controller.clearManualFfprobePath,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolField extends StatelessWidget {
  const _ToolField({
    required this.label,
    required this.detectedPath,
    required this.effectivePath,
    required this.validation,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final String label;
  final String? detectedPath;
  final String? effectivePath;
  final ExecutableValidationResult validation;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (validation.status) {
      ToolValidationStatus.valid => const Color(0xFF1F7A4C),
      ToolValidationStatus.invalid => const Color(0xFF9B2C2C),
      ToolValidationStatus.unknown => theme.colorScheme.secondary,
    };

    final statusLabel = switch (validation.status) {
      ToolValidationStatus.valid => 'Validated',
      ToolValidationStatus.invalid => 'Needs attention',
      ToolValidationStatus.unknown => 'Not checked yet',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusLabel,
                style: theme.textTheme.labelLarge?.copyWith(color: statusColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Detected path: ${detectedPath ?? 'Not found on system path'}',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'Manual override',
            hintText: 'Leave empty to use auto-detection',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: controller.text.isEmpty ? null : onClear,
              icon: const Icon(Icons.close),
              tooltip: 'Clear override',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Effective path: ${effectivePath ?? 'No executable available'}',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (validation.versionLine != null) ...[
          const SizedBox(height: 6),
          Text(validation.versionLine as String, style: theme.textTheme.bodySmall),
        ],
        if (validation.message != null) ...[
          const SizedBox(height: 6),
          Text(
            validation.message as String,
            style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
          ),
        ],
      ],
    );
  }
}
