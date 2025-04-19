import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/event/event_bus.dart';
import '../../domain/models/mini_app_model.dart';
import '../../domain/registry/mini_app_hub.dart';
import '../provider/mini_app_provider.dart';
import 'mini_app_icon_widget.dart';

/// 小程序网格组件
/// 
/// 显示小程序网格
class DraggableMiniAppGrid extends StatefulWidget {
  /// 小程序列表
  final List<MiniAppModel> apps;
  
  /// 是否处于编辑模式
  final bool isDraggingMode;
  
  /// 构造函数
  const DraggableMiniAppGrid({
    super.key,
    required this.apps,
    required this.isDraggingMode,
  });

  @override
  State<DraggableMiniAppGrid> createState() => _DraggableMiniAppGridState();
}

class _DraggableMiniAppGridState extends State<DraggableMiniAppGrid> {
  /// 存储当前小程序列表
  late List<MiniAppModel> _currentApps;

  @override
  void initState() {
    super.initState();
    _currentApps = List.from(widget.apps);
  }
  
  @override
  void didUpdateWidget(DraggableMiniAppGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当传入的apps发生变化时更新内部列表
    if (widget.apps != oldWidget.apps) {
      _currentApps = List.from(widget.apps);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
      ),
      itemCount: _currentApps.length,
      itemBuilder: (context, index) => _buildItem(index, _currentApps[index]),
    );
  }

  /// 构建小程序项
  Widget _buildItem(int index, MiniAppModel app) {
    // 如果不是编辑模式，直接返回普通图标
    if (!widget.isDraggingMode) {
      return MiniAppIconWidget(
        app: app,
        isDraggingMode: false,
        onPressed: () {
          // 普通模式下点击通过MiniAppHub处理点击
          MiniAppHub.instance.handleMiniAppTap(context, app.id);
        },
      );
    }

    // 编辑模式
    return MiniAppIconWidget(
      app: app,
      isDraggingMode: true,
      onPressed: () {}, // 编辑模式下点击不做任何操作
    );
  }
} 