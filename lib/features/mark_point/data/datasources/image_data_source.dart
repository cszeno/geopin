import 'package:image_picker/image_picker.dart';

/// 图片数据源接口
abstract class ImageDataSource {
  /// 从相机或相册选择图片
  Future<XFile?> pickImage(ImageSource source);
}

/// 图片数据源实现
class ImageDataSourceImpl implements ImageDataSource {
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  Future<XFile?> pickImage(ImageSource source) async {
    return await _imagePicker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
  }
} 