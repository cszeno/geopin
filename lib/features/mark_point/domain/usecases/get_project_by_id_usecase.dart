import '../entities/mark_point_project_entity.dart';
import '../repositories/mark_point_project_repository.dart';

/// 根据ID获取项目用例
/// 
/// 负责处理根据ID获取特定项目的业务逻辑
class GetProjectByIdUseCase {
  /// 项目仓库
  final MarkPointProjectRepository repository;

  /// 构造函数
  GetProjectByIdUseCase(this.repository);

  /// 执行根据ID获取项目操作
  /// 
  /// [id] 项目的唯一标识
  /// 返回对应ID的项目，如果不存在则抛出异常
  Future<MarkPointProjectEntity> call(int id) async {
    return await repository.getProjectById(id);
  }
} 