import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../../../core/utils/sp_util.dart';
import '../../domain/entities/mark_point_entity.dart';

/// 标记点表单底部弹窗
/// 
/// 一个美观现代的底部滑动表单，用于收集用户输入的标记点信息
/// 包含名称、经纬度等基本信息以及可选的附加属性
class MarkerPointFormSheet extends StatefulWidget {
  /// 当前位置的纬度
  final double latitude;
  
  /// 当前位置的经度
  final double longitude;

  /// 当前位置的高程
  final double altitude;
  
  /// 表单提交回调函数
  final Function(MarkPointEntity) onSubmit;
  
  /// 构造函数
  const MarkerPointFormSheet({
    super.key, 
    required this.latitude, 
    required this.longitude,
    required this.onSubmit,
    this.altitude = 0
  });

  @override
  State<MarkerPointFormSheet> createState() => _MarkerPointFormSheetState();
}

class _MarkerPointFormSheetState extends State<MarkerPointFormSheet> {
  /// SharedPreferences键名，用于存储用户选择的颜色
  static const String _colorPreferenceKey = 'mark_point_selected_color';
  
  /// SharedPreferences键名，用于存储用户历史属性
  static const String _historyAttributesKey = 'mark_point_history_attributes';
  
  /// 表单全局键，用于验证
  final _formKey = GlobalKey<FormState>();
  
  /// 名称控制器
  final _nameController = TextEditingController();
  
  /// 海拔控制器（可选）
  final _elevationController = TextEditingController();
  
  /// 选择的颜色
  Color _selectedColor = Colors.red; // 默认颜色，将在initState中尝试加载上次的选择
  
  /// 可选的颜色列表
  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];

  /// 当前编辑的自定义属性列表 - 改为Map<String, String>存储键值对
  final List<Map<String, String>> _currentAttributes = [];
  
  /// 历史属性列表
  List<Map<String, String>> _historyAttributes = [];
  
  /// 已选择的图片路径列表
  List<String> _selectedImagePaths = [];
  
  /// 图片选择器
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedColor();
    _loadHistoryAttributes();
  }

  /// 从SharedPreferences加载上次选择的颜色
  Future<void> _loadSavedColor() async {
    final spUtil = SPUtil();
    if (!spUtil.isInitialized) {
      await spUtil.init();
    }
    
    // 获取保存的颜色值（整数表示的ARGB值）
    final savedColorValue = spUtil.getInt(_colorPreferenceKey);
    
    if (savedColorValue != null) {
      setState(() {
        _selectedColor = Color(savedColorValue);
      });
    }
  }
  
  /// 加载历史属性
  Future<void> _loadHistoryAttributes() async {
    final spUtil = SPUtil();
    if (!spUtil.isInitialized) {
      await spUtil.init();
    }
    
    final historyAttributes = spUtil.getMapStringList(_historyAttributesKey);
    
    setState(() {
      _historyAttributes = historyAttributes;
    });
  }
  
  /// 保存历史属性
  Future<void> _saveHistoryAttribute(String key, String value) async {
    // 检查是否已存在相同键值对
    bool exists = false;
    for (var attr in _historyAttributes) {
      if (attr['key'] == key && attr['value'] == value) {
        exists = true;
        break;
      }
    }
    
    if (!exists) {
      final spUtil = SPUtil();
      if (!spUtil.isInitialized) {
        await spUtil.init();
      }
      
      // 添加到历史列表
      final newHistory = List<Map<String, String>>.from(_historyAttributes);
      newHistory.add({'key': key, 'value': value});
      
      // 如果历史记录太多，保留最近的20条
      if (newHistory.length > 20) {
        newHistory.removeAt(0);
      }
      
      // 更新内存和存储
      setState(() {
        _historyAttributes = newHistory;
      });
      
      await spUtil.setMapStringList(_historyAttributesKey, newHistory);
    }
  }
  
  /// 保存选择的颜色到SharedPreferences
  Future<void> _saveSelectedColor(Color color) async {
    // 保存颜色的整数值（ARGB）
    await SPUtil().setInt(_colorPreferenceKey, color.toARGB32());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _elevationController.dispose();
    // 不再需要清理String类型的属性
    super.dispose();
  }

  /// 添加新的自定义属性
  void _addAttribute() {
    _showAttributeEditDialog();
  }

  /// 显示属性编辑弹窗，使用更简单的输入方法
  void _showAttributeEditDialog({
    String initialKey = '',
    String initialValue = '',
    int? editIndex,
  }) {
    // 使用直接的文本编辑对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // 内部状态控制
        String key = initialKey;
        String value = initialValue;
        
        return AlertDialog(
          title: Text(editIndex != null ? '编辑属性' : '添加属性'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                // 属性名称输入
                TextFormField(
                  initialValue: initialKey,
                  decoration: const InputDecoration(
                    labelText: '属性名',
                    hintText: '输入属性名',
                  ),
                  onChanged: (text) => key = text,
                ),
                const SizedBox(height: 16),
                // 属性值输入
                TextFormField(
                  initialValue: initialValue,
                  decoration: const InputDecoration(
                    labelText: '属性值',
                    hintText: '输入属性值',
                  ),
                  onChanged: (text) => value = text,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('保存'),
              onPressed: () {
                final trimmedKey = key.trim();
                final trimmedValue = value.trim();
                
                if (trimmedKey.isEmpty || trimmedValue.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('属性名和属性值不能为空')),
                  );
                  return;
                }
                
                // 先关闭对话框
                Navigator.of(dialogContext).pop();
                
                // 然后更新状态
                setState(() {
                  if (editIndex != null) {
                    _currentAttributes[editIndex] = {'key': trimmedKey, 'value': trimmedValue};
                  } else {
                    _currentAttributes.add({'key': trimmedKey, 'value': trimmedValue});
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  /// 提交表单
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 收集自定义属性
      final Map<String, String> attributes = {};
      for (var attribute in _currentAttributes) {
        final key = attribute['key'];
        final value = attribute['value'];
        if (key != null && key.isNotEmpty && value != null && value.isNotEmpty) {
          attributes[key] = value;
          
          // 保存属性到历史记录
          _saveHistoryAttribute(key, value);
        }
      }

      // 创建标记点实体
      final markPoint = MarkPointEntity(
        id: DateTime.now().millisecondsSinceEpoch, // 临时ID，实际应由数据库生成
        uuid: const Uuid().v1(),
        name: _nameController.text,
        latitude: widget.latitude,
        longitude: widget.longitude,
        elevation: _elevationController.text.isNotEmpty 
            ? double.tryParse(_elevationController.text) 
            : null,
        color: _selectedColor,
        attributes: attributes.isNotEmpty ? attributes : null,
        imgPath: _selectedImagePaths.isNotEmpty ? _selectedImagePaths : null,
      );

      // 调用回调函数
      widget.onSubmit(markPoint);
      
      // 关闭弹窗
      Navigator.of(context).pop();
    }
  }
  
  /// 选择图片
  Future<void> _pickImage(ImageSource source) async {
    try {
      AppLogger.debug('开始选择图片，来源: ${source == ImageSource.camera ? "相机" : "相册"}');
      
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      AppLogger.debug('图片选择结果: ${image != null ? "成功" : "取消"}');
      
      if (image != null) {
        AppLogger.debug('选择的图片路径: ${image.path}');
        
        // 复制图片到应用内部目录
        final String savedImagePath = await _saveImageToAppDirectory(image.path);
        AppLogger.debug('保存后的图片路径: $savedImagePath');
        
        setState(() {
          _selectedImagePaths.add(savedImagePath);
        });
      } else {
        // 用户取消了选择
        AppLogger.debug('用户取消了图片选择');
      }
    } catch (e) {
      AppLogger.error('选择图片失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('选择图片失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// 将图片保存到应用内部目录
  Future<String> _saveImageToAppDirectory(String imagePath) async {
    try {
      // 获取应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      // 创建图片存储目录
      final imageDir = Directory('${appDir.path}/mark_point_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      // 生成唯一的文件名
      final fileName = '${const Uuid().v4()}${path.extension(imagePath)}';
      final targetPath = '${imageDir.path}/$fileName';
      
      // 复制图片到应用目录
      final File sourceFile = File(imagePath);
      await sourceFile.copy(targetPath);
      AppLogger.debug('保存图片成功🏅: $e');
      return targetPath;
    } catch (e) {
      AppLogger.error('保存图片到应用目录失败: $e');
      // 如果保存失败，返回原路径
      return imagePath;
    }
  }
  
  /// 显示图片选择对话框
  void _showImageSourceDialog() {
    AppLogger.debug('显示图片来源选择对话框');
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('拍摄照片'),
              onTap: () {
                AppLogger.debug('用户选择拍摄照片');
                Navigator.pop(context);
                // 添加延迟，确保底部菜单完全关闭
                Future.delayed(const Duration(milliseconds: 100), () {
                  _pickImage(ImageSource.camera);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                AppLogger.debug('用户选择从相册选择');
                Navigator.pop(context);
                // 添加延迟，确保底部菜单完全关闭
                Future.delayed(const Duration(milliseconds: 100), () {
                  _pickImage(ImageSource.gallery);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// 移除选中的图片
  void _removeImage(int index) {
    setState(() {
      _selectedImagePaths.removeAt(index);
    });
  }
  
  /// 构建图片预览区域
  Widget _buildImagePreview() {
    if (_selectedImagePaths.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: GestureDetector(
            onTap: _showImageSourceDialog,
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '已选择 ${_selectedImagePaths.length} 张图片',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add_photo_alternate,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _showImageSourceDialog,
              tooltip: '添加更多图片',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImagePaths.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(_selectedImagePaths[index])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
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
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取设备尺寸以适配不同屏幕
    final size = MediaQuery.of(context).size;
    
    return Container(
      // 高度限制
      constraints: BoxConstraints(maxHeight: size.height * 0.6),
      // 圆角装饰
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias, // 裁剪超出圆角的部分
      child: Scaffold(
        // 自定义应用栏，固定在顶部
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false, // 不显示返回按钮
          centerTitle: true,
          title: Column(
            children: [
              // 顶部拖动条
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                '添加标记点',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            // 保存按钮放在右上角
            TextButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.save),
              label: const Text('保存'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        // 表单内容区
        body: GestureDetector(
          // 点击空白处关闭键盘
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 显示当前坐标
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '当前坐标',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                context, 
                                '纬度', 
                                widget.latitude.toStringAsFixed(6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoItem(
                                context, 
                                '经度', 
                                widget.longitude.toStringAsFixed(6),
                              ),
                            ),

                            /// 注意同步保存
                            if(widget.altitude != 0)
                              ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoItem(
                                    context,
                                    '高程',
                                    widget.altitude.toStringAsFixed(6),
                                  ),
                                ),
                              ]
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 名称输入框
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '标记点名称',
                      hintText: '输入标记点名称',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.pin_drop),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入标记点名称';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 12),

                  // 颜色选择器标题和选择器在同一行
                  Row(
                    children: [
                      Text(
                        '选择标记颜色',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      // 显示当前选中的颜色
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), 
                  _buildColorPicker(),
                  
                  const SizedBox(height: 16),
                  
                  // 图片选择部分
                  Text(
                    '图片',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildImagePreview(),
                  
                  const SizedBox(height: 16),
                  
                  // 自定义属性部分
                  ..._buildAttributeFields(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建信息项组件
  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2), // 减少间距
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 构建颜色选择器 - 改为横向滑动列表
  Widget _buildColorPicker() {
    return SizedBox(
      height: 50, // 固定高度
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // 横向滚动
        itemCount: _availableColors.length,
        itemBuilder: (context, index) {
          final color = _availableColors[index];
          // 使用颜色的value属性进行比较，确保比较的是颜色值而不是对象引用
          final isSelected = _selectedColor.toARGB32() == color.toARGB32();
          // AppLogger.debug("$isSelected = $_selectedColor == $color");
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
              // 保存用户选择的颜色
              _saveSelectedColor(color);
            },
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// 构建自定义属性区域
  List<Widget> _buildAttributeFields() {
    final List<Widget> widgets = [];
    
    // 标题和添加按钮
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '自定义属性',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ElevatedButton.icon(
            onPressed: _addAttribute,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加属性'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
    
    // 当前属性标签区域
    if (_currentAttributes.isEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '暂无自定义属性',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    } else {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_currentAttributes.length, (index) {
              final attribute = _currentAttributes[index];
              return _buildAttributeTag(
                attribute['key'] ?? '',
                attribute['value'] ?? '',
                onTap: () => _showAttributeOptions(index),
              );
            }),
          ),
        ),
      );
    }
    
    // 添加历史属性标签区域
    if (_historyAttributes.isNotEmpty) {
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              '历史属性',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            _buildHistoryAttributeTags(),
          ],
        ),
      );
    }
    
    return widgets;
  }
  
  /// 显示属性选项菜单（编辑/删除）
  void _showAttributeOptions(int index) {
    // 提前获取属性信息，避免在回调中访问可能已变更的数据
    final attribute = _currentAttributes[index];
    
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                // 先关闭底部菜单
                Navigator.pop(bottomSheetContext);
                
                // 然后打开编辑对话框
                if (index < _currentAttributes.length) {
                  _showAttributeEditDialog(
                    initialKey: attribute['key'] ?? '',
                    initialValue: attribute['value'] ?? '',
                    editIndex: index,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                // 先关闭底部菜单
                Navigator.pop(bottomSheetContext);
                
                // 然后执行删除操作
                if (index < _currentAttributes.length) {
                  setState(() {
                    _currentAttributes.removeAt(index);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建属性标签
  Widget _buildAttributeTag(String key, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$key: $value',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建历史属性标签
  Widget _buildHistoryAttributeTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _historyAttributes.map((attr) {
        final key = attr['key'] ?? '';
        final value = attr['value'] ?? '';
        
        // 检查当前属性列表中是否已存在相同属性
        bool isAlreadyAdded = _currentAttributes.any(
          (currentAttr) => currentAttr['key'] == key && currentAttr['value'] == value
        );
        
        // 如果已添加则显示灰色，否则可点击添加
        return GestureDetector(
          onTap: isAlreadyAdded ? null : () {
            // 添加到当前属性列表
            setState(() {
              _currentAttributes.add({'key': key, 'value': value});
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isAlreadyAdded 
                ? Colors.grey.withOpacity(0.1) 
                : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAlreadyAdded 
                  ? Colors.grey.withOpacity(0.3) 
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$key: $value',
                  style: TextStyle(
                    fontSize: 12,
                    color: isAlreadyAdded 
                      ? Colors.grey 
                      : Theme.of(context).colorScheme.secondary,
                  ),
                ),
                if (!isAlreadyAdded) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.add_circle_outline,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ]
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
