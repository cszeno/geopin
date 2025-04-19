import 'package:flutter/material.dart';
import '../../../shared/features/mini_app/domain/models/mini_app_model.dart';
import '../../../shared/features/mini_app/domain/registry/mini_app_registry.dart';

/// 标记点功能注册器
class MiniAppRegister {

  /// 注册应用到 MiniAppRegistry
  static void register() {
    MiniAppRegistry.register(markPoint);
    MiniAppRegistry.register(markLine);
    MiniAppRegistry.register(locationTest);
    MiniAppRegistry.register(log);
    MiniAppRegistry.register(settings);
  }

  /// 声明应用
  static const MiniAppModel markPoint = MiniAppModel(
    id: 'mark_point',
    name: '标记点',
    icon: Icons.location_searching,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/mark_point',
    priority: 15,
  );

  static const MiniAppModel markLine = MiniAppModel(
    id: 'mark_line',
    name: '标记线',
    icon: Icons.linear_scale,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/mark_line',
    priority: 15, // 设置较高优先级使其显示在前面
  );

  static const MiniAppModel locationTest = MiniAppModel(
    id: "location_test",
    name: '位置数据',
    icon: Icons.info_outline_rounded,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/location_test',
    priority: 15, // 设置较高优先级使其显示在前面
  );

  static const MiniAppModel settings = MiniAppModel(
    id: 'setting',
    name: '设置',
    icon: Icons.settings,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/settings',
    priority: 20,
  );

  static const MiniAppModel log = MiniAppModel(
    id: 'log',
    name: '日志',
    icon: Icons.text_snippet_outlined,
    color: Color(0xFF007AFF),
    backgroundColor: Color(0xFF007AFF),
    route: '/log',
    priority: 20,
  );
}
