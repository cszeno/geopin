import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/mark_point_entity.dart';
import '../providers/mark_point_provider.dart';
import '../widgets/full_screen_image_view_widget.dart';
import 'mark_point_form_page.dart';
import '../../data/repositories/image_repository_impl.dart';

/// 标记点详情底部弹窗
class MarkPointDetailSheet extends StatelessWidget {
  /// 要显示详情的标记点实体
  final MarkPointEntity markPoint;

  /// 构造函数
  const MarkPointDetailSheet({
    super.key,
    required this.markPoint,
  });

  @override
  Widget build(BuildContext context) {
    // 获取设备尺寸以适配不同屏幕
    final size = MediaQuery.of(context).size;

    return Container(
      // 高度限制
      constraints: BoxConstraints(maxHeight: size.height * 0.7),
      // 圆角装饰
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias, // 裁剪超出圆角的部分
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部标题栏
          _buildHeader(context),
          
          // 内容区域
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 坐标信息
                  _buildCoordinateInfo(context),
                  
                  const SizedBox(height: 16),

                  // 自定义属性
                  if (markPoint.attributes != null && markPoint.attributes!.isNotEmpty)
                    _buildAttributesSection(context),
                  
                  const SizedBox(height: 16),

                  // 图片预览
                  if (markPoint.imgPath != null && markPoint.imgPath!.isNotEmpty)
                    _buildImagePreview(context),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部拖动条
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              // 标记点颜色徽章
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: markPoint.color,
                  shape: BoxShape.circle,
                ),
              ),
              // 标记点名称
              Expanded(
                child: Text(
                  markPoint.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 编辑按钮
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // 关闭详情弹窗
                  Navigator.pop(context);
                  
                  // 打开编辑页面
                  _openEditPage(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建坐标信息
  Widget _buildCoordinateInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            '位置信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 经纬度信息
          _buildInfoRow(
            context, 
            '经度', 
            markPoint.longitude.toStringAsFixed(6),
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            context, 
            '纬度', 
            markPoint.latitude.toStringAsFixed(6),
          ),
          // 高程信息（如果有）
          if (markPoint.elevation != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow(
              context, 
              '高程', 
              '${markPoint.elevation!.toStringAsFixed(2)} 米',
            ),
          ],
          // 添加时间
          const SizedBox(height: 4),
          _buildInfoRow(
            context, 
            '创建时间', 
            _formatTimestamp(markPoint.id),
          ),
        ],
      ),
    );
  }

  /// 构建图片预览
  Widget _buildImagePreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '图片 (${markPoint.imgPath!.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: markPoint.imgPath!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _showFullScreenImage(context, index);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FutureBuilder<String>(
                    future: ImageRepositoryImpl.getAbsoluteImagePath(markPoint.imgPath![index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        AppLogger.error('加载缩略图失败: ${snapshot.error}');
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.error_outline, color: Colors.red),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(snapshot.data!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              AppLogger.error('渲染缩略图失败: $error');
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.red),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 显示全屏图片
  void _showFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewWidget(
          images: markPoint.imgPath!,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  /// 构建自定义属性区域
  Widget _buildAttributesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '属性信息',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: markPoint.attributes!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildInfoRow(context, entry.key, entry.value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 格式化时间戳
  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  /// 打开编辑页面
  void _openEditPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MarkPointFormPage(
        projectUUID: markPoint.projectUUID!,
        latitude: markPoint.latitude,
        longitude: markPoint.longitude,
        altitude: markPoint.elevation ?? 0,
        onSubmit: (updatedMarkPoint) {
          // 更新标记点
          final markPointProvider = Provider.of<MarkPointProvider>(context, listen: false);
          markPointProvider.updatePoint(updatedMarkPoint);
        },
      ),
    );
  }
} 