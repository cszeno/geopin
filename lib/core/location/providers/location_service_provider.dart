import 'dart:async';

import 'package:flutter/material.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/entities/location.dart';

/// 位置状态枚举
enum LocationServiceStatus {
  /// 未初始化
  uninitialized,
  
  /// 初始化中
  initializing,
  
  /// 已初始化，监听中
  active,
  
  /// 发生错误
  error
}

/// 位置服务提供者
class LocationServiceProvider with ChangeNotifier, WidgetsBindingObserver {
  final LocationRepository _repository;
  
  // 位置服务状态
  LocationServiceStatus _serviceStatus = LocationServiceStatus.uninitialized;
  LocationServiceStatus get serviceStatus => _serviceStatus;

  // 错误消息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 位置精度 (0-低, 1-平衡, 2-高)
  int _accuracyLevel = 2; // 默认高精度
  int get accuracyLevel => _accuracyLevel;
  
  // 位置流
  StreamController<Location>? _locationStreamController;
  Stream<Location>? _locationStream;
  Stream<Location>? get locationStream => _locationStream;
  
  // 当前位置
  Location? _currentLocation;
  Location? get currentLocation => _currentLocation;
  
  // 初始化超时时间
  static const _initTimeoutDuration = Duration(seconds: 15);
  
  // 初始化计时器
  Timer? _initTimeoutTimer;
  
  // 位置流订阅
  StreamSubscription? _locationSubscription;
  
  /// 构造函数
  LocationServiceProvider(this._repository) {
    // 注册生命周期监听
    WidgetsBinding.instance.addObserver(this);
    
    // 应用启动时自动初始化位置服务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeLocationService();
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopLocationService();
    _cancelInitTimeout();
    _locationStreamController?.close();
    _locationSubscription?.cancel();
    super.dispose();
  }
  
  /// 处理应用生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用恢复前台时，检查位置服务状态
        if (_serviceStatus != LocationServiceStatus.active) {
          initializeLocationService();
        } else {
          // 如果已经活跃，请求一次最新位置
          _requestImmediateUpdate();
        }
        break;
      case AppLifecycleState.paused:
        // 应用进入后台时，可以选择性地暂停位置服务以节省电量
        // 这里保持活跃以确保位置跟踪持续进行
        break;
      default:
        break;
    }
  }
  
  /// 请求立即更新位置
  Future<void> _requestImmediateUpdate() async {
    try {
      final location = await _repository.getLastLocation();
      if (location != null) {
        _updateLocation(location);
      }
    } catch (e) {
      // 忽略错误，不影响主流程
      debugPrint('请求立即更新位置失败: $e');
    }
  }

  /// 初始化位置服务
  Future<void> initializeLocationService() async {
    // 重置错误状态
    _errorMessage = null;
    
    // 如果已经是活跃状态，无需重复初始化
    if (_serviceStatus == LocationServiceStatus.active) {
      return;
    }
    
    // 更新状态为初始化中
    _serviceStatus = LocationServiceStatus.initializing;
    notifyListeners();
    
    // 设置初始化超时
    _initTimeoutTimer?.cancel();
    _initTimeoutTimer = Timer(_initTimeoutDuration, () {
      if (_serviceStatus == LocationServiceStatus.initializing) {
        // 初始化超时，设置为错误状态
        _serviceStatus = LocationServiceStatus.error;
        _errorMessage = '位置服务初始化超时，请重试';
        notifyListeners();
      }
    });
    
    try {
      // 初始化服务
      final initialized = await _repository.initLocationService();
      if (!initialized) {
        _serviceStatus = LocationServiceStatus.error;
        _errorMessage = '位置服务初始化失败';
        _cancelInitTimeout();
        notifyListeners();
        return;
      }

      // 设置精度
      await _repository.setLocationAccuracy(_accuracyLevel);

      // 尝试预热获取一次位置以确保流程正常
      final lastLocation = await _repository.getLastLocation();
      if (lastLocation != null) {
        _updateLocation(lastLocation);
      }
      
      // 启动位置监听
      _startLocationUpdates();
      
      _serviceStatus = LocationServiceStatus.active;
      _cancelInitTimeout();
      notifyListeners();
      
    } catch (e) {
      // 处理异常
      _serviceStatus = LocationServiceStatus.error;
      _errorMessage = '初始化位置服务出错: $e';
      _cancelInitTimeout();
      notifyListeners();
    }
  }
  
  /// 启动位置更新监听
  void _startLocationUpdates() {
    // 如果已有流控制器，先关闭
    _locationStreamController?.close();
    _locationSubscription?.cancel();
    
    // 创建新的流控制器
    _locationStreamController = StreamController<Location>.broadcast();
    _locationStream = _locationStreamController?.stream;
    
    // 订阅位置更新
    _locationSubscription = _repository.getLocationUpdates().listen(
      (location) {
        _updateLocation(location);
      },
      onError: (error) {
        _errorMessage = '位置更新出错: $error';
        notifyListeners();
      }
    );
  }
  
  /// 更新位置并通知监听器
  void _updateLocation(Location location) {
    _currentLocation = location;
    
    // 添加到流中
    _locationStreamController?.add(location);
    
    // 通知监听器UI需要更新
    notifyListeners();
  }

  /// 取消初始化超时计时器
  void _cancelInitTimeout() {
    _initTimeoutTimer?.cancel();
    _initTimeoutTimer = null;
  }

  /// 更改位置精度
  Future<void> changeAccuracy(int accuracy) async {
    if (_accuracyLevel == accuracy) return;
    
    // 更新精度状态
    _accuracyLevel = accuracy;
    notifyListeners();
    
    try {
      // 调用设置精度
      final success = await _repository.setLocationAccuracy(accuracy);
      
      if (!success) {
        _errorMessage = '设置位置精度失败';
        notifyListeners();
      } else {
        // 精度变更后立即请求位置更新
        _requestImmediateUpdate();
      }
    } catch (e) {
      _errorMessage = '设置位置精度失败: $e';
      notifyListeners();
    }
  }

  /// 停止位置服务
  Future<void> stopLocationService() async {
    try {
      // 调用停止位置更新
      await _repository.stopLocationUpdates();
      
      // 取消订阅
      _locationSubscription?.cancel();
      _locationSubscription = null;
      
      // 更新状态
      _serviceStatus = LocationServiceStatus.uninitialized;
      notifyListeners();
    } catch (e) {
      _errorMessage = '停止位置服务失败: $e';
      notifyListeners();
    }
  }
  
  /// 重试初始化位置服务
  Future<void> retryInitialization() async {
    await initializeLocationService();
  }
  
  /// 获取最后一次位置
  Future<Location?> getLastLocation() async {
    try {
      final location = await _repository.getLastLocation();
      // 如果成功获取位置，更新当前状态
      if (location != null) {
        _updateLocation(location);
      }
      return location;
    } catch (e) {
      _errorMessage = '获取最后位置失败: $e';
      notifyListeners();
      return null;
    }
  }
} 