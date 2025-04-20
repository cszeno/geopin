import 'package:flutter/material.dart';
import '../../domain/registry/mini_app_hub.dart';
import 'draggable_mini_app_grid.dart';

/// 小程序网格组件
/// 
/// 用于显示小程序网格列表
class MiniAppGridWidget extends StatelessWidget {
  /// 构造函数
  const MiniAppGridWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final apps = MiniAppHub.instance.getAllAppConfigs();
    
    if (apps.isEmpty) {
      return _buildEmptyState();
    }
    
    return MiniAppGrid(
      apps: apps,
    );
  }
  
  /// 构建空状态视图
  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            "暂无可用小程序",
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