import 'dart:io';

import 'package:geopin/core/utils/app_logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';

import '../../domain/repositories/image_repository.dart';
import '../datasources/image_data_source.dart';

/// 图片仓库实现
class ImageRepositoryImpl implements ImageRepository {
  final ImageDataSource _imageDataSource = GetIt.I<ImageDataSource>();
  
  // 图片存储子目录名称
  static const String imageSubDir = 'mark_point_images';
  
  ImageRepositoryImpl();
  
  @override
  Future<String?> pickAndSaveImage(ImageSource source) async {
    try {
      final XFile? image = await _imageDataSource.pickImage(source);
      
      if (image == null) {
        AppLogger.debug('用户取消了图片选择');
        return null;
      }
      
      AppLogger.debug('选择的图片路径: ${image.path}');
      
      // 将图片保存到应用目录
      final String savedPath = await _saveImageToAppDirectory(image.path);
      AppLogger.debug('保存后的图片路径: $savedPath');
      
      return savedPath;
    } catch (e) {
      AppLogger.error('选择或保存图片失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<bool> deleteImage(String imagePath) async {
    try {
      // 转换为绝对路径
      final absolutePath = await _getAbsoluteImagePath(imagePath);
      
      final file = File(absolutePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('删除图片失败: $e');
      return false;
    }
  }
  
  /// 将图片保存到应用内部目录，返回相对路径
  Future<String> _saveImageToAppDirectory(String imagePath) async {
    try {
      // 获取应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      // 创建图片存储目录
      final imageDir = Directory('${appDir.path}/$imageSubDir');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      // 生成唯一的文件名
      final fileName = '${const Uuid().v4()}${path.extension(imagePath)}';
      final targetPath = '${imageDir.path}/$fileName';
      
      // 复制图片到应用目录
      final File sourceFile = File(imagePath);
      await sourceFile.copy(targetPath);
      
      // 存储相对路径，而不是绝对路径
      final relativePath = '$imageSubDir/$fileName';
      AppLogger.debug('保存图片成功，相对路径: $relativePath');
      return relativePath;
    } catch (e) {
      AppLogger.error('保存图片到应用目录失败: $e');
      // 如果保存失败，返回原路径
      return imagePath;
    }
  }
  
  /// 获取图片的绝对路径
  Future<String> _getAbsoluteImagePath(String relativePath) async {
    // 如果已经是绝对路径，则直接返回
    if (relativePath.startsWith('/')) {
      return relativePath;
    }
    
    // 获取应用文档目录
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$relativePath';
  }
  
  /// 获取图片的绝对路径（静态方法，可供外部使用）
  static Future<String> getAbsoluteImagePath(String relativePath) async {
    // 如果已经是绝对路径，则直接返回
    if (relativePath.startsWith('/')) {
      return relativePath;
    }
    
    // 获取应用文档目录
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$relativePath';
  }
} 