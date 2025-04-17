import '../entities/location.dart';
import '../repositories/location_repository.dart';

/// 获取最后一次位置的用例
class GetLastLocation {
  final LocationRepository _repository;

  /// 构造函数
  const GetLastLocation(this._repository);

  /// 执行用例
  /// 
  /// 返回最后一次位置数据，如果无法获取返回null
  Future<Location?> call() async {
    return _repository.getLastLocation();
  }
} 