import 'package:flutter/material.dart';

/// 小程序类型枚举
enum MiniAppType {
  /// 使用事件总线处理点击
  eventBus,
  
  /// 使用路由处理点击
  router
}

/// 小程序模型类
///
/// 定义应用中小程序的基本结构和属性
class MiniAppModel {
  /// 小程序唯一标识符
  final String id;
  
  /// 小程序名称
  final String name;
  
  /// 小程序图标
  final IconData icon;
  
  /// 小程序图标背景色
  final Color color;
  
  /// 小程序背景色
  final Color backgroundColor;
  
  /// 小程序路由
  final String route;
  

  /// 小程序优先级（用于排序）
  final int priority;
  
  /// 小程序是否可用
  final bool isEnabled;
  
  /// 小程序类型
  final MiniAppType type;
  
  /// 事件名称（仅type为eventBus时有效）
  final Object? eventName;
  
  /// 小程序构造函数
  const MiniAppModel({
    required this.id,
    required this.name, 
    required this.icon, 
    required this.color,
    required this.backgroundColor,
    required this.route,
    this.priority = 100,
    this.isEnabled = true,
    this.type = MiniAppType.router,
    this.eventName,
  });
  
  /// 创建小程序模型的副本并更新属性
  MiniAppModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    Color? backgroundColor,
    String? route,
    String? category,
    int? priority,
    bool? isEnabled,
    MiniAppType? type,
    Object? eventName,
  }) {
    return MiniAppModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      route: route ?? this.route,
      priority: priority ?? this.priority,
      isEnabled: isEnabled ?? this.isEnabled,
      type: type ?? this.type,
      eventName: eventName ?? this.eventName,
    );
  }
  
  /// 从JSON对象创建小程序模型
  factory MiniAppModel.fromJson(Map<String, dynamic> json, IconData Function(int codePoint) iconFromCode) {
    return MiniAppModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: iconFromCode(json['iconCode'] as int),
      color: Color(json['color'] as int),
      backgroundColor: Color(json['backgroundColor'] as int),
      route: json['route'] as String,
      priority: json['priority'] as int? ?? 100,
      isEnabled: json['isEnabled'] as bool? ?? true,
      // 默认使用router类型
      type: MiniAppType.router,
    );
  }
  
  /// 将小程序模型转换为JSON对象
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'color': color.value,
      'backgroundColor': backgroundColor.value,
      'route': route,
      'priority': priority,
      'isEnabled': isEnabled,
    };
  }

  /// 可以添加一个构造函数，从现有的 color 自动创建背景色
  MiniAppModel.withAutoBackground({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    required String category,
    required String route,
    bool isEnabled = true,
    MiniAppType type = MiniAppType.router,
    Object? eventName,
  }) : this(
    id: id,
    name: name,
    icon: icon,
    color: color,
    backgroundColor: color, // 自动使用前景色作为背景色
    route: route,
    isEnabled: isEnabled,
    type: type,
    eventName: eventName,
  );
} 