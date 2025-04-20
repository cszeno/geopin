import '../../../../core/usecases/usecase.dart';
import '../entities/mark_point_entity.dart';
import '../repositories/mark_point_repository.dart';

/// 搜索标记点用例
/// 
/// 位于领域层，实现标记点搜索的业务逻辑。
/// 通过仓库接口与数据层交互，但不依赖具体实现。
class SearchMarkPoints implements UseCase<List<MarkPointEntity>, String> {
  /// 标记点仓库依赖
  final MarkPointRepository repository;

  /// 构造函数
  /// 
  /// 注入标记点仓库依赖
  SearchMarkPoints(this.repository);

  /// 执行搜索标记点的业务逻辑
  /// 
  /// [params] 搜索关键词
  /// 返回符合搜索条件的标记点实体列表
  @override
  Future<List<MarkPointEntity>> call(String params) async {
    if (params.isEmpty) {
      // 如果关键词为空，返回所有标记点
      return await repository.getAllMarkPoints();
    } else {
      // 否则执行搜索
      return await repository.searchMarkPoints(params);
    }
  }
} 