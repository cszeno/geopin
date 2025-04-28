import '../entities/mark_point_project_entity.dart';
import '../repositories/mark_point_project_repository.dart';

/// 获取所有项目用例
/// 
/// 负责处理获取所有项目的业务逻辑
class GetProjectsUseCase {
  /// 项目仓库
  final MarkPointProjectRepository repository;

  /// 构造函数
  GetProjectsUseCase(this.repository);

  /// 执行获取所有项目操作
  /// 
  /// 返回所有已保存的项目列表
  Future<List<MarkPointProjectEntity>> call() async {
    return await repository.getAllProjects();
  }
} 