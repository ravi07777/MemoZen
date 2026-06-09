import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeIndex = ref.watch(selectedThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Profile section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Learner',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'learner@memozen.app',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Menu items
            _buildMenuItem(
              theme,
              icon: Icons.notifications_outlined,
              title: 'Notification Reminder',
              onTap: () {},
            ),
            _buildMenuItem(
              theme,
              icon: Icons.language_outlined,
              title: 'Language',
              onTap: () {},
              trailing: const Text('English'),
            ),
            _buildMenuItem(
              theme,
              icon: Icons.palette_outlined,
              title: 'Theme',
              onTap: () => _showThemeSheet(context, ref, themeIndex, themeMode),
              trailing: Text(
                allThemes[themeIndex].name,
                style: TextStyle(color: allThemes[themeIndex].primary),
              ),
            ),
            const Divider(height: 32),
            _buildMenuItem(
              theme,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildMenuItem(
              theme,
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {},
              trailing: Text(AppConstants.appVersion),
            ),
            const Divider(height: 32),
            _buildMenuItem(
              theme,
              icon: Icons.download_outlined,
              title: 'Export Backup',
              onTap: () {},
            ),
            _buildMenuItem(
              theme,
              icon: Icons.upload_outlined,
              title: 'Import Backup',
              onTap: () {},
            ),
            const Divider(height: 32),
            _buildMenuItem(
              theme,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {},
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (textColor ?? theme.colorScheme.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: textColor ?? theme.colorScheme.primary),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref, int selected, ThemeMode mode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Theme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Select your preferred color theme',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
              ),
              const SizedBox(height: 20),
              ...allThemes.asMap().entries.map(
                    (entry) => _buildThemeOption(ctx, ref, entry.key, entry.value, selected),
                  ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Theme Mode',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildModeChip(context, ref, 'Light', ThemeMode.light, mode),
                  const SizedBox(width: 8),
                  _buildModeChip(context, ref, 'Dark', ThemeMode.dark, mode),
                  const SizedBox(width: 8),
                  _buildModeChip(context, ref, 'Auto', ThemeMode.system, mode),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, WidgetRef ref, int index, AppColorTheme themeOption, int selected) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: () {
        ref.read(selectedThemeProvider.notifier).select(index);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? themeOption.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? themeOption.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [themeOption.primary, themeOption.secondary],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              themeOption.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: themeOption.primary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip(BuildContext context, WidgetRef ref, String label, ThemeMode mode, ThemeMode current) {
    final isSelected = mode == current;
    return GestureDetector(
      onTap: () {
        ref.read(themeModeProvider.notifier).setMode(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
