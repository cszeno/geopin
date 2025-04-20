import '../../../../core/usecases/usecase.dart';
import '../entities/mark_point_entity.dart';
import '../repositories/mark_point_repository.dart';

/// 更新标记点用例
/// 
/// 位于领域层，实现标记点更新的业务逻辑。
/// 通过仓库接口与数据层交互，但不依赖具体实现。
class UpdateMarkPoint implements UseCase<bool, MarkPointEntity> {
  /// 标记点仓库依赖
  final MarkPointRepository repository;

  /// 构造函数
  /// 
  /// 注入标记点仓库依赖
  UpdateMarkPoint(this.repository);

  /// 执行更新标记点的业务逻辑
  /// 
  /// [params] 要更新的标记点实体
  /// 返回是否成功更新
  @override
  Future<bool> call(MarkPointEntity params) async {
    // 验证标记点数据的有效性
    _validateMarkPoint(params);
    
    // 调用仓库更新标记点
    return await repository.updateMarkPoint(params);
  }
  
  /// 验证标记点数据的有效性
  /// 
  /// 检查必填字段和数据格式
  void _validateMarkPoint(MarkPointEntity markPoint) {
    // 验证ID
    if (markPoint.id <= 0) {
      throw ArgumentError('标记点ID必须大于0');
    }
    
    // 验证名称
    if (markPoint.name.isEmpty) {
      throw ArgumentError('标记点名称不能为空');
    }
    
    // 验证坐标范围
    if (markPoint.latitude < -90 || markPoint.latitude > 90) {
      throw ArgumentError('纬度必须在-90到90度之间');
    }
    
    if (markPoint.longitude < -180 || markPoint.longitude > 180) {
      throw ArgumentError('经度必须在-180到180度之间');
    }
  }
} 