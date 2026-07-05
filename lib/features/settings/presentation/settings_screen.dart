import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/enums.dart';
import '../../../providers/settings_providers.dart';

// Settings tab. Bottom nav is provided by the router shell, so no nav here.
// Relies on sharedPreferencesProvider being overridden at bootstrap.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _baseUrlController;

  @override
  void initState() {
    super.initState();
    _baseUrlController =
        TextEditingController(text: ref.read(appSettingsProvider).baseUrl);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  void _submitBaseUrl(String value) =>
      ref.read(appSettingsProvider.notifier).updateBaseUrl(value.trim());

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding,
          120.0,
        ),
        children: [
          const _Label('Backend API URL'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _baseUrlController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'https://api.songketai.dev/v1',
            ),
            onEditingComplete: () => _submitBaseUrl(_baseUrlController.text),
            onSubmitted: _submitBaseUrl,
          ),
          const Divider(height: AppSpacing.xl),
          const _Label('Resolusi Gambar'),
          const SizedBox(height: AppSpacing.sm),
          DropdownButton<Resolution>(
            isExpanded: true,
            value: settings.defaultResolution,
            items: const [
              DropdownMenuItem(value: Resolution.px64, child: Text('64×64')),
              DropdownMenuItem(value: Resolution.px128, child: Text('128×128')),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(appSettingsProvider.notifier).updateResolution(value);
              }
            },
          ),
          const Divider(height: AppSpacing.xl),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark Mode', style: AppTypography.bodyMedium),
            subtitle: Text(
              'Aktifkan tema gelap',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.gray),
            ),
            value: settings.isDarkMode,
            onChanged: (value) =>
                ref.read(appSettingsProvider.notifier).updateThemeMode(value),
          ),
          const Divider(height: AppSpacing.xl),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Versi Aplikasi', style: AppTypography.bodyMedium),
            trailing: Text(
              'v${AppConstants.appVersion}',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.gray),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      );
}
