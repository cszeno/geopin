import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/mark_point_entity.dart';
import '../widgets/attribute_tag_widget.dart';
import '../widgets/color_picker_widget.dart';
import '../widgets/image_preview_widget.dart';
import '../providers/mark_point_form_provider.dart';

/// 标记点表单屏幕
/// 
/// 使用Clean Architecture重构后的标记点表单界面
class MarkPointFormPage extends StatelessWidget {
  /// 当前位置的纬度
  final double latitude;
  
  /// 当前位置的经度
  final double longitude;
  
  /// 当前位置的高程
  final double altitude;
  
  /// 表单提交回调函数
  final Function(MarkPointEntity) onSubmit;
  
  /// 构造函数
  const MarkPointFormPage({
    super.key,
    required this.latitude, 
    required this.longitude, 
    required this.onSubmit,
    this.altitude = 0
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MarkPointFormProvider>(
      create: (context) => GetIt.instance<MarkPointFormProvider>(),
      child: Consumer<MarkPointFormProvider>(
        builder: (context, provider, _) {
          return _MarkPointFormView(
            provider: provider,
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            onSubmit: onSubmit,
          );
        },
      ),
    );
  }
}

/// 标记点表单视图
class _MarkPointFormView extends StatelessWidget {
  final MarkPointFormProvider provider;
  final double latitude;
  final double longitude;
  final double altitude;
  final Function(MarkPointEntity) onSubmit;

  const _MarkPointFormView({
    super.key,
    required this.provider,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // 获取设备尺寸以适配不同屏幕
    final size = MediaQuery.of(context).size;
    
    return Container(
      // 高度限制
      constraints: BoxConstraints(maxHeight: size.height * 0.8),
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
              onPressed: () => _submitForm(context),
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
        body: Stack(
          children: [
            GestureDetector(
              // 点击空白处关闭键盘
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: Form(
                key: provider.formKey,
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
                      // 名称输入框
                      TextFormField(
                        controller: provider.nameController,
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

                      // 显示当前坐标
                      _buildCoordinatesSection(context),
                      
                      const SizedBox(height: 16),
                      
                      // 颜色选择器
                      _buildColorPickerSection(context),
                      
                      const SizedBox(height: 16),

                      // 自定义属性部分
                      _buildAttributesSection(context),

                      const SizedBox(height: 16),

                      // 图片选择部分
                      _buildImagePreviewSection(context),
                    ],
                  ),
                ),
              ),
            ),
            
            // 加载指示器
            if (provider.isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建坐标信息区域
  Widget _buildCoordinatesSection(BuildContext context) {
    return Container(
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
                  latitude.toStringAsFixed(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  context, 
                  '经度', 
                  longitude.toStringAsFixed(6),
                ),
              ),
              if (altitude != 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    '高程',
                    altitude.toStringAsFixed(6),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  /// 构建颜色选择器区域
  Widget _buildColorPickerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                color: provider.selectedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ColorPickerWidget(
          selectedColor: provider.selectedColor,
          availableColors: provider.availableColors,
          onColorSelected: (color) => provider.selectColor(color),
        ),
      ],
    );
  }

  /// 构建图片预览区域
  Widget _buildImagePreviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '图片',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ImagePreviewWidget(
          selectedImagePaths: provider.selectedImagePaths,
          onAddImage: () => _showImageSourceDialog(context),
          onRemoveImage: (index) => provider.removeImage(index),
        ),
      ],
    );
  }

  /// 构建属性区域
  Widget _buildAttributesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '自定义属性',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              onPressed: () => _showAttributeEditDialog(context),
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
        const SizedBox(height: 8),
        
        // 当前属性标签
        if (provider.currentAttributes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '暂无自定义属性',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(provider.currentAttributes.length, (index) {
              final attribute = provider.currentAttributes[index];
              return AttributeTagWidget(
                keyText: attribute['key'] ?? '',
                valueText: attribute['value'] ?? '',
                isActive: true,
                onTap: () => _showAttributeOptions(context, index),
              );
            }),
          ),
          
        // 历史属性标签
        if (provider.historyAttributes.isNotEmpty) ...[
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
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.historyAttributes.map((attr) {
              final key = attr['key'] ?? '';
              final value = attr['value'] ?? '';
              
              // 检查当前属性列表中是否已存在相同属性
              final isAlreadyAdded = provider.currentAttributes.any(
                (currentAttr) => currentAttr['key'] == key && currentAttr['value'] == value
              );
              
              return AttributeTagWidget(
                keyText: key,
                valueText: value,
                isActive: !isAlreadyAdded,
                onTap: isAlreadyAdded 
                    ? null 
                    : () => provider.addHistoryAttribute(attr),
              );
            }).toList(),
          ),
        ],
      ],
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
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 提交表单
  void _submitForm(BuildContext context) {
    final markPoint = provider.createMarkPoint(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
    );
    
    if (markPoint != null) {
      onSubmit(markPoint);
      Navigator.of(context).pop();
    }
  }

  /// 显示图片来源选择对话框
  void _showImageSourceDialog(BuildContext context) {
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
                  provider.pickImage(ImageSource.camera);
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
                  provider.pickImage(ImageSource.gallery);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示属性编辑对话框
  void _showAttributeEditDialog(BuildContext context, {
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
                if (editIndex != null) {
                  provider.updateAttribute(editIndex, trimmedKey, trimmedValue);
                } else {
                  provider.addAttribute(trimmedKey, trimmedValue);
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// 显示属性选项菜单（编辑/删除）
  void _showAttributeOptions(BuildContext context, int index) {
    // 提前获取属性信息，避免在回调中访问可能已变更的数据
    final attribute = provider.currentAttributes[index];
    
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
                if (index < provider.currentAttributes.length) {
                  _showAttributeEditDialog(
                    context,
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
                provider.removeAttribute(index);
              },
            ),
          ],
        ),
      ),
    );
  }
} 