import '../../../../core/usecases/usecase.dart';
import '../entities/mark_point_entity.dart';
import '../repositories/mark_point_repository.dart';

/// 根据ID获取标记点用例
/// 
/// 位于领域层，实现根据ID获取特定标记点的业务逻辑。
/// 通过仓库接口与数据层交互，但不依赖具体实现。
class GetMarkPointById implements UseCase<MarkPointEntity, int> {
  /// 标记点仓库依赖
  final MarkPointRepository repository;

  /// 构造函数
  /// 
  /// 注入标记点仓库依赖
  GetMarkPointById(this.repository);

  /// 执行根据ID获取标记点的业务逻辑
  /// 
  /// [params] 要获取的标记点ID
  /// 返回对应ID的标记点实体，如果不存在则抛出异常
  @override
  Future<MarkPointEntity> call(int params) async {
    // 验证ID的有效性
    if (params <= 0) {
      throw ArgumentError('标记点ID必须大于0');
    }
    
    // 调用仓库获取标记点
    return await repository.getMarkPointById(params);
  }
} 