import 'package:flutter/material.dart';
import '../../domain/models/mini_app_model.dart';

/// 小程序图标组件
/// 
/// 用于显示小程序的图标、名称和状态
class MiniAppIconWidget extends StatelessWidget {
  /// 小程序模型
  final MiniAppModel app;
  
  /// 图标不透明度
  final double opacity;
  
  /// 点击回调函数
  final VoidCallback onPressed;
  
  /// 构造函数
  const MiniAppIconWidget({
    super.key,
    required this.app,
    this.opacity = 1.0,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 创建基础图标组件
    final iconWidget = SizedBox(
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
              color: app.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Icon(
                app.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          
          const SizedBox(height: 6),
          
          // 小程序名称
          Text(
            app.name,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF1C1C1E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: iconWidget,
      ),
    );
  }
} 