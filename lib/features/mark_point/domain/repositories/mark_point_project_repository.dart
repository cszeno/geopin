import '../entities/mark_point_project_entity.dart';

/// 标记点项目仓库接口
/// 
/// 定义了标记点项目数据操作的标准方法
abstract class MarkPointProjectRepository {
  /// 获取所有项目
  ///
  /// 返回所有已保存的项目列表
  Future<List<MarkPointProjectEntity>> getAllProjects();
  
  /// 根据ID获取特定项目
  /// 
  /// [id] 项目的唯一标识
  /// 返回对应ID的项目，如果不存在则抛出异常
  Future<MarkPointProjectEntity> getProjectById(int id);
  
  /// 添加新项目
  /// 
  /// [projectEntity] 要添加的项目实体
  /// 返回新添加的项目ID
  Future<int> addProject(MarkPointProjectEntity projectEntity);
  
  /// 更新已有项目
  /// 
  /// [projectEntity] 包含更新内容的项目实体
  /// 返回是否更新成功
  Future<bool> updateProject(MarkPointProjectEntity projectEntity);
  
  /// 删除项目
  /// 
  /// [id] 要删除的项目ID
  /// 返回是否删除成功
  Future<bool> deleteProject(int id);
  
  /// 搜索项目
  /// 
  /// [keyword] 搜索关键词
  /// 返回符合搜索条件的项目列表
  Future<List<MarkPointProjectEntity>> searchProjects(String keyword);
} 