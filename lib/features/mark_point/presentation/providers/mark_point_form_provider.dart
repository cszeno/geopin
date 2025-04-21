import 'package:flutter/material.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/mark_point_entity.dart';
import '../../domain/usecases/add_attribute_history_usecase.dart';
import '../../domain/usecases/create_mark_point_usecase.dart';
import '../../domain/usecases/get_attribute_history_usecase.dart';
import '../../domain/usecases/get_saved_color_usecase.dart';
import '../../domain/usecases/save_color_usecase.dart';
import '../../domain/usecases/save_image_usecase.dart';

/// 标记点表单的Provider
/// 
/// 负责处理标记点表单的业务逻辑和状态管理
class MarkPointFormProvider extends ChangeNotifier {
  // 用例
  final SaveImageUseCase _saveImageUseCase;
  final GetSavedColorUseCase _getSavedColorUseCase;
  final SaveColorUseCase _saveColorUseCase;
  final GetAttributeHistoryUseCase _getAttributeHistoryUseCase;
  final AddAttributeHistoryUseCase _addAttributeHistoryUseCase;
  final CreateMarkPointUseCase _createMarkPointUseCase;

  // 表单状态
  final TextEditingController nameController = TextEditingController();
  final TextEditingController elevationController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // 可选的颜色列表
  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];

  // 状态变量
  Color _selectedColor = Colors.red;
  List<String> _selectedImagePaths = [];
  List<Map<String, String>> _currentAttributes = [];
  List<Map<String, String>> _historyAttributes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 构造函数
  MarkPointFormProvider({
    required SaveImageUseCase saveImageUseCase,
    required GetSavedColorUseCase getSavedColorUseCase,
    required SaveColorUseCase saveColorUseCase,
    required GetAttributeHistoryUseCase getAttributeHistoryUseCase,
    required AddAttributeHistoryUseCase addAttributeHistoryUseCase,
    required CreateMarkPointUseCase createMarkPointUseCase,
  }) : 
    _saveImageUseCase = saveImageUseCase,
    _getSavedColorUseCase = getSavedColorUseCase,
    _saveColorUseCase = saveColorUseCase,
    _getAttributeHistoryUseCase = getAttributeHistoryUseCase,
    _addAttributeHistoryUseCase = addAttributeHistoryUseCase,
    _createMarkPointUseCase = createMarkPointUseCase {
    // 初始化
    _loadData();
  }

  // Getter
  Color get selectedColor => _selectedColor;
  List<String> get selectedImagePaths => _selectedImagePaths;
  List<Map<String, String>> get currentAttributes => _currentAttributes;
  List<Map<String, String>> get historyAttributes => _historyAttributes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 初始化加载数据
  Future<void> _loadData() async {
    _setLoading(true);
    try {
      // 加载已保存的颜色
      _selectedColor = await _getSavedColorUseCase.execute();
      
      // 加载历史属性
      _historyAttributes = await _getAttributeHistoryUseCase.execute();
      
      _setLoading(false);
    } catch (e) {
      _setError('初始化数据失败: $e');
    }
  }

  /// 选择颜色
  Future<void> selectColor(Color color) async {
    try {
      _selectedColor = color;
      notifyListeners();
      
      // 保存选择的颜色
      await _saveColorUseCase.execute(color);
    } catch (e) {
      _setError('保存颜色失败: $e');
    }
  }

  /// 选择图片
  Future<void> pickImage(ImageSource source) async {
    try {
      _setLoading(true);
      
      final String? imagePath = await _saveImageUseCase.execute(source);
      
      if (imagePath != null) {
        _selectedImagePaths.add(imagePath);
        notifyListeners();
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('选择图片失败: $e');
    }
  }

  /// 移除图片
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImagePaths.length) {
      _selectedImagePaths.removeAt(index);
      notifyListeners();
    }
  }

  /// 添加属性
  void addAttribute(String key, String value) {
    if (key.isNotEmpty && value.isNotEmpty) {
      _currentAttributes.add({'key': key, 'value': value});
      notifyListeners();
    }
  }

  /// 更新属性
  void updateAttribute(int index, String key, String value) {
    if (index >= 0 && index < _currentAttributes.length) {
      _currentAttributes[index] = {'key': key, 'value': value};
      notifyListeners();
    }
  }

  /// 删除属性
  void removeAttribute(int index) {
    if (index >= 0 && index < _currentAttributes.length) {
      _currentAttributes.removeAt(index);
      notifyListeners();
    }
  }

  /// 添加历史属性到当前属性
  void addHistoryAttribute(Map<String, String> attribute) {
    // 检查是否已存在相同的属性
    final exists = _currentAttributes.any((attr) => 
      attr['key'] == attribute['key'] && attr['value'] == attribute['value']);
    
    if (!exists) {
      _currentAttributes.add(Map<String, String>.from(attribute));
      notifyListeners();
    }
  }

  /// 创建标记点
  MarkPointEntity? createMarkPoint({
    required double latitude,
    required double longitude,
    double? altitude,
  }) {
    if (formKey.currentState?.validate() != true) {
      return null;
    }
    
    try {
      // 收集自定义属性
      final Map<String, String> attributes = {};
      for (var attribute in _currentAttributes) {
        final key = attribute['key'];
        final value = attribute['value'];
        if (key != null && key.isNotEmpty && value != null && value.isNotEmpty) {
          attributes[key] = value;
          
          // 保存属性到历史记录
          _addAttributeHistoryUseCase.execute(key, value);
        }
      }

      // 创建标记点实体
      return _createMarkPointUseCase.execute(
        name: nameController.text,
        latitude: latitude,
        longitude: longitude,
        elevation: elevationController.text.isNotEmpty 
            ? double.tryParse(elevationController.text) 
            : altitude,
        color: _selectedColor,
        attributes: attributes.isNotEmpty ? attributes : null,
        imagePaths: _selectedImagePaths.isNotEmpty ? _selectedImagePaths : null,
      );
    } catch (e) {
      _setError('创建标记点失败: $e');
      return null;
    }
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String error) {
    AppLogger.error(error);
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    elevationController.dispose();
    super.dispose();
  }
} 