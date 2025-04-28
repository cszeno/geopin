import 'package:flutter/material.dart';
import '../../../../core/utils/sp_util.dart';

/// 地图源模型类
class MapSource {
  final String name;
  final String urlTemplate;
  final bool isDefault;
  
  MapSource({
    required this.name,
    required this.urlTemplate,
    required this.isDefault,
  });
  
  Map<String, String> toMap() {
    return {
      'name': name,
      'urlTemplate': urlTemplate,
    };
  }
}

/// 地图源管理类
class MapSourceManager {
  // 存储地图源相关变量
  static const String _mapSourceKey = 'custom_map_sources';
  static const String _currentMapSourceKey = 'current_map_source';
  
  int _currentMapSourceIndex = 0;
  List<MapSource> _mapSources = [];
  
  // 获取当前地图源
  MapSource get currentMapSource => 
      _mapSources.isNotEmpty ? _mapSources[_currentMapSourceIndex] : _defaultMapSources.first;
      
  // 获取地图源列表  
  List<MapSource> get mapSources => _mapSources;
  
  // 获取当前索引
  int get currentMapSourceIndex => _currentMapSourceIndex;
  
  // 默认地图源
  final List<MapSource> _defaultMapSources = [
    MapSource(
      name: '高德矢量',
      urlTemplate: 'http://wprd04.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}',
      isDefault: true,
    ),
    MapSource(
      name: '高德路网',
      urlTemplate: 'https://wprd01.is.autonavi.com/appmaptile?x={x}&y={y}&z={z}&lang=zh_cn&size=1&scl=2&style=8&ltype=11',
      isDefault: true,
    ),
    MapSource(
      name: '高德影像',
      urlTemplate: 'http://wprd04.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}',
      isDefault: true,
    ),
    MapSource(
      name: '谷歌矢量',
      urlTemplate: 'http://mt2.google.cn/vt/lyrs=m&scale=2&hl=zh-CN&gl=cn&x={x}&y={y}&z={z}',
      isDefault: true,
    ),
    MapSource(
      name: '谷歌路网',
      urlTemplate: 'https://mt1.google.com/vt/lyrs=h&x={x}&y={y}&z={z}',
      isDefault: true,
    ),
    MapSource(
      name: '谷歌影像',
      urlTemplate: 'http://www.google.cn/maps/vt?lyrs=s@189&gl=cn&x={x}&y={y}&z={z}',
      isDefault: true,
    ),
    MapSource(
      name: 'OpenStreetMap',
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      isDefault: true,
    ),
  ];
  
  // 初始化地图源
  Future<void> initialize() async {
    // 确保 SPUtil 已初始化
    if (!SPUtil.I.isInitialized) {
      await SPUtil.I.init();
    }
    
    // 初始化默认地图源
    _mapSources = List.from(_defaultMapSources);
    
    // 加载自定义地图源
    _loadCustomMapSources();
    
    // 加载当前选择的地图源
    _loadCurrentMapSourceIndex();
  }
  
  // 加载自定义地图源
  void _loadCustomMapSources() {
    final customSources = SPUtil.I.getMapStringList(_mapSourceKey);
    if (customSources.isNotEmpty) {
      for (var source in customSources) {
        _mapSources.add(MapSource(
          name: source['name'] ?? '未命名地图源',
          urlTemplate: source['urlTemplate'] ?? '',
          isDefault: false,
        ));
      }
    }
  }
  
  // 加载当前地图源索引
  void _loadCurrentMapSourceIndex() {
    final index = SPUtil.I.getInt(_currentMapSourceKey);
    if (index != null && index < _mapSources.length) {
      _currentMapSourceIndex = index;
    }
  }
  
  // 设置当前地图源
  void setCurrentMapSource(int index) {
    if (index >= 0 && index < _mapSources.length) {
      _currentMapSourceIndex = index;
      SPUtil.I.setInt(_currentMapSourceKey, index);
    }
  }
  
  // 添加地图源
  void addMapSource(String name, String urlTemplate) {
    _mapSources.add(MapSource(
      name: name,
      urlTemplate: urlTemplate,
      isDefault: false,
    ));
    _saveCustomMapSources();
  }
  
  // 更新地图源
  void updateMapSource(int index, String name, String urlTemplate) {
    if (index >= 0 && index < _mapSources.length) {
      _mapSources[index] = MapSource(
        name: name,
        urlTemplate: urlTemplate,
        isDefault: _mapSources[index].isDefault,
      );
      _saveCustomMapSources();
    }
  }
  
  // 删除地图源
  void deleteMapSource(int index) {
    // 不允许删除默认地图源
    if (index < 0 || index >= _mapSources.length || _mapSources[index].isDefault) return;
    
    // 如果删除的是当前选中的地图源，切换到第一个地图源
    if (_currentMapSourceIndex == index) {
      _currentMapSourceIndex = 0;
      SPUtil.I.setInt(_currentMapSourceKey, 0);
    } else if (_currentMapSourceIndex > index) {
      // 如果删除的地图源在当前选中的地图源之前，需要调整索引
      _currentMapSourceIndex--;
      SPUtil.I.setInt(_currentMapSourceKey, _currentMapSourceIndex);
    }
    
    _mapSources.removeAt(index);
    _saveCustomMapSources();
  }
  
  // 保存自定义地图源到 SP
  void _saveCustomMapSources() {
    final customSources = _mapSources
        .where((source) => !source.isDefault)
        .map((source) => source.toMap())
        .toList();
    
    SPUtil.I.setMapStringList(_mapSourceKey, customSources);
  }
}

/// 地图源选择底部表单组件
class MapSourceSheet extends StatefulWidget {
  final MapSourceManager manager;
  final VoidCallback onMapSourceChanged;
  
  const MapSourceSheet({
    super.key,
    required this.manager,
    required this.onMapSourceChanged,
  });

  @override
  State<MapSourceSheet> createState() => _MapSourceSheetState();
}

class _MapSourceSheetState extends State<MapSourceSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部拖动条
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          // 标题栏
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '地图源管理',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.add, size: 18),
                  label: Text('添加地图源'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () => _showAddMapSourceDialog(context),
                ),
              ],
            ),
          ),
          
          Divider(height: 1),
          
          // 提示文本
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              '选择一个地图源作为当前底图，或添加自定义地图源',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          
          // 地图源列表
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              separatorBuilder: (context, index) => Divider(height: 1, indent: 70),
              itemCount: widget.manager.mapSources.length,
              itemBuilder: (context, index) {
                final source = widget.manager.mapSources[index];
                final isSelected = widget.manager.currentMapSourceIndex == index;
                
                return Card(
                  elevation: 0,
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSelected
                        ? BorderSide(color: Theme.of(context).primaryColor, width: 1)
                        : BorderSide.none,
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      widget.manager.setCurrentMapSource(index);
                      widget.onMapSourceChanged();
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // 地图预览图标
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.map,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          
                          // 地图源信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      source.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (source.isDefault)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '默认',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                      ),
                                    if (isSelected)
                                      Container(
                                        margin: EdgeInsets.only(left: 4),
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '已选择',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.green[800],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  source.urlTemplate,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 操作按钮
                          if (!source.isDefault) ...[
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: Colors.blue),
                              tooltip: '编辑',
                              onPressed: () => _showEditMapSourceDialog(context, index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: '删除',
                              onPressed: () => _showDeleteConfirmDialog(context, index),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 底部提示
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              '提示: 地图源URL格式通常为 https://tile.example.com/{z}/{x}/{y}.png',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 确认删除对话框
  void _showDeleteConfirmDialog(BuildContext context, int index) {
    final source = widget.manager.mapSources[index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要删除以下地图源吗？'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    source.urlTemplate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              widget.manager.deleteMapSource(index);
              setState(() {}); // 刷新界面
              Navigator.of(context).pop();
            },
            child: Text('删除'),
          ),
        ],
      ),
    );
  }
  
  // 显示添加地图源对话框
  void _showAddMapSourceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.add_location_alt, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('添加地图源'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxWidth: 500),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '自定义地图源将保存在本地，可随时切换使用',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '地图源名称',
                      hintText: '例如：我的地图源',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.title),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) => 
                      value == null || value.isEmpty ? '请输入地图源名称' : null,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'URL模板',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: urlController,
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: '例如：https://tile.example.com/{z}/{x}/{y}.png',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入URL模板';
                      }
                      if (!value.contains('{x}') || !value.contains('{y}') || !value.contains('{z}')) {
                        return 'URL必须包含 {x}, {y}, {z} 变量';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              '模板参数说明',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• {x}, {y} - 瓦片坐标\n• {z} - 缩放级别',
                          style: TextStyle(fontSize: 13),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '示例: https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.save),
            label: Text('保存'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                widget.manager.addMapSource(nameController.text, urlController.text);
                setState(() {}); // 刷新界面
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
  
  // 显示编辑地图源对话框
  void _showEditMapSourceDialog(BuildContext context, int index) {
    final source = widget.manager.mapSources[index];
    final nameController = TextEditingController(text: source.name);
    final urlController = TextEditingController(text: source.urlTemplate);
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_location_alt, color: Colors.blue),
            SizedBox(width: 8),
            Text('编辑地图源'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxWidth: 500),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '地图源名称',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.title),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) => 
                      value == null || value.isEmpty ? '请输入地图源名称' : null,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'URL模板',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: urlController,
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入URL模板';
                      }
                      if (!(value.contains('{x}') || value.contains('{-x}')) ||
                          !(value.contains('{y}') || value.contains('{-y}')) ||
                          !(value.contains('{z}') || value.contains('{-z}'))) {
                        return 'URL必须包含 {x}, {y}, {z} 变量';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              '模板参数说明',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• {x}, {y} - 瓦片坐标\n• {z} - 缩放级别',
                          style: TextStyle(fontSize: 13),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '示例: https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.save),
            label: Text('保存'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                widget.manager.updateMapSource(index, nameController.text, urlController.text);
                setState(() {}); // 刷新界面
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

/// 显示地图源选择底部表单
void showMapSourceSheet(
  BuildContext context, 
  MapSourceManager manager,
  VoidCallback onMapSourceChanged,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => MapSourceSheet(
      manager: manager,
      onMapSourceChanged: onMapSourceChanged,
    ),
  );
} 