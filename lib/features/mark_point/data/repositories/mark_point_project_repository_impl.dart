import 'package:get_it/get_it.dart';

import '../../domain/entities/mark_point_project_entity.dart';
import '../../domain/repositories/mark_point_project_repository.dart';
import '../datasources/mark_point_project_local_data_source.dart';
import '../models/mark_point_project_model.dart';

/// 标记点项目仓库实现类
/// 
/// 位于数据层，实现领域层定义的项目仓库接口。
/// 负责协调数据源和模型转换，为领域层提供所需的数据。
/// 负责项目的CRUD操作，并确保数据的一致性。
class MarkPointProjectRepositoryImpl implements MarkPointProjectRepository {
  /// 本地数据源
  final MarkPointProjectLocalDataSource localDataSource = GetIt.I<MarkPointProjectLocalDataSource>();

  /// 构造函数
  MarkPointProjectRepositoryImpl();

  @override
  Future<int> addProject(MarkPointProjectEntity projectEntity) async {
    // 转换为数据模型
    final model = MarkPointProjectModel.fromEntity(projectEntity);
    
    // 调用数据源方法添加项目
    return await localDataSource.insertProject(model);
  }

  @override
  Future<bool> deleteProject(int id) async {
    // 调用数据源方法删除项目
    return await localDataSource.deleteProject(id);
  }

  @override
  Future<List<MarkPointProjectEntity>> getAllProjects() async {
    // 获取所有项目模型
    final models = await localDataSource.getAllProjects();
    
    // 转换为实体列表并返回
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<MarkPointProjectEntity> getProjectById(int id) async {
    // 获取指定ID的项目模型
    final model = await localDataSource.getProjectById(id);
    
    // 转换为实体并返回
    return model.toEntity();
  }

  @override
  Future<List<MarkPointProjectEntity>> searchProjects(String keyword) async {
    // 搜索项目模型
    final models = await localDataSource.searchProjects(keyword);
    
    // 转换为实体列表并返回
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> updateProject(MarkPointProjectEntity projectEntity) async {
    // 转换为数据模型
    final model = MarkPointProjectModel.fromEntity(projectEntity);
    
    // 调用数据源方法更新项目
    return await localDataSource.updateProject(model);
  }
} 