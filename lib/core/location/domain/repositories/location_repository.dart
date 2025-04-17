import 'dart:async';

import '../../../utils/result.dart';
import '../entities/location.dart';

/// 位置仓库接口
/// 
/// 定义与位置服务交互的方法
abstract class LocationRepository {
  /// 初始化位置服务
  /// 
  /// 返回初始化结果
  Future<Result<bool>> initLocationService();
  
  /// 设置位置精度
  /// 
  /// [accuracy] 精度级别: 0-低精度, 1-平衡精度, 2-高精度
  /// 返回设置结果
  Future<Result<bool>> setLocationAccuracy(int accuracy);
  
  /// 开始监听位置更新
  /// 
  /// 返回位置数据流
  Stream<Result<Location>> getLocationUpdates();
  
  /// 获取最后一次位置
  /// 
  /// 返回最后一次位置的结果
  Future<Result<Location>> getLastLocation();
  
  /// 停止位置更新
  /// 
  /// 返回停止结果
  Future<Result<bool>> stopLocationUpdates();
} 