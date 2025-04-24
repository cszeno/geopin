import 'package:flutter/material.dart';
import '../../core/utils/sp_util.dart';

/// 地图顶部工具栏组件
/// 可以垂直方向上下展开和收缩，支持自定义工具按钮
class MapSideToolbar extends StatefulWidget {
  /// 工具栏项目列表
  final List<MapToolItem> items;

  /// 折叠状态下显示的工具数量
  final int collapsedItemCount;

  /// 工具栏宽度
  final double width;

  /// 每个工具项的高度
  final double itemHeight;

  /// 工具栏背景颜色
  final Color backgroundColor;

  /// 工具栏边框圆角
  final double borderRadius;

  /// 工具栏阴影
  final double elevation;

  /// 初始状态是否展开
  final bool initiallyExpanded;

  /// 工具项点击回调
  final Function(MapToolItem) onToolTap;

  /// 顶部边距，用于避开搜索框
  final double topMargin;

  const MapSideToolbar({
    super.key,
    required this.items,
    this.collapsedItemCount = 0,
    this.width = 44.0,
    this.itemHeight = 56.0,
    this.backgroundColor = Colors.white,
    this.borderRadius = 12.0,
    this.elevation = 4.0,
    this.initiallyExpanded = false,
    required this.onToolTap,
    this.topMargin = 80.0, // 默认给搜索框留出空间
  });

  @override
  State<MapSideToolbar> createState() => _MapSideToolbarState();
}

/// 工具栏展开方向枚举
enum ToolbarDirection { up, down }

/// 工具项数据模型
class MapToolItem {
  /// 工具图标
  final IconData icon;

  /// 工具名称
  final String label;

  /// 工具提示文本
  final String? tooltip;

  /// 是否启用
  final bool enabled;

  /// 是否为当前活动项
  final bool isActive;

  final String id; // 添加唯一标识符

  const MapToolItem({
    required this.icon,
    required this.label,
    required this.id, // 必须提供ID
    this.tooltip,
    this.enabled = true,
    this.isActive = false,
  });
}

class _MapSideToolbarState extends State<MapSideToolbar> with SingleTickerProviderStateMixin {
  /// 控制展开收缩的动画控制器
  late AnimationController _animationController;

  /// 当前是否展开
  bool _isExpanded = true;

  /// 存储键名
  static const String _toolbarExpandedKey = 'map_toolbar_expanded';

  /// 存储服务实例
  final SPUtil _storageService = SPUtil();

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 预先设置默认值，防止加载前闪烁
    _isExpanded = widget.initiallyExpanded;
    if (_isExpanded) {
      _animationController.value = 1.0;
    }

    // 确保存储服务初始化后再加载状态
    _initStorage();
  }

  /// 初始化存储服务并加载状态
  Future<void> _initStorage() async {
    // 确保存储服务已初始化
    if (!_storageService.isInitialized) {
      await _storageService.init();
    }

    // 加载保存的状态
    _loadExpandedState();
  }

  /// 从存储中加载展开状态
  Future<void> _loadExpandedState() async {
    try {
      // 检查键是否存在
      if (_storageService.containsKey(_toolbarExpandedKey)) {
        final savedExpanded = _storageService.getBool(_toolbarExpandedKey);

        // 只有在值不为null且与当前状态不同时才更新
        if (savedExpanded != null && savedExpanded != _isExpanded) {
          setState(() {
            _isExpanded = savedExpanded;
            // 更新动画控制器值
            if (_isExpanded) {
              _animationController.value = 1.0;
            } else {
              _animationController.value = 0.0;
            }
          });
        }
      } else {
        // 如果没有保存过状态，保存初始状态
        await _saveExpandedState(_isExpanded);
      }
    } catch (e) {
      debugPrint('加载工具栏状态失败: $e');
    }
  }

  /// 保存展开状态到存储
  Future<void> _saveExpandedState(bool isExpanded) async {
    try {
      await _storageService.setBool(_toolbarExpandedKey, isExpanded);
    } catch (e) {
      debugPrint('保存工具栏状态失败: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 切换展开/收缩状态
  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;

      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }

      // 保存状态到本地存储
      _saveExpandedState(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕高度，用于限制工具栏最大高度
    final screenHeight = MediaQuery.of(context).size.height;
    // 计算工具栏最大高度为屏幕高度的60%
    final maxHeight = screenHeight * 0.6;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // 计算应该显示的工具项数量
        final visibleItemCount = _isExpanded
            ? widget.items.length
            : widget.collapsedItemCount;

        return Material(
          elevation: widget.elevation,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: widget.backgroundColor,
          child: Container(
            width: widget.width,
            // 限制最大高度
            constraints: BoxConstraints(
              maxHeight: maxHeight,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 使用Flexible+SingleChildScrollView使内容可滚动
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 显示工具项
                        ...widget.items.asMap().entries.take(visibleItemCount).map((entry) {
                          final index = entry.key;
                          final tool = entry.value;
                          return _buildToolItem(tool, index);
                        }),
                      ],
                    ),
                  ),
                ),

                // 仅当工具数量大于折叠时显示的数量时才显示切换按钮
                if (widget.items.length > widget.collapsedItemCount)
                  _buildToggleButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建展开/收缩切换按钮
  Widget _buildToggleButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleExpand,
        child: Container(
          width: widget.width,
          height: 30, // 固定高度以避免溢出
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.borderRadius),
              bottomRight: Radius.circular(widget.borderRadius),
            ),
          ),
          child: Center(
            child: Icon(
              _isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.blue,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建单个工具项
  Widget _buildToolItem(MapToolItem tool, int index) {
    // 创建工具提示包装
    Widget toolItemWidget = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tool.enabled ? () => widget.onToolTap(tool) : null,
        child: Container(
          width: widget.width,
          height: widget.itemHeight,
          decoration: BoxDecoration(
            color: tool.isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
            border: index < widget.items.length - 1
                ? Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 工具图标
              Icon(
                tool.icon,
                color: tool.enabled
                    ? (tool.isActive ? Colors.blue : Colors.grey[700])
                    : Colors.grey[400],
                size: 24,
              ),

              // 工具文本标签
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  tool.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: tool.enabled
                        ? (tool.isActive ? Colors.blue : Colors.grey[800])
                        : Colors.grey[400],
                    fontWeight: tool.isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  softWrap: true,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 如果有提示文本，添加工具提示
    if (tool.tooltip != null) {
      return Tooltip(
        message: tool.tooltip!,
        child: toolItemWidget,
      );
    }

    return toolItemWidget;
  }
}