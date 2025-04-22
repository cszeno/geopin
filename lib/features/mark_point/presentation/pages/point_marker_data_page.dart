import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:geopin/features/mark_point/domain/entities/mark_point_entity.dart';
import 'package:geopin/features/mark_point/presentation/providers/mark_point_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// 标记点数据展示页面
class MarkPointDataPage extends StatefulWidget {
  /// 构造函数
  const MarkPointDataPage({super.key});

  @override
  State<MarkPointDataPage> createState() => _MarkPointDataPageState();
}

class _MarkPointDataPageState extends State<MarkPointDataPage> {
  // 搜索关键词
  String _searchKeyword = '';

  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  // 标记点列表
  List<MarkPointEntity> _filteredPoints = [];

  // 是否正在加载
  bool _isLoading = false;

  // 排序列索引
  int? _sortColumnIndex;

  // 排序方向 (true: 升序, false: 降序)
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    // 在构建完成后加载数据，避免在构建过程中调用setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// 加载数据
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 从Provider获取标记点数据
      final provider = GetIt.I<MarkPointProvider>();
      await provider.loadAllMarkPoints();

      // 过滤数据
      _filterData();
    } catch (e) {
      AppLogger.error('加载标记点数据失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 过滤数据
  void _filterData() {
    final provider = GetIt.I<MarkPointProvider>();
    final allPoints = provider.points;

    if (_searchKeyword.isEmpty) {
      _filteredPoints = List.from(allPoints);
    } else {
      _filteredPoints =
          allPoints.where((point) {
            // 在名称和属性中搜索关键词
            final nameMatch = point.name.toLowerCase().contains(
              _searchKeyword.toLowerCase(),
            );

            // 在自定义属性中搜索
            bool attributeMatch = false;
            if (point.attributes != null) {
              attributeMatch = point.attributes!.values.any(
                (value) =>
                    value.toLowerCase().contains(_searchKeyword.toLowerCase()),
              );
            }

            return nameMatch || attributeMatch;
          }).toList();
    }

    // 应用排序
    if (_sortColumnIndex != null) {
      _sortData();
    }

    setState(() {});
  }

  /// 排序数据
  void _sortData() {
    if (_sortColumnIndex == null) return;

    _filteredPoints.sort((a, b) {
      dynamic valueA;
      dynamic valueB;

      // 根据排序列获取排序值
      switch (_sortColumnIndex) {
        case 0: // ID
          valueA = a.id;
          valueB = b.id;
          break;
        case 1: // 名称
          valueA = a.name;
          valueB = b.name;
          break;
        case 2: // 经度
          valueA = a.longitude;
          valueB = b.longitude;
          break;
        case 3: // 纬度
          valueA = a.latitude;
          valueB = b.latitude;
          break;
        case 4: // 海拔
          valueA = a.elevation ?? 0;
          valueB = b.elevation ?? 0;
          break;
        case 5: // 创建时间
          valueA = a.createdAt.millisecondsSinceEpoch;
          valueB = b.createdAt.millisecondsSinceEpoch;
          break;
        default:
          return 0;
      }

      // 根据排序方向比较值
      int result;
      if (valueA is String && valueB is String) {
        result = valueA.compareTo(valueB);
      } else if (valueA is num && valueB is num) {
        result = valueA.compareTo(valueB);
      } else {
        result = 0;
      }

      return _sortAscending ? result : -result;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听数据变化
    final markPointProvider = Provider.of<MarkPointProvider>(context);

    if (_filteredPoints.isEmpty &&
        !_isLoading &&
        markPointProvider.points.isNotEmpty) {
      _filteredPoints = markPointProvider.points;
    }

    return Scaffold(
      appBar: AppBar(title: Text("标记点数据")),
      body: Column(
        children: [
          // 标题和搜索栏
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '搜索标记点...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          suffixIcon:
                              _searchKeyword.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchKeyword = '';
                                      });
                                      _filterData();
                                    },
                                  )
                                  : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchKeyword = value;
                          });
                          _filterData();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 数据表格
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildDataTable(),
          ),
        ],
      ),
    );
  }

  /// 构建数据表格
  Widget _buildDataTable() {
    if (_filteredPoints.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '没有找到标记点数据',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.grey.withOpacity(0.2),
                dataTableTheme: DataTableThemeData(
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  dataTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                showCheckboxColumn: false,
                columnSpacing: 20,
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                ),
                headingRowHeight: 56,
                dataRowMaxHeight: 72,
                dataRowMinHeight: 56,
                horizontalMargin: 16,
                columns: [
                  DataColumn(
                    label: const Text('序号'),
                    tooltip: '序号',
                    onSort:
                        (columnIndex, ascending) => _handleSort(columnIndex),
                  ),
                  DataColumn(
                    label: const Text('名称'),
                    tooltip: '标记点名称',
                    onSort:
                        (columnIndex, ascending) => _handleSort(columnIndex),
                  ),
                  DataColumn(
                    label: const Text('经度'),
                    tooltip: '经度坐标',
                    numeric: true,
                    onSort:
                        (columnIndex, ascending) => _handleSort(columnIndex),
                  ),
                  DataColumn(
                    label: const Text('纬度'),
                    tooltip: '纬度坐标',
                    numeric: true,
                    onSort:
                        (columnIndex, ascending) => _handleSort(columnIndex),
                  ),
                  DataColumn(
                    label: const Text('海拔'),
                    tooltip: '海拔高度',
                    numeric: true,
                    onSort:
                        (columnIndex, ascending) => _handleSort(columnIndex),
                  ),
                  DataColumn(
                    label: const Text('创建时间'),
                    tooltip: '创建时间',
                    onSort:
                        (columnIndex, ascending) => _handleSort(columnIndex),
                  ),
                  const DataColumn(label: Text('图片'), tooltip: '关联图片数量'),
                  const DataColumn(label: Text('属性'), tooltip: '自定义属性数量'),
                ],
                rows:
                    _filteredPoints.map((point) {
                      final int index = _filteredPoints.indexOf(point);
                      return DataRow(
                        onSelectChanged: (_) => _viewDetail(point),
                        cells: [
                          DataCell(
                            Text(
                              '#$index',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: point.color ?? Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(point.name),
                              ],
                            ),
                          ),
                          DataCell(Text(point.longitude.toStringAsFixed(6))),
                          DataCell(Text(point.latitude.toStringAsFixed(6))),
                          DataCell(
                            Text(
                              point.elevation != null
                                  ? '${point.elevation!.toStringAsFixed(2)}米'
                                  : '-',
                            ),
                          ),
                          DataCell(
                            Text(
                              DateFormat(
                                'yyyy-MM-dd HH:mm',
                              ).format(point.createdAt),
                            ),
                          ),
                          DataCell(
                            Text(
                              point.imgPath == null || point.imgPath!.isEmpty
                                  ? '-'
                                  : '${point.imgPath!.length} 张',
                            ),
                          ),
                          DataCell(
                            Text(
                              point.attributes == null ||
                                      point.attributes!.isEmpty
                                  ? '-'
                                  : '${point.attributes!.length} 项',
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 处理排序
  void _handleSort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        // 同一列，切换排序方向
        _sortAscending = !_sortAscending;
      } else {
        // 不同列，设置新的排序列和默认排序方向
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }

      _sortData();
    });
  }

  /// 查看标记点详情
  void _viewDetail(MarkPointEntity point) {
    // TODO: 显示标记点详情底部弹窗
    AppLogger.debug('查看标记点详情: ${point.name}');
  }

  /// 编辑标记点
  void _editPoint(MarkPointEntity point) {
    // TODO: 显示编辑标记点表单
    AppLogger.debug('编辑标记点: ${point.name}');
  }

  /// 确认删除标记点
  void _confirmDelete(MarkPointEntity point) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除标记点 "${point.name}" 吗？这个操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _deletePoint(point);
                },
                child: const Text('删除'),
              ),
            ],
          ),
    );
  }

  /// 删除标记点
  Future<void> _deletePoint(MarkPointEntity point) async {
    final provider = GetIt.I<MarkPointProvider>();

    try {
      await provider.deletePoint(point.id);

      // 更新过滤后的列表
      setState(() {
        _filteredPoints.removeWhere((p) => p.id == point.id);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已删除标记点: ${point.name}')));
    } catch (e) {
      AppLogger.error('删除标记点失败: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
