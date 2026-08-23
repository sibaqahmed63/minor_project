// lib/presentation/views/settings/settings_placeholder.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/theme_provider.dart';

class SettingsPlaceholder extends ConsumerWidget {
  const SettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTheme = ref.watch(themeModeProvider);
    final isDark = (asyncTheme.asData?.value ?? AppThemeMode.light) == AppThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(isDark ? 'Dark' : 'Light'),
              trailing: Switch(
                value: isDark,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Other settings will appear here', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
