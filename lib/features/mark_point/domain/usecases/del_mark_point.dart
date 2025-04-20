import '../../../../core/usecases/usecase.dart';
import '../repositories/mark_point_repository.dart';

/// 删除标记点用例
/// 
/// 位于领域层，实现标记点删除的业务逻辑。
/// 通过仓库接口与数据层交互，但不依赖具体实现。
class DelMarkPoint implements UseCase<bool, int> {
  /// 标记点仓库依赖
  final MarkPointRepository repository;

  /// 构造函数
  /// 
  /// 注入标记点仓库依赖
  DelMarkPoint(this.repository);

  /// 执行删除标记点的业务逻辑
  /// 
  /// [params] 要删除的标记点ID
  /// 返回是否成功删除
  @override
  Future<bool> call(int params) async {
    // 验证ID的有效性
    if (params <= 0) {
      throw ArgumentError('标记点ID必须大于0');
    }
    
    // 调用仓库删除标记点
    return await repository.deleteMarkPoint(params);
  }
}