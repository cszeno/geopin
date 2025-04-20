import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/mini_app_model.dart';
import '../../domain/registry/mini_app_hub.dart';
import 'mini_app_icon_widget.dart';

/// 小程序网格组件
/// 
/// 显示小程序网格
class MiniAppGrid extends StatelessWidget {
  /// 小程序列表
  final List<MiniAppModel> apps;
  
  /// 构造函数
  const MiniAppGrid({
    super.key,
    required this.apps,
  });

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
      itemCount: apps.length,
      itemBuilder: (context, index) => _buildItem(context, apps[index]),
    );
  }

  /// 构建小程序项
  Widget _buildItem(BuildContext context, MiniAppModel app) {
    return MiniAppIconWidget(
      app: app,
      onPressed: () {
        // 点击通过MiniAppHub处理点击
        context.pop();
        MiniAppHub.instance.handleMiniAppTap(context, app.id);
      },
    );
  }
} 