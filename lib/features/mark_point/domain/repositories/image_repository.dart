import 'package:image_picker/image_picker.dart';

/// 图片仓库接口
///
/// 定义处理图片的方法，遵循依赖倒置原则
abstract class ImageRepository {
  /// 选择并保存图片
  ///
  /// [source] - 图片来源 (相机或相册)
  /// 返回保存后的图片路径，如果用户取消则返回null
  Future<String?> pickAndSaveImage(ImageSource source);
  
  /// 删除图片
  ///
  /// [imagePath] - 要删除的图片路径
  Future<bool> deleteImage(String imagePath);
} 