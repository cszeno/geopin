import 'package:flutter/material.dart';
import '../../domain/models/mini_app_model.dart';
import 'dart:math' as math;

/// 小程序图标组件
/// 
/// 用于显示小程序的图标、名称和状态
class MiniAppIconWidget extends StatefulWidget {
  /// 小程序模型
  final MiniAppModel app;
  
  /// 是否处于拖拽模式
  final bool isDraggingMode;
  
  /// 图标不透明度
  final double opacity;
  
  /// 点击回调函数
  final VoidCallback onPressed;
  
  /// 构造函数
  const MiniAppIconWidget({
    super.key,
    required this.app,
    required this.isDraggingMode,
    this.opacity = 1.0,
    required this.onPressed,
  });

  @override
  State<MiniAppIconWidget> createState() => _MiniAppIconWidgetState();
}

class _MiniAppIconWidgetState extends State<MiniAppIconWidget> with SingleTickerProviderStateMixin {
  // 抖动动画控制器
  late AnimationController _shakeController;
  
  @override
  void initState() {
    super.initState();
    // 初始化抖动动画控制器
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    
    // 如果不是拖拽模式，暂停动画
    if (!widget.isDraggingMode) {
      _shakeController.stop();
    }
  }
  
  @override
  void didUpdateWidget(MiniAppIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 当拖拽模式状态改变时，控制动画播放状态
    if (widget.isDraggingMode != oldWidget.isDraggingMode) {
      if (widget.isDraggingMode) {
        _shakeController.repeat(reverse: true);
      } else {
        _shakeController.stop();
        _shakeController.reset();
      }
    }
  }
  
  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根据小程序启用状态和拖拽模式决定显示样式
    final bool isDisabled = !widget.app.isEnabled && widget.isDraggingMode;
    
    // 创建基础图标组件
    Widget iconWidget = SizedBox(
      height: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标容器
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: widget.app.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!widget.isDraggingMode)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.app.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          
          const SizedBox(height: 6),
          
          // 小程序名称
          Text(
            widget.app.name,
            style: TextStyle(
              fontSize: 11,
              color: isDisabled 
                ? const Color(0xFF8E8E93) 
                : const Color(0xFF1C1C1E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    
    // 在拖拽模式下添加抖动动画效果
    if (widget.isDraggingMode) {
      iconWidget = AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          // 使用正弦函数创建来回震动效果
          final sineValue = math.sin(2 * math.pi * _shakeController.value);
          // 最大抖动角度为2度
          final rotationAngle = sineValue * 0.035;
          
          return Transform.rotate(
            angle: rotationAngle,
            child: child,
          );
        },
        child: iconWidget,
      );
    }
    
    return AnimatedOpacity(
      opacity: isDisabled ? 0.4 : widget.opacity,
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(12),
        child: iconWidget,
      ),
    );
  }
} 