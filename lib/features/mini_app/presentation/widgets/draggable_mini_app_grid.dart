import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../core/event/event_bus.dart';
import '../../domain/models/mini_app_model.dart';
import '../../domain/registry/mini_app_registry.dart';
import '../provider/mini_app_provider.dart';
import 'mini_app_icon_widget.dart';

/// 可拖拽的小程序网格组件
/// 
/// 提供流畅的拖拽体验和排序功能
class DraggableMiniAppGrid extends StatefulWidget {
  /// 小程序列表
  final List<MiniAppModel> apps;
  
  /// 是否处于拖拽模式
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
  /// 存储当前小程序列表（可能会在拖拽过程中临时改变）
  late List<MiniAppModel> _currentApps;
  
  /// 拖拽开始前的备份列表
  late List<MiniAppModel> _backupApps;
  
  /// 当前被覆盖的项索引
  int _overlapIndex = -1;
  
  /// 是否显示源元素
  bool _showSrcElement = false;

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
      itemBuilder: (context, index) => _buildDraggableItem(index, _currentApps[index]),
    );
  }

  /// 构建可拖拽的小程序项
  Widget _buildDraggableItem(int index, MiniAppModel app) {
    // 如果不是拖拽模式，直接返回普通图标
    if (!widget.isDraggingMode) {
      return MiniAppIconWidget(
        app: app,
        isDraggingMode: false,
        onPressed: () {
          // 普通模式下点击打开小程序
          _handleMiniAppTap(context, app);
        },
      );
    }

    // 拖拽模式
    return Draggable<MiniAppModel>(
      data: app,
      // 长按震动反馈
      feedbackOffset: const Offset(0, -20),
      // 拖拽时显示的组件
      feedback: Material(
        elevation: 4.0,
        color: Colors.transparent,
        child: SizedBox(
          width: 80,
          height: 90,
          child: MiniAppIconWidget(
            app: app,
            isDraggingMode: true,
            onPressed: () {}, // 拖拽中不响应点击
          ),
        ),
      ),
      // 被拖拽的位置显示的组件
      childWhenDragging: _showSrcElement
          ? MiniAppIconWidget(
              app: app,
              isDraggingMode: true,
              opacity: 0.3, // 半透明表示原位置
              onPressed: () {},
            )
          : const SizedBox.shrink(),
      // 拖拽开始时
      onDragStarted: () {
        // 备份当前列表
        _backupApps = List.from(_currentApps);
        // 触觉反馈
        HapticFeedback.mediumImpact();
      },
      // 拖拽取消时
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          // 恢复原始数据
          _currentApps = List.from(_backupApps);
          _overlapIndex = -1;
          _showSrcElement = false;
        });
      },
      // 拖拽完成时
      onDragCompleted: () {
        setState(() {
          _showSrcElement = false;
          _overlapIndex = -1;
          
          // 保存新的排序到视图模型
          final miniAppViewModel = Provider.of<MiniAppProvider>(context, listen: false);
          miniAppViewModel.updateMiniAppsOrder(_currentApps);
        });
      },
      // 实际显示的组件
      child: DragTarget<MiniAppModel>(
        builder: (context, candidateData, rejectedData) {
          // 如果当前项是被覆盖的项，则不显示
          return index == _overlapIndex
              ? const SizedBox.shrink()
              : MiniAppIconWidget(
                  app: app,
                  isDraggingMode: true,
                  onPressed: () {
                    // 拖拽模式下点击切换启用状态
                    _toggleMiniAppEnabled(context, app);
                  },
                );
        },
        // 当有拖拽项进入时
        onWillAccept: (draggedApp) {
          if (draggedApp != null && draggedApp.id != app.id) {
            setState(() {
              final int draggedIndex = _backupApps.indexWhere((a) => a.id == draggedApp.id);
              final int targetIndex = _backupApps.indexWhere((a) => a.id == app.id);
              
              // 更新列表顺序
              _currentApps.removeAt(draggedIndex);
              _currentApps.insert(index, draggedApp);
              
              // 更新UI状态
              _showSrcElement = true;
              _overlapIndex = index;
            });
          }
          return true;
        },
        // 当拖拽项离开时
        onLeave: (data) {
          setState(() {
            _overlapIndex = -1;
            _showSrcElement = false;
            _currentApps = List.from(_backupApps);
          });
        },
        // 当放下拖拽项时
        onAccept: (data) {
          // 接受拖拽，状态在 onDragCompleted 中处理
        },
      ),
    );
  }

  /// 处理小程序点击
  void _handleMiniAppTap(BuildContext context, MiniAppModel app) {
    // 触发小程序点击通用事件
    bus.emit(MiniAppEvent.tapAnyMiniApp, app);
    
    // 根据小程序类型处理点击
    switch (app.type) {
      case MiniAppType.eventBus:
        if (app.eventName != null) {
          bus.emit(app.eventName!, app);
        }
        break;
      case MiniAppType.router:
      default:
        // 对于路由类型，直接使用路由导航
        context.push(app.route);
    }
  }

  /// 切换小程序启用状态
  void _toggleMiniAppEnabled(BuildContext context, MiniAppModel app) {
    final miniAppViewModel = Provider.of<MiniAppProvider>(context, listen: false);
    miniAppViewModel.setMiniAppEnabled(app.id, !app.isEnabled);
    
    // 触觉反馈
    HapticFeedback.lightImpact();
    
    // 显示操作提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(app.isEnabled ? "已禁用 ${app.name}" : "已启用 ${app.name}"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 