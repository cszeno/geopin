import '../entities/mark_point_project_entity.dart';
import '../repositories/mark_point_project_repository.dart';

/// 添加项目用例
/// 
/// 负责处理添加新项目的业务逻辑
class AddProjectUseCase {
  /// 项目仓库
  final MarkPointProjectRepository repository;

  /// 构造函数
  AddProjectUseCase(this.repository);

  /// 执行添加项目操作
  /// 
  /// [projectEntity] 要添加的项目实体
  /// 返回新添加的项目ID
  Future<int> call(MarkPointProjectEntity projectEntity) async {
    return await repository.addProject(projectEntity);
  }
} 