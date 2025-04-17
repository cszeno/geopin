import 'dart:async';

import '../entities/location.dart';

/// 位置仓库接口
/// 
/// 定义与位置服务交互的方法
abstract class LocationRepository {
  /// 初始化位置服务
  /// 
  /// 返回是否成功初始化
  Future<bool> initLocationService();
  
  /// 设置位置精度
  /// 
  /// [accuracy] 精度级别: 0-低精度, 1-平衡精度, 2-高精度
  /// 返回是否设置成功
  Future<bool> setLocationAccuracy(int accuracy);
  
  /// 开始监听位置更新
  /// 
  /// 返回位置数据流
  Stream<Location> getLocationUpdates();
  
  /// 获取最后一次位置
  /// 
  /// 返回最后一次位置数据，如果无法获取返回null
  Future<Location?> getLastLocation();
  
  /// 停止位置更新
  /// 
  /// 返回是否成功停止
  Future<bool> stopLocationUpdates();
} 