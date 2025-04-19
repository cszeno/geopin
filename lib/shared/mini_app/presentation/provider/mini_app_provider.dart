import 'package:flutter/material.dart';
import '../../domain/models/mini_app_model.dart';
import '../../domain/registry/mini_app_hub.dart';

/// 小程序视图模型
///
/// 管理小程序的状态并提供UI层与数据层的交互
class MiniAppProvider with ChangeNotifier {
  /// 所有小程序列表
  List<MiniAppModel> _miniApps = [];
  
  /// 是否处于编辑模式
  bool _isDraggingMode = false;
  
  /// 构造函数
  MiniAppProvider() {
    _loadMiniApps();
  }
  
  /// 获取所有小程序
  List<MiniAppModel> get miniApps => _miniApps;
  
  /// 获取是否处于编辑模式
  bool get isDraggingMode => _isDraggingMode;
  
  /// 设置编辑模式
  void setDraggingMode(bool value) {
    _isDraggingMode = value;
    notifyListeners();
  }
  
  /// 获取分类下的小程序
  List<MiniAppModel> getAppsByCategory() {
    return _miniApps;
  }
  
  /// 加载小程序
  void _loadMiniApps() {
    // 从MiniAppHub获取所有配置的小程序
    _miniApps = MiniAppHub.instance.getAllAppConfigs();
    notifyListeners();
  }
  
  /// 更新小程序顺序（现已禁用）
  void updateMiniAppsOrder(List<MiniAppModel> apps) {
    // 排序功能已禁用
  }
} 