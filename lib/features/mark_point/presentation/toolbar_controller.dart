import 'package:flutter/material.dart';

import '../../../shared/sider_tool/map_side_toolbar.dart';


/// 工具栏控制器
///
/// 管理地图工具栏的状态和行为。
/// 职责：
/// 1. 管理工具栏项目的状态（激活/非激活）
/// 2. 提供工具栏项目的操作方法
/// 3. 处理工具栏项目的排序逻辑
class ToolbarController {
  /// 工具栏项目列表
  List<MapToolItem> _toolItems = [];

  /// 当前激活的工具索引
  int _activeToolIndex = -1;

  /// 获取工具栏项目列表
  List<MapToolItem> get toolItems => _toolItems;

  /// 获取当前激活的工具索引
  int get activeToolIndex => _activeToolIndex;

  /// 构造函数
  ToolbarController() {
    // 初始化工具项
    initToolbarItems();
  }

  /// 初始化工具项列表
  void initToolbarItems() {
    _toolItems = [
      MapToolItem(
        icon: Icons.compare_arrows_sharp,
        label: '排序',
        tooltip: '对工具的顺序排序',
        id: 'order',
        isActive: _activeToolIndex == 0,
      ),
      MapToolItem(
        icon: Icons.folder,
        label: '项目管理',
        tooltip: '项目管理',
        id: 'project_manager',
        isActive: _activeToolIndex == 0,
      ),
      MapToolItem(
        icon: Icons.map,
        label: '切换地图',
        tooltip: '切换不同的地图源',
        isActive: _activeToolIndex == 1,
        id: 'map_switch',
      ),
      MapToolItem(
        icon: Icons.navigation,
        label: '回正',
        tooltip: '移动地图到当前位置',
        isActive: _activeToolIndex == 2,
        id: 'move_current_location',
      ),
      MapToolItem(
        icon: Icons.add_circle_outline,
        label: '放大',
        tooltip: '放大地图',
        isActive: _activeToolIndex == 3,
        id: 'zoom_in',
      ),
      MapToolItem(
        icon: Icons.remove_circle_outline,
        label: '缩小',
        tooltip: '缩小地图',
        isActive: _activeToolIndex == 4,
        id: 'zoom_out',
      ),
      MapToolItem(
        icon: Icons.title,
        label: '标题',
        tooltip: '是否显示标题',
        isActive: _activeToolIndex == 5,
        id: 'show_title',
      ),
      MapToolItem(
        icon: Icons.gps_fixed,
        label: '光标',
        tooltip: '切换十字光标显示模式',
        isActive: _activeToolIndex == 7,
        id: 'crosshair_mode',
      ),
    ];
  }

  /// 设置激活工具
  ///
  /// [tool] 要激活的工具项
  /// 返回是否需要更新UI
  bool setActiveTool(MapToolItem tool) {
    final oldIndex = _activeToolIndex;
    _activeToolIndex = _toolItems.indexWhere((item) => item.id == tool.id);

    // 更新工具项的活动状态
    _toolItems =
        _toolItems.map((item) {
          return MapToolItem(
            icon: item.icon,
            label: item.label,
            tooltip: item.tooltip,
            id: item.id,
            isActive: item.id == tool.id,
          );
        }).toList();

    // 如果索引变化，返回true表示需要更新UI
    return oldIndex != _activeToolIndex;
  }

  /// 重置工具的激活状态
  ///
  /// 返回是否需要更新UI
  bool resetToolActiveState() {
    final hadActiveTool = _activeToolIndex != -1;
    _activeToolIndex = -1;

    // 更新所有工具项为非激活状态
    _toolItems =
        _toolItems.map((item) {
          return MapToolItem(
            icon: item.icon,
            label: item.label,
            tooltip: item.tooltip,
            id: item.id,
            isActive: false,
          );
        }).toList();

    // 如果之前有激活的工具，返回true表示需要更新UI
    return hadActiveTool;
  }

  /// 更新工具项列表
  ///
  /// [newToolItems] 新的工具项列表
  void updateToolItems(List<MapToolItem> newToolItems) {
    _toolItems = newToolItems;

    // 更新激活工具索引
    if (_activeToolIndex > 0) {
      _activeToolIndex = _toolItems.indexWhere(
        (tool) => tool.isActive && tool != _toolItems[0],
      );
    }
  }

  /// 根据ID获取工具项
  MapToolItem? getToolById(String id) {
    final index = _toolItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      return _toolItems[index];
    }
    return null;
  }
}
