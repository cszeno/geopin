import '../repositories/location_repository.dart';

/// 设置位置精度的用例
class SetLocationAccuracy {
  final LocationRepository _repository;

  /// 构造函数
  const SetLocationAccuracy(this._repository);

  /// 执行用例
  /// 
  /// [accuracy] 精度级别: 0-低精度, 1-平衡精度, 2-高精度
  /// 返回是否设置成功
  Future<bool> call(int accuracy) async {
    return _repository.setLocationAccuracy(accuracy);
  }
} 