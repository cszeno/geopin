import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';

import '../repositories/image_repository.dart';

/// 保存图片用例
/// 
/// 负责从相机或相册选择图片并保存到应用目录
class SaveImageUseCase {
  final ImageRepository _imageRepository = GetIt.I<ImageRepository>();
  
  /// 从相机或相册选择图片并保存
  /// 
  /// [source] - 图片来源 (相机或相册)
  /// 返回保存后的图片路径，如果用户取消则返回null
  Future<String?> execute(ImageSource source) async {
    return await _imageRepository.pickAndSaveImage(source);
  }
} 