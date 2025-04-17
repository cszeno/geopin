import 'dart:async';
import 'package:flutter/services.dart';

import 'location_data_source.dart';

/// 通过平台通道实现的位置数据源
class PlatformLocationDataSource implements LocationDataSource {
  // 定义平台通道
  static const MethodChannel _methodChannel = MethodChannel('cn.geopin.geopin/location_method');
  static const EventChannel _eventChannel = EventChannel('cn.geopin.geopin/location_event');

  // 位置流控制器
  StreamController<Map<String, dynamic>>? _locationController;
  
  // 位置数据流
  Stream<Map<String, dynamic>>? _locationStream;

  // 平台事件流订阅
  StreamSubscription? _platformStreamSubscription;

  // 单例模式
  static final PlatformLocationDataSource _instance = PlatformLocationDataSource._internal();
  
  factory PlatformLocationDataSource() {
    return _instance;
  }
  
  PlatformLocationDataSource._internal();

  // 跟踪初始化状态
  bool _isInitialized = false;

  @override
  Future<bool> checkLocationPermission() async {
    try {
      final bool hasPermission = await _methodChannel.invokeMethod('checkLocationPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      print('检查位置权限失败: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      final bool granted = await _methodChannel.invokeMethod('requestLocationPermission');
      return granted;
    } on PlatformException catch (e) {
      print('请求位置权限失败: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> initLocationService() async {
    try {
      // 如果已经初始化过，避免重复初始化
      if (_isInitialized) {
        return true;
      }
      
      final bool result = await _methodChannel.invokeMethod('initLocationService');
      
      if (result) {
        _isInitialized = true;
      }
      
      return result;
    } on PlatformException catch (e) {
      print('初始化位置服务失败: ${e.message}');
      return false;
    }
  }

  @override
  Stream<Map<String, dynamic>> startLocationUpdates() {
    // 确保旧的流和订阅被清理
    _cleanupStreams();
    
    // 创建位置流控制器
    _locationController = StreamController<Map<String, dynamic>>.broadcast(
      onListen: _startListeningPlatformEvents,
      onCancel: _cleanupStreams,
    );
    
    _locationStream = _locationController?.stream;
    return _locationStream!;
  }
  
  /// 开始监听平台事件
  void _startListeningPlatformEvents() {
    try {
      _platformStreamSubscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event != null) {
            // 将原生数据转换为Map
            final Map<String, dynamic> locationData = Map<String, dynamic>.from(event);
            _locationController?.add(locationData);
          }
        },
        onError: (dynamic error) {
          print('位置事件通道错误: $error');
          _locationController?.addError('位置监听错误: $error');
          
          // 在出错后尝试重新建立连接
          _restartLocationService();
        },
        onDone: () {
          // 如果底层平台通道结束，尝试重新初始化
          print('位置事件通道已关闭，尝试重新初始化');
          _isInitialized = false;
          _restartLocationService();
        },
      );
    } catch (e) {
      print('开始监听位置事件失败: $e');
      _locationController?.addError('开始监听位置事件失败: $e');
    }
  }
  
  /// 清理流和订阅
  void _cleanupStreams() {
    _platformStreamSubscription?.cancel();
    _platformStreamSubscription = null;
  }
  
  /// 在连接中断后重新启动位置服务
  Future<void> _restartLocationService() async {
    _isInitialized = false;
    
    try {
      // 短暂延迟后尝试重新初始化
      await Future.delayed(const Duration(seconds: 2));
      
      if (_locationController != null && !_locationController!.isClosed) {
        final bool initialized = await initLocationService();
        if (!initialized) {
          _locationController?.addError('重新初始化位置服务失败');
        }
      }
    } catch (e) {
      print('重新启动位置服务失败: $e');
      _locationController?.addError('重新启动位置服务失败: $e');
    }
  }

  @override
  Future<bool> stopLocationUpdates() async {
    try {
      final bool result = await _methodChannel.invokeMethod('stopLocationService');
      
      // 关闭流控制器
      _cleanupStreams();
      _locationController?.close();
      _locationController = null;
      _locationStream = null;
      _isInitialized = false;
      
      return result;
    } on PlatformException catch (e) {
      print('停止位置服务失败: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> setLocationAccuracy(int accuracy) async {
    try {
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

  @override
  Future<Map<String, dynamic>?> getLastLocation() async {
    try {
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