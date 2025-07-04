import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:geopin/features/mark_point/data/repositories/image_repository_impl.dart';

/// 图片预览组件
/// 
/// 显示选择的图片，并提供添加和删除功能
class ImagePreviewWidget extends StatelessWidget {
  /// 已选择的图片路径列表
  final List<String> selectedImagePaths;
  
  /// 添加图片回调
  final VoidCallback onAddImage;
  
  /// 移除图片回调
  final Function(int) onRemoveImage;
  
  /// 构造函数
  const ImagePreviewWidget({
    super.key,
    required this.selectedImagePaths,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return _buildPreviewList(context);
  }

  /// 构建空状态UI
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: GestureDetector(
          onTap: onAddImage,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  '添加图片',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建预览列表UI
  Widget _buildPreviewList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Text(
            //   '已选择 ${selectedImagePaths.length} 张图片',
            //   style: const TextStyle(
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            Text(
              '图片',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              onPressed: onAddImage,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加图片'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        if(selectedImagePaths.isNotEmpty)
          ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedImagePaths.length,
                itemBuilder: (context, index) {
                  return _buildImageItem(context, index);
                },
              ),
            ),
          ]
      ],
    );
  }

  /// 构建单个图片项
  Widget _buildImageItem(BuildContext context, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: FutureBuilder<String>(
            future: ImageRepositoryImpl.getAbsoluteImagePath(selectedImagePaths[index]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                AppLogger.error('加载图片失败: ${snapshot.error}');
                return Center(
                  child: Icon(Icons.error_outline, color: Colors.red),
                );
              } else if (snapshot.hasData) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(snapshot.data!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      AppLogger.error('渲染图片失败: $error');
                      return Center(
                        child: Icon(Icons.broken_image, color: Colors.red),
                      );
                    },
                  ),
                );
              } else {
                return Center(
                  child: Icon(Icons.image_not_supported),
                );
              }
            },
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          child: GestureDetector(
            onTap: () => onRemoveImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 