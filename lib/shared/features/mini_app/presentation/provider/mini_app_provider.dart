import 'package:flutter/material.dart';
import '../../domain/models/mini_app_model.dart';
import '../../infrastructure/services/mini_app_service.dart';

/// 小程序视图模型
///
/// 管理小程序的状态并提供UI层与数据层的交互
class MiniAppProvider with ChangeNotifier {
  /// 小程序服务
  final MiniAppService _miniAppService = MiniAppService();
  
  /// 所有小程序列表
  List<MiniAppModel> _miniApps = [];
  
  /// 拖拽排序模式状态
  bool _isDraggingMode = false;
  
  /// 构造函数
  MiniAppProvider() {
    _loadMiniApps();
  }
  
  /// 获取所有小程序
  List<MiniAppModel> get miniApps => _miniApps;
  
  /// 获取拖拽排序模式状态
  bool get isDraggingMode => _isDraggingMode;
  
  /// 设置拖拽排序模式
  void setDraggingMode(bool value) {
    _isDraggingMode = value;
    notifyListeners();
  }
  
  /// 切换拖拽排序模式
  void toggleDraggingMode() {
    _isDraggingMode = !_isDraggingMode;
    notifyListeners();
  }
  
  /// 根据类别获取小程序
  List<MiniAppModel> getAppsByCategory() {
    return _miniApps
        .where((app) => app.isEnabled)
        .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
  }
  
  /// 加载小程序
  Future<void> _loadMiniApps() async {
    _miniApps = await _miniAppService.loadMiniApps();
    notifyListeners();
  }
  
  /// 更新小程序排序
  Future<void> updateMiniAppsOrder(List<MiniAppModel> apps) async {
    // 获取排序前的应用
    final oldApps = getAppsByCategory();
    
    // 如果排序没有改变，不做任何操作
    if (_isOrderSame(oldApps, apps)) {
      return;
    }
    
    // 创建优先级映射，用于保存
    final Map<String, int> priorities = {};
    
    // 为排序后的应用分配新的优先级
    for (int i = 0; i < apps.length; i++) {
      priorities[apps[i].id] = (i + 1) * 10; // 使用10的倍数作为优先级，便于后期插入
    }
    
    // 保存排序
    await _miniAppService.saveMiniAppOrder(priorities);
    
    // 重新加载应用
    await _loadMiniApps();
  }
  
  /// 启用或禁用小程序
  Future<void> setMiniAppEnabled(String appId, bool isEnabled) async {
    // 获取当前状态
    final Map<String, bool> status = {};
    
    // 为每个应用设置启用状态
    for (final app in _miniApps) {
      if (app.id == appId) {
        status[appId] = isEnabled;
      } else {
        status[app.id] = app.isEnabled;
      }
    }
    
    // 保存状态
    await _miniAppService.saveMiniAppStatus(status);
    
    // 重新加载应用
    await _loadMiniApps();
  }
  
  /// 判断两个列表的排序是否相同
  bool _isOrderSame(List<MiniAppModel> list1, List<MiniAppModel> list2) {
    if (list1.length != list2.length) {
      return false;
    }
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) {
        return false;
      }
    }
    
    return true;
  }
} 