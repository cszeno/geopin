import 'dart:async';

import 'package:flutter/material.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/entities/location.dart';
import '../../../core/utils/app_logger.dart';

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
/// 使用ChangeNotifier替代Riverpod实现状态管理
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
      AppLogger.info('位置服务开始初始化', loggerName: 'LocationService');
      initializeLocationService();
    });
  }
  
  @override
  void dispose() {
    AppLogger.debug('位置服务提供者销毁', loggerName: 'LocationService');
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
    AppLogger.debug('应用生命周期状态: $state', loggerName: 'LocationService');
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用恢复前台时，检查位置服务状态
        if (_serviceStatus != LocationServiceStatus.active) {
          AppLogger.info('应用恢复前台，初始化位置服务', loggerName: 'LocationService');
          initializeLocationService();
        } else {
          // 如果已经活跃，请求一次最新位置
          AppLogger.debug('应用恢复前台，请求最新位置', loggerName: 'LocationService');
          _requestImmediateUpdate();
        }
        break;
      case AppLifecycleState.paused:
        // 应用进入后台时，可以选择性地暂停位置服务以节省电量
        // 这里保持活跃以确保位置跟踪持续进行
        AppLogger.debug('应用进入后台，保持位置服务活跃', loggerName: 'LocationService');
        break;
      default:
        break;
    }
  }
  
  /// 请求立即更新位置
  Future<void> _requestImmediateUpdate() async {
    try {
      AppLogger.debug('请求立即更新位置', loggerName: 'LocationService');
      final location = await _repository.getLastLocation();
      if (location != null) {
        AppLogger.debug('获取到立即位置更新', loggerName: 'LocationService');
        _updateLocation(location);
      } else {
        AppLogger.debug('立即位置更新为空', loggerName: 'LocationService');
      }
    } catch (e) {
      // 忽略错误，不影响主流程
      AppLogger.warning('请求立即更新位置失败', error: e, loggerName: 'LocationService');
    }
  }

  /// 初始化位置服务
  Future<void> initializeLocationService() async {
    // 重置错误状态
    _errorMessage = null;
    
    // 如果已经是活跃状态，无需重复初始化
    if (_serviceStatus == LocationServiceStatus.active) {
      AppLogger.debug('位置服务已经活跃，跳过初始化', loggerName: 'LocationService');
      return;
    }
    
    // 更新状态为初始化中
    _serviceStatus = LocationServiceStatus.initializing;
    AppLogger.info('位置服务状态: 初始化中', loggerName: 'LocationService');
    notifyListeners();
    
    // 设置初始化超时
    _initTimeoutTimer?.cancel();
    _initTimeoutTimer = Timer(_initTimeoutDuration, () {
      if (_serviceStatus == LocationServiceStatus.initializing) {
        // 初始化超时，设置为错误状态
        _serviceStatus = LocationServiceStatus.error;
        _errorMessage = '位置服务初始化超时，请重试';
        AppLogger.error('位置服务初始化超时', loggerName: 'LocationService');
        notifyListeners();
      }
    });
    
    try {
      // 初始化服务
      final initialized = await _repository.initLocationService();
      if (!initialized) {
        _serviceStatus = LocationServiceStatus.error;
        _errorMessage = '位置服务初始化失败';
        AppLogger.error('位置服务初始化失败', loggerName: 'LocationService');
        _cancelInitTimeout();
        notifyListeners();
        return;
      }

      // 设置精度
      await _repository.setLocationAccuracy(_accuracyLevel);
      AppLogger.debug('设置位置精度: $_accuracyLevel', loggerName: 'LocationService');

      // 尝试预热获取一次位置以确保流程正常
      final lastLocation = await _repository.getLastLocation();
      if (lastLocation != null) {
        AppLogger.debug('获取到初始位置', loggerName: 'LocationService');
        _updateLocation(lastLocation);
      } else {
        AppLogger.debug('未获取到初始位置', loggerName: 'LocationService');
      }
      
      // 启动位置监听
      _startLocationUpdates();
      
      _serviceStatus = LocationServiceStatus.active;
      AppLogger.info('位置服务状态: 活跃', loggerName: 'LocationService');
      _cancelInitTimeout();
      notifyListeners();
      
    } catch (e) {
      // 处理异常
      _serviceStatus = LocationServiceStatus.error;
      _errorMessage = '初始化位置服务出错: $e';
      AppLogger.error('初始化位置服务出错', error: e, loggerName: 'LocationService');
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
    
    AppLogger.info('开始监听位置更新', loggerName: 'LocationService');
    
    // 订阅位置更新
    _locationSubscription = _repository.getLocationUpdates().listen(
      (location) {
        AppLogger.info('收到位置更新: 经度=${location.longitude}, 纬度=${location.latitude}, 高程=${location.altitude} 精度=${location.accuracy}米',
            loggerName: 'LocationService');
        _updateLocation(location);
      },
      onError: (error) {
        _errorMessage = '位置更新出错: $error';
        AppLogger.error('位置更新流发生错误', error: error, loggerName: 'LocationService');
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
    AppLogger.info('更改位置精度: $accuracy', loggerName: 'LocationService');
    notifyListeners();
    
    try {
      // 调用设置精度
      final success = await _repository.setLocationAccuracy(accuracy);
      
      if (!success) {
        _errorMessage = '设置位置精度失败';
        AppLogger.error('设置位置精度失败', loggerName: 'LocationService');
        notifyListeners();
      } else {
        // 精度变更后立即请求位置更新
        _requestImmediateUpdate();
      }
    } catch (e) {
      _errorMessage = '设置位置精度失败: $e';
      AppLogger.error('设置位置精度失败', error: e, loggerName: 'LocationService');
      notifyListeners();
    }
  }

  /// 停止位置服务
  Future<void> stopLocationService() async {
    try {
      // 调用停止位置更新
      AppLogger.info('停止位置服务', loggerName: 'LocationService');
      await _repository.stopLocationUpdates();
      
      // 取消订阅
      _locationSubscription?.cancel();
      _locationSubscription = null;
      
      // 更新状态
      _serviceStatus = LocationServiceStatus.uninitialized;
      notifyListeners();
    } catch (e) {
      _errorMessage = '停止位置服务失败: $e';
      AppLogger.error('停止位置服务失败', error: e, loggerName: 'LocationService');
      notifyListeners();
    }
  }
  
  /// 重试初始化位置服务
  Future<void> retryInitialization() async {
    AppLogger.info('重试初始化位置服务', loggerName: 'LocationService');
    await initializeLocationService();
  }
  
  /// 获取最后一次位置
  Future<Location?> getLastLocation() async {
    try {
      AppLogger.debug('获取最后一次位置', loggerName: 'LocationService');
      final location = await _repository.getLastLocation();
      // 如果成功获取位置，更新当前状态
      if (location != null) {
        AppLogger.debug('获取到最后位置', loggerName: 'LocationService');
        _updateLocation(location);
      } else {
        AppLogger.debug('最后位置为空', loggerName: 'LocationService');
      }
      return location;
    } catch (e) {
      _errorMessage = '获取最后位置失败: $e';
      AppLogger.error('获取最后位置失败', error: e, loggerName: 'LocationService');
      notifyListeners();
      return null;
    }
  }
} 