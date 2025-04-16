import '../../../utils/result.dart';
import '../repositories/location_repository.dart';

/// 初始化位置服务的用例类
class InitializeLocationService {
  final LocationRepository _repository;

  /// 构造函数
  const InitializeLocationService(this._repository);

  /// 执行用例
  /// 
  /// 1. 检查并请求位置权限
  /// 2. 初始化位置服务
  /// 3. 设置位置精度
  /// 
  /// [accuracy] 精度级别: 0-低精度, 1-平衡精度, 2-高精度 (默认高精度)
  /// 返回初始化结果
  Future<Result<bool>> call({int accuracy = 2}) async {
    // 请求权限
    final permissionResult = await _repository.requestLocationPermission();
    if (permissionResult.isFailure) {
      return permissionResult;
    }

    if (permissionResult.data == false) {
      return permissionResult;
    }

    // 初始化服务
    final initResult = await _repository.initLocationService();
    if (initResult.isFailure) {
      return initResult;
    }

    // 设置精度
    return _repository.setLocationAccuracy(accuracy);
  }
} 