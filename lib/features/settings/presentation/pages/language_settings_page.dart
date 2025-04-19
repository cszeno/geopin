import 'package:flutter/material.dart';
import 'package:geopin/i18n/app_localizations_extension.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/providers/locale_provider.dart';

/// 语言设置页面
class LanguageSettingsPage extends StatelessWidget {
  /// 构造函数
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.language),
      ),
      body: Column(
        children: [
          RadioListTile<String?>(
            title: Text(context.l10n.systemDefault),
            value: null,
            groupValue: currentLocale,
            onChanged: (_) => localeProvider.setSystemLocale(),
          ),
          RadioListTile<String>(
            title: Text(context.l10n.chinese),
            value: 'zh',
            groupValue: currentLocale,
            onChanged: (_) => localeProvider.setChineseLocale(),
          ),
          RadioListTile<String>(
            title: Text(context.l10n.english),
            value: 'en',
            groupValue: currentLocale,
            onChanged: (_) => localeProvider.setEnglishLocale(),
          ),
        ],
      ),
    );
  }
} 