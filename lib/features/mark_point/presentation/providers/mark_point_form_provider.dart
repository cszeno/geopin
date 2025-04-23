import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:geopin/core/utils/sp_util.dart';
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
  final SaveImageUseCase _saveImageUseCase = GetIt.I<SaveImageUseCase>();
  final GetSavedColorUseCase _getSavedColorUseCase = GetIt.I<GetSavedColorUseCase>();
  final SaveColorUseCase _saveColorUseCase = GetIt.I<SaveColorUseCase>();
  final GetAttributeHistoryUseCase _getAttributeHistoryUseCase = GetIt.I<GetAttributeHistoryUseCase>();
  final AddAttributeHistoryUseCase _addAttributeHistoryUseCase = GetIt.I<AddAttributeHistoryUseCase>();
  final CreateMarkPointUseCase _createMarkPointUseCase = GetIt.I<CreateMarkPointUseCase>();

  // 自动编号相关的键
  static const String _autoNumberingEnabledKey = 'auto_numbering_enabled';
  static const String _currentNumberKey = 'current_point_number';

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
  
  // 自动编号相关状态
  bool _autoNumberingEnabled = false;
  int _currentNumber = 1;

  // 构造函数
  MarkPointFormProvider() {
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
  
  // 自动编号getter
  bool get autoNumberingEnabled => _autoNumberingEnabled;

  /// 初始化加载数据
  Future<void> _loadData() async {
    _setLoading(true);
    try {
      // 加载已保存的颜色
      _selectedColor = await _getSavedColorUseCase.execute();
      
      // 加载历史属性
      _historyAttributes = await _getAttributeHistoryUseCase.execute();
      
      // 加载自动编号设置
      await _loadAutoNumberingSettings();
      
      // 如果启用了自动编号，自动应用到名称
      if (_autoNumberingEnabled && nameController.text.isEmpty) {
        _applyNumbering();
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('初始化数据失败: $e');
    }
  }

  /// 加载自动编号设置
  Future<void> _loadAutoNumberingSettings() async {
    try {
      final spUtil = SPUtil.I;
      _autoNumberingEnabled = spUtil.getBool(_autoNumberingEnabledKey) ?? false;
      _currentNumber = spUtil.getInt(_currentNumberKey) ?? 1;
    } catch (e) {
      AppLogger.error('加载自动编号设置失败: $e');
      // 使用默认值
      _autoNumberingEnabled = false;
      _currentNumber = 1;
    }
  }

  /// 设置自动编号状态
  Future<void> setAutoNumberingEnabled(bool enabled) async {
    try {
      _autoNumberingEnabled = enabled;
      notifyListeners();
      
      // 保存设置到SP
      await SPUtil.I.setBool(_autoNumberingEnabledKey, enabled);
      
      // 如果启用了自动编号且当前名称为空，应用编号
      if (enabled && nameController.text.isEmpty) {
        _applyNumbering();
      }
    } catch (e) {
      _setError('设置自动编号状态失败: $e');
    }
  }

  /// 应用当前编号到名称（公共方法）
  void applyCurrentNumbering() {
    if (_autoNumberingEnabled) {
      _applyNumbering();
    }
  }

  /// 应用编号到当前名称
  void _applyNumbering() {
    // 如果名称为空或者只有数字，直接设置为当前编号
    if (nameController.text.isEmpty || int.tryParse(nameController.text) != null) {
      nameController.text = "点$_currentNumber";
    } else {
      // 检查名称是否已经有数字后缀
      final RegExp numPattern = RegExp(r'(.+?)(\d+)$');
      final match = numPattern.firstMatch(nameController.text);
      
      if (match != null) {
        // 替换已有的数字后缀
        final baseName = match.group(1)!;
        nameController.text = baseName + _currentNumber.toString();
      } else {
        // 没有数字后缀，添加当前编号
        nameController.text = nameController.text + _currentNumber.toString();
      }
    }
  }

  /// 递增当前编号并保存
  Future<void> _incrementNumber() async {
    try {
      _currentNumber++;
      await SPUtil.I.setInt(_currentNumberKey, _currentNumber);
    } catch (e) {
      AppLogger.error('递增编号失败: $e');
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
      final markPoint = _createMarkPointUseCase.execute(
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
      
      // 如果启用了自动编号，递增编号
      if (_autoNumberingEnabled) {
        _incrementNumber();
      }
      
      return markPoint;
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