import '../entities/mark_point_project_entity.dart';
import '../repositories/mark_point_project_repository.dart';

/// 更新项目用例
/// 
/// 负责处理更新已有项目的业务逻辑
class UpdateProjectUseCase {
  /// 项目仓库
  final MarkPointProjectRepository repository;

  /// 构造函数
  UpdateProjectUseCase(this.repository);

  /// 执行更新项目操作
  /// 
  /// [projectEntity] 包含更新内容的项目实体
  /// 返回是否更新成功
  Future<bool> call(MarkPointProjectEntity projectEntity) async {
    return await repository.updateProject(projectEntity);
  }
} 