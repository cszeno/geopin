import '../repositories/location_repository.dart';

/// 停止位置更新的用例
class StopLocationUpdates {
  final LocationRepository _repository;

  /// 构造函数
  const StopLocationUpdates(this._repository);

  /// 执行用例
  /// 
  /// 返回是否成功停止
  Future<bool> call() async {
    return _repository.stopLocationUpdates();
  }
} 