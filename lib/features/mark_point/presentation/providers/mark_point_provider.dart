import 'package:flutter/material.dart';
import 'package:geopin/features/mark_point/domain/entities/mark_point_project_entity.dart';
import 'package:get_it/get_it.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:geopin/features/mark_point/domain/entities/mark_point_entity.dart';
import 'package:geopin/features/mark_point/domain/repositories/mark_point_repository.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/mark_point_project_repository.dart';

/// 标记点提供者
/// 
/// 管理标记点数据，提供UI层访问和操作标记点的能力
class MarkPointProvider with ChangeNotifier {
  
  /// 标记点仓库
  final MarkPointRepository _repositoryMarkPoint = GetIt.I<MarkPointRepository>();

  /// 标记点项目
  final MarkPointProjectRepository _repositoryMarkPointProject = GetIt.I<MarkPointProjectRepository>();

  /// 标记点列表
  List<MarkPointProjectEntity> _projects = [];
  
  /// 标记点列表
  List<MarkPointEntity> _points = [];
  
  /// 经纬度列表（用于地图显示）
  List<LatLng> _latLngs = [];
  
  /// 加载状态
  bool _isLoading = false;

  /// 当前选择的项目id, -1 为默认项目id
  String _projectUUID = "default-project";
  
  /// 错误信息
  String? _errorMessage;

  /// 构造函数
  MarkPointProvider() {
    // 加载项目（TODO：定义当前打开的项目）
    loadAllMarkPointProjects();
    // 初始化时加载所有标记点
    loadAllMarkPoints();
  }

  /// 获取当前打开的项目
  String get openedprojectUUID => _projectUUID;

  /// 获取项目列表
  List<MarkPointProjectEntity> get projects => _projects;

  /// 获取标记点列表
  List<MarkPointEntity> get points => _points;
  
  /// 获取经纬度列表
  List<LatLng> get latLngs => _latLngs;
  
  /// 获取加载状态
  bool get isLoading => _isLoading;
  
  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 加载所有标记点
  Future<void> loadAllMarkPoints() async {
    _setLoading(true);
    try {
      // 从仓库加载所有标记点
      _points = await _repositoryMarkPoint.getAllMarkPointsById(_projectUUID);
      
      // 更新经纬度列表
      _updateLatLngs();
      
      _setLoading(false);
    } catch (e) {
      _setError('加载标记点失败: $e');
    }
  }

  Future<void> loadAllMarkPointProjects() async {
    _setLoading(true);
    try {
      // 从仓库加载所有标记点
      _projects = await _repositoryMarkPointProject.getAllProjects();

      _setLoading(false);
    } catch (e) {
      _setError('加载项目失败: $e');
    }
  }

  /// 添加项目测试TODO完善
  ///
  Future<void> addProject(String name) async {
    try {
      await _repositoryMarkPointProject.addProject(MarkPointProjectEntity(id: -1, uuid: Uuid().v4(), name: name));
      // 添加项目后立即刷新项目列表
      await loadAllMarkPointProjects();
      notifyListeners();
    } catch (e) {
      _setError('添加标记点失败: $e');
    }
  }

  
  /// 添加标记点
  /// 
  /// 可接受 LatLng 对象或 MarkPointEntity 对象
  /// [pointData]: 标记点数据
  Future<void> addPoint(dynamic pointData) async {
    try {
      if (pointData is LatLng) {
        // 从LatLng创建并添加标记点
        await _addPointFromLatLng(pointData);
      } else if (pointData is MarkPointEntity) {
        // 直接添加MarkPointEntity
        await _addPointEntity(pointData);
      }
    } catch (e) {
      _setError('添加标记点失败: $e');
    }
  }
  
  /// 更新标记点
  /// 
  /// [markPoint]: 更新后的标记点实体
  Future<void> updatePoint(MarkPointEntity markPoint) async {
    _setLoading(true);
    try {
      // 调用仓库更新标记点
      final success = await _repositoryMarkPoint.updateMarkPoint(markPoint);
      
      if (success) {
        // 更新本地缓存
        final index = _points.indexWhere((p) => p.id == markPoint.id);
        if (index != -1) {
          _points[index] = markPoint;
          _updateLatLngs();
        }
        
        AppLogger.info('成功更新标记点: ${markPoint.name}');
      } else {
        _setError('更新标记点失败');
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('更新标记点失败: $e');
    }
  }
  
  /// 删除标记点
  /// 
  /// [id]: 要删除的标记点ID
  Future<void> deletePoint(int id) async {
    _setLoading(true);
    try {
      // 调用仓库删除标记点
      final success = await _repositoryMarkPoint.deleteMarkPoint(id);
      
      if (success) {
        // 从本地缓存移除
        _points.removeWhere((p) => p.id == id);
        _updateLatLngs();
        
        AppLogger.info('成功删除标记点 ID: $id');
      } else {
        _setError('删除标记点失败');
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('删除标记点失败: $e');
    }
  }
  
  /// 搜索标记点
  /// 
  /// [keyword]: 搜索关键词
  Future<List<MarkPointEntity>> searchPoints(String keyword) async {
    _setLoading(true);
    try {
      // 调用仓库搜索标记点
      final results = await _repositoryMarkPoint.searchMarkPoints(keyword);
      _setLoading(false);
      return results;
    } catch (e) {
      _setError('搜索标记点失败: $e');
      return [];
    }
  }

  /// 内部方法：从LatLng添加点
  Future<void> _addPointFromLatLng(LatLng latLng) async {
    // 创建新的标记点实体
    final newPoint = MarkPointEntity(
      id: DateTime.now().millisecondsSinceEpoch, // 临时ID
      uuid: const Uuid().v4(),
      name: "标记点 ${_points.length + 1}",
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
    
    // 调用仓库添加标记点
    final id = await _repositoryMarkPoint.addMarkPoint(newPoint);
    
    // 获取包含正确ID的新标记点
    final addedPoint = await _repositoryMarkPoint.getMarkPointById(id);
    
    // 更新本地缓存
    _points.add(addedPoint);
    _latLngs.add(latLng);
    
    AppLogger.info('添加了新标记点: ${addedPoint.name}, ID: $id');
    
    // 通知UI更新
    notifyListeners();
  }

  /// 内部方法：直接添加MarkPointEntity
  Future<void> _addPointEntity(MarkPointEntity markPoint) async {
    // 调用仓库添加标记点
    final id = await _repositoryMarkPoint.addMarkPoint(markPoint);
    
    // 获取包含正确ID的新标记点
    final addedPoint = await _repositoryMarkPoint.getMarkPointById(id);
    
    // 更新本地缓存
    _points.add(addedPoint);
    _latLngs.add(LatLng(addedPoint.latitude, addedPoint.longitude));
    
    AppLogger.info('添加了新标记点: ${addedPoint.name}, ID: $id');
    
    // 通知UI更新
    notifyListeners();
  }
  
  /// 更新经纬度列表
  void _updateLatLngs() {
    _latLngs = _points.map((p) => LatLng(p.latitude, p.longitude)).toList();
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

  /// 设置当前打开的项目
  set projectUUID(String value) {
    _projectUUID = value;
    loadAllMarkPoints();
  }
}
