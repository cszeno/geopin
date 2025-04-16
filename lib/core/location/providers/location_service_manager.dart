import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_providers.dart';

/// 位置服务管理器
/// 
/// 负责位置服务的初始化、监控和生命周期管理
/// 不对外暴露具体实现，只提供必要的管理功能
class LocationServiceManager extends AsyncNotifier<void> with WidgetsBindingObserver {
  // 初始化超时时间
  static const _initTimeoutDuration = Duration(seconds: 15);
  
  // 初始化计时器
  Timer? _initTimeoutTimer;
  
  @override
  Future<void> build() async {
    // 注册生命周期监听
    WidgetsBinding.instance.addObserver(this);
    
    // 应用启动时自动初始化位置服务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeLocationService();
    });
    
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      stopLocationService();
      _cancelInitTimeout();
    });
    
    return;
  }
  
  /// 处理应用生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用恢复前台时，检查位置服务状态
        final serviceStatus = ref.read(locationServiceStatusProvider);
        if (serviceStatus != LocationServiceStatus.active) {
          initializeLocationService();
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

  /// 初始化位置服务
  Future<void> initializeLocationService() async {
    // 重置错误状态
    ref.read(locationErrorMessageProvider.notifier).state = null;
    
    // 如果已经是活跃状态，无需重复初始化
    if (ref.read(locationServiceStatusProvider) == LocationServiceStatus.active) {
      return;
    }
    
    // 更新状态为初始化中
    ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.initializing;
    
    // 设置初始化超时
    _initTimeoutTimer?.cancel();
    _initTimeoutTimer = Timer(_initTimeoutDuration, () {
      if (ref.read(locationServiceStatusProvider) == LocationServiceStatus.initializing) {
        // 初始化超时，设置为错误状态
        ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.error;
        ref.read(locationErrorMessageProvider.notifier).state = '位置服务初始化超时，请重试';
      }
    });
    
    final initialAccuracy = ref.read(locationAccuracyProvider);
    
    try {
      // 先检查权限状态而不是直接请求权限
      final checkPermission = ref.read(locationRepositoryProvider).checkLocationPermission();
      final permissionResult = await checkPermission;
      
      if (permissionResult.isFailure || permissionResult.data == false) {
        // 权限不足，尝试请求权限
        final initService = ref.read(initializeLocationServiceProvider);
        final result = await initService(accuracy: initialAccuracy);
        
        if (result.isFailure) {
          // 更新错误状态
          ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.error;
          ref.read(locationErrorMessageProvider.notifier).state = result.error!.message;
          _cancelInitTimeout();
          return;
        }
      } else {
        // 已有权限，直接初始化服务
        final initResult = await ref.read(locationRepositoryProvider).initLocationService();
        if (initResult.isFailure) {
          ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.error;
          ref.read(locationErrorMessageProvider.notifier).state = initResult.error!.message;
          _cancelInitTimeout();
          return;
        }
        
        // 设置精度
        await ref.read(locationRepositoryProvider).setLocationAccuracy(initialAccuracy);
      }

      // iOS特定：尝试预热获取一次位置以确保流程正常
      await ref.read(locationRepositoryProvider).getLastLocation();
      
      // 启动位置监听
      ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.active;
      _cancelInitTimeout();
      
    } catch (e) {
      // 处理异常
      ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.error;
      ref.read(locationErrorMessageProvider.notifier).state = '初始化位置服务出错: $e';
      _cancelInitTimeout();
    }
  }

  /// 取消初始化超时计时器
  void _cancelInitTimeout() {
    _initTimeoutTimer?.cancel();
    _initTimeoutTimer = null;
  }

  /// 更改位置精度
  Future<void> changeAccuracy(int accuracy) async {
    if (ref.read(locationAccuracyProvider) == accuracy) return;
    
    // 更新精度状态
    ref.read(locationAccuracyProvider.notifier).state = accuracy;
    
    try {
      // 调用设置精度用例
      final setAccuracy = ref.read(setLocationAccuracyProvider);
      final result = await setAccuracy(accuracy);
      
      if (result.isFailure) {
        ref.read(locationErrorMessageProvider.notifier).state = result.error!.message;
      }
    } catch (e) {
      ref.read(locationErrorMessageProvider.notifier).state = '设置位置精度失败: $e';
    }
  }

  /// 停止位置服务
  Future<void> stopLocationService() async {
    try {
      // 调用停止位置更新用例
      final stopUpdates = ref.read(stopLocationUpdatesProvider);
      await stopUpdates();
      
      // 更新状态
      ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.uninitialized;
    } catch (e) {
      ref.read(locationErrorMessageProvider.notifier).state = '停止位置服务失败: $e';
    }
  }
  
  /// 重试初始化位置服务
  Future<void> retryInitialization() async {
    await initializeLocationService();
  }
}

/// 位置服务管理器提供者
final locationServiceManagerProvider = AsyncNotifierProvider<LocationServiceManager, void>(() {
  return LocationServiceManager();
}); 