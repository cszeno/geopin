import '../entities/mark_point_entity.dart';

/// 标记点仓库接口
/// 
/// 定义了标记点数据操作的标准方法
abstract class MarkPointRepository {
  /// 获取所有标记点
  /// 
  /// 返回所有已保存的标记点列表
  Future<List<MarkPointEntity>> getAllMarkPoints();

  /// 通过项目Id返回所有已保存的标记点列表
  Future<List<MarkPointEntity>> getAllMarkPointsById(String projectUUID);
  
  /// 根据ID获取特定标记点
  /// 
  /// [id] 标记点的唯一标识
  /// 返回对应ID的标记点，如果不存在则抛出异常
  Future<MarkPointEntity> getMarkPointById(int id);
  
  /// 添加新标记点
  /// 
  /// [markPointEntity] 要添加的标记点实体
  /// 返回新添加的标记点ID
  Future<int> addMarkPoint(MarkPointEntity markPointEntity);
  
  /// 更新已有标记点
  /// 
  /// [markPointEntity] 包含更新内容的标记点实体
  /// 返回是否更新成功
  Future<bool> updateMarkPoint(MarkPointEntity markPointEntity);
  
  /// 删除标记点
  /// 
  /// [id] 要删除的标记点ID
  /// 返回是否删除成功
  Future<bool> deleteMarkPoint(int id);
  
  /// 搜索标记点
  /// 
  /// [keyword] 搜索关键词
  /// 返回符合搜索条件的标记点列表
  Future<List<MarkPointEntity>> searchMarkPoints(String keyword);
}