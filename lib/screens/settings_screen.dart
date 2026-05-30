import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_text_styles.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ListView(
            children: [
              const SizedBox(height: 16),

              // Theme section
              _buildSectionHeader(context, '外观'),
              _buildThemeTile(context, themeProvider),

              const Divider(height: 32),

              // About section
              _buildSectionHeader(context, '关于'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('版本', style: AppTextStyles.body),
                subtitle: const Text('1.0.0', style: AppTextStyles.caption),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('技术栈', style: AppTextStyles.body),
                subtitle: const Text(
                  'Flutter + Provider + SQLite',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: AppTextStyles.h3.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('主题模式', style: AppTextStyles.body),
      subtitle: Text(themeProvider.themeModeName, style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, themeProvider),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              themeProvider,
              ThemeMode.system,
              '跟随系统',
              Icons.phone_android,
            ),
            _buildThemeOption(
              context,
              themeProvider,
              ThemeMode.light,
              '浅色模式',
              Icons.light_mode,
            ),
            _buildThemeOption(
              context,
              themeProvider,
              ThemeMode.dark,
              '深色模式',
              Icons.dark_mode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    String title,
    IconData icon,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
