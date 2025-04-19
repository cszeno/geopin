import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/mini_app_provider.dart';
import 'draggable_mini_app_grid.dart';

/// 小程序网格组件
/// 
/// 用于显示一个分类下的小程序网格
class MiniAppGridWidget extends StatelessWidget {
  /// 小程序分类

  /// 构造函数
  const MiniAppGridWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MiniAppProvider>(
      builder: (context, miniAppViewModel, child) {
        // 获取此分类下的小程序
        final apps = miniAppViewModel.getAppsByCategory();
        
        // 是否处于拖拽模式
        final isDraggingMode = miniAppViewModel.isDraggingMode;
        
        // 如果没有小程序，显示空状态
        if (apps.isEmpty) {
          return _buildEmptyState();
        }
        
        return DraggableMiniAppGrid(
          apps: apps,
          isDraggingMode: isDraggingMode,
        );
      },
    );
  }
  
  /// 构建空状态视图
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            "此分类暂无小程序",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF8E8E93),
            ),
          ),
        ),
      ),
    );
  }
} 