import 'package:flutter/material.dart';
import 'generated/app_localizations.dart';

/// 本地化工具扩展
extension AppLocalizationsExtension on BuildContext {
  /// 获取本地化资源
  AppLocalizations get l10n => AppLocalizations.of(this)!;
} 