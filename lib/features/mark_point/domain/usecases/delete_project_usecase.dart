import '../repositories/mark_point_project_repository.dart';

/// 删除项目用例
/// 
/// 负责处理删除项目的业务逻辑
class DeleteProjectUseCase {
  /// 项目仓库
  final MarkPointProjectRepository repository;

  /// 构造函数
  DeleteProjectUseCase(this.repository);

  /// 执行删除项目操作
  /// 
  /// [id] 要删除的项目ID
  /// 返回是否删除成功
  Future<bool> call(int id) async {
    return await repository.deleteProject(id);
  }
} 