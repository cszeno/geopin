import 'dart:async';

/// 位置数据源接口
/// 
/// 定义与原生位置服务交互的方法
abstract class LocationDataSource {
  /// 初始化位置服务
  /// 
  /// 返回是否成功初始化
  Future<bool> initLocationService();
  
  /// 设置位置精度
  /// 
  /// [accuracy] 精度级别: 0-低精度, 1-平衡精度, 2-高精度
  /// 返回设置是否成功
  Future<bool> setLocationAccuracy(int accuracy);
  
  /// 开始监听位置更新
  /// 
  /// 返回位置数据流
  Stream<Map<String, dynamic>> startLocationUpdates();
  
  /// 获取最后一次位置
  /// 
  /// 返回位置数据
  Future<Map<String, dynamic>?> getLastLocation();
  
  /// 停止位置更新
  /// 
  /// 返回是否成功停止
  Future<bool> stopLocationUpdates();
} 