import 'package:flutter/material.dart';
import 'package:geopin/i18n/app_localizations_extension.dart';
import 'package:go_router/go_router.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  /// 构造函数
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
      ),
      body: ListView(
        children: [
          // 语言设置
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.l10n.language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.go('/language-settings');
            },
          ),
          
          // 分隔线
          const Divider(),
          
          // 主题设置（未实现）
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(context.l10n.theme),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: 实现主题设置页面
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.themeSettingDevelopment)),
              );
            },
          ),
          
          // 分隔线
          const Divider(),
          
          // 应用信息
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(context.l10n.aboutApp),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: context.l10n.appTitle,
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 48),
                children: [
                  Text(context.l10n.appDescription),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
} 