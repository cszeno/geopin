import 'package:get_it/get_it.dart';

import '../../domain/entities/mark_point_entity.dart';
import '../../domain/repositories/mark_point_repository.dart';
import '../datasources/mark_point_local_data_source.dart';
import '../models/mark_point_model.dart';

/// 标记点仓库实现类
/// 
/// 位于数据层，实现领域层定义的仓库接口。
/// 负责协调数据源和模型转换，为领域层提供所需的数据。
/// 负责数据的CRUD操作，并确保数据的一致性。
class MarkPointRepositoryImpl implements MarkPointRepository {
  /// 本地数据源
  final MarkPointLocalDataSource localDataSource = GetIt.I<MarkPointLocalDataSource>();

  /// 构造函数
  MarkPointRepositoryImpl();

  @override
  Future<int> addMarkPoint(MarkPointEntity markPointEntity) async {
    // 转换为数据模型
    final model = MarkPointModel.fromEntity(markPointEntity);
    
    // 调用数据源方法添加标记点
    return await localDataSource.insertMarkPoint(model);
  }

  @override
  Future<bool> deleteMarkPoint(int id) async {
    // 调用数据源方法删除标记点
    return await localDataSource.deleteMarkPoint(id);
  }

  @override
  Future<List<MarkPointEntity>> getAllMarkPoints() async {
    // 获取所有标记点模型
    final models = await localDataSource.getAllMarkPoints();
    
    // 转换为实体列表并返回
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<MarkPointEntity>> getAllMarkPointsById(String projectUUID) async {
    // 获取所有标记点模型
    final models = await localDataSource.getAllMarkPointsByProjectUUID(projectUUID);

    // 转换为实体列表并返回
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<MarkPointEntity> getMarkPointById(int id) async {
    // 获取指定ID的标记点模型
    final model = await localDataSource.getMarkPointById(id);
    
    // 转换为实体并返回
    return model.toEntity();
  }

  @override
  Future<List<MarkPointEntity>> searchMarkPoints(String keyword) async {
    // 搜索标记点模型
    final models = await localDataSource.searchMarkPoints(keyword);
    
    // 转换为实体列表并返回
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> updateMarkPoint(MarkPointEntity markPointEntity) async {
    // 转换为数据模型
    final model = MarkPointModel.fromEntity(markPointEntity);
    
    // 调用数据源方法更新标记点
    return await localDataSource.updateMarkPoint(model);
  }
}