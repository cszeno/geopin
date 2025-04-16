import '../../../utils/result.dart';
import '../entities/location.dart';
import '../repositories/location_repository.dart';

/// 获取最后一次位置的用例
class GetLastLocation {
  final LocationRepository _repository;

  /// 构造函数
  const GetLastLocation(this._repository);

  /// 执行用例
  /// 
  /// 返回最后一次位置的结果
  Future<Result<Location>> call() async {
    return _repository.getLastLocation();
  }
} 