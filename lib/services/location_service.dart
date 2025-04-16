import 'dart:async';
import 'package:flutter/services.dart';

/// 高精度位置服务类
/// 通过平台通道与原生代码交互获取高精度位置信息
class LocationService {
  // 定义平台通道
  static const MethodChannel _methodChannel = MethodChannel('cn.geopin.geopin/location_method');
  static const EventChannel _eventChannel = EventChannel('cn.geopin.geopin/location_event');

  // 位置流控制器
  StreamController<Map<String, dynamic>>? _locationController;
  
  // 位置数据流
  Stream<Map<String, dynamic>>? _locationStream;

  // 单例模式
  static final LocationService _instance = LocationService._internal();
  
  factory LocationService() {
    return _instance;
  }
  
  LocationService._internal();

  /// 检查位置权限
  /// 返回是否已获得权限
  Future<bool> checkLocationPermission() async {
    try {
      final bool hasPermission = await _methodChannel.invokeMethod('checkLocationPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      print('检查位置权限失败: ${e.message}');
      return false;
    }
  }

  /// 请求位置权限
  /// 返回是否获得权限
  Future<bool> requestLocationPermission() async {
    try {
      final bool granted = await _methodChannel.invokeMethod('requestLocationPermission');
      return granted;
    } on PlatformException catch (e) {
      print('请求位置权限失败: ${e.message}');
      return false;
    }
  }

  /// 初始化位置服务
  /// 返回是否成功初始化
  Future<bool> initLocationService() async {
    try {
      // 调用原生方法初始化位置服务
      final bool result = await _methodChannel.invokeMethod('initLocationService');
      return result;
    } on PlatformException catch (e) {
      print('初始化位置服务失败: ${e.message}');
      return false;
    }
  }

  /// 开始监听位置变化
  /// 返回位置数据流
  Stream<Map<String, dynamic>> startLocationUpdates() {
    if (_locationStream == null) {
      // 创建位置流控制器
      _locationController = StreamController<Map<String, dynamic>>.broadcast();
      
      // 监听原生事件通道
      _eventChannel.receiveBroadcastStream().listen((dynamic event) {
        // 将原生数据转换为Map
        final Map<String, dynamic> locationData = Map<String, dynamic>.from(event);
        _locationController?.add(locationData);
      }, onError: (dynamic error) {
        _locationController?.addError('位置监听错误: $error');
      });
      
      _locationStream = _locationController?.stream;
    }
    
    return _locationStream!;
  }

  /// 停止位置更新
  Future<bool> stopLocationUpdates() async {
    try {
      // 调用原生方法停止位置服务
      final bool result = await _methodChannel.invokeMethod('stopLocationService');
      
      // 关闭流控制器
      await _locationController?.close();
      _locationController = null;
      _locationStream = null;
      
      return result;
    } on PlatformException catch (e) {
      print('停止位置服务失败: ${e.message}');
      return false;
    }
  }

  /// 设置位置更新精度
  /// [accuracy] 精度级别: 0-低, 1-平衡, 2-高
  Future<bool> setLocationAccuracy(int accuracy) async {
    try {
      // 调用原生方法设置精度
      final bool result = await _methodChannel.invokeMethod(
        'setLocationAccuracy', 
        {'accuracy': accuracy}
      );
      return result;
    } on PlatformException catch (e) {
      print('设置位置精度失败: ${e.message}');
      return false;
    }
  }

  /// 获取最后一次位置
  Future<Map<String, dynamic>?> getLastLocation() async {
    try {
      // 调用原生方法获取最后位置
      final Map<dynamic, dynamic>? result = await _methodChannel.invokeMethod('getLastLocation');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } on PlatformException catch (e) {
      print('获取最后位置失败: ${e.message}');
      return null;
    }
  }
} 