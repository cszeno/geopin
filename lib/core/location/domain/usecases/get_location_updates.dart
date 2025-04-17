import 'dart:async';

import '../entities/location.dart';
import '../repositories/location_repository.dart';

/// 获取位置更新的用例
class GetLocationUpdates {
  final LocationRepository _repository;

  /// 构造函数
  const GetLocationUpdates(this._repository);

  /// 执行用例
  /// 
  /// 返回位置数据流
  Stream<Location> call() {
    return _repository.getLocationUpdates();
  }
} 