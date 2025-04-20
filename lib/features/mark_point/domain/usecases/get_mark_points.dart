import '../../../../core/usecases/usecase.dart';
import '../entities/mark_point_entity.dart';
import '../repositories/mark_point_repository.dart';

/// 获取标记点列表用例
/// 
/// 位于领域层，实现获取所有标记点的业务逻辑。
/// 通过仓库接口与数据层交互，但不依赖具体实现。
class GetMarkPoints implements NoParamsUseCase<List<MarkPointEntity>> {
  /// 标记点仓库依赖
  final MarkPointRepository repository;

  /// 构造函数
  /// 
  /// 注入标记点仓库依赖
  GetMarkPoints(this.repository);

  /// 执行获取标记点列表的业务逻辑
  /// 
  /// 返回标记点实体列表
  @override
  Future<List<MarkPointEntity>> call() async {
    return await repository.getAllMarkPoints();
  }
} 