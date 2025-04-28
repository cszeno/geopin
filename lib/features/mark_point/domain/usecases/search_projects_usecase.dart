import '../entities/mark_point_project_entity.dart';
import '../repositories/mark_point_project_repository.dart';

/// 搜索项目用例
/// 
/// 负责处理搜索项目的业务逻辑
class SearchProjectsUseCase {
  /// 项目仓库
  final MarkPointProjectRepository repository;

  /// 构造函数
  SearchProjectsUseCase(this.repository);

  /// 执行搜索项目操作
  /// 
  /// [keyword] 搜索关键词
  /// 返回符合搜索条件的项目列表
  Future<List<MarkPointProjectEntity>> call(String keyword) async {
    return await repository.searchProjects(keyword);
  }
} 