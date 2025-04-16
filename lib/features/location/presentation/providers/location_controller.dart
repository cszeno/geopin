import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/location/providers/location_providers.dart';

/// 位置控制器
/// 
/// 管理位置服务的状态和交互
class LocationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // 初始状态不需要执行任何操作
    return;
  }

  /// 初始化位置服务
  Future<void> initializeLocationService() async {
    // 更新状态为初始化中
    ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.initializing;
    ref.read(locationErrorMessageProvider.notifier).state = null;
    
    final initialAccuracy = ref.read(locationAccuracyProvider);
    
    try {
      // 调用初始化用例
      final initService = ref.read(initializeLocationServiceProvider);
      final result = await initService(accuracy: initialAccuracy);
      
      if (result.isFailure) {
        // 更新错误状态
        ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.error;
        ref.read(locationErrorMessageProvider.notifier).state = result.error!.message;
        return;
      }

      // 启动位置监听
      ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.active;
      
    } catch (e) {
      // 处理异常
      ref.read(locationServiceStatusProvider.notifier).state = LocationServiceStatus.error;
      ref.read(locationErrorMessageProvider.notifier).state = '初始化位置服务出错: $e';
    }
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
}

/// 位置控制器提供者
final locationControllerProvider = AsyncNotifierProvider<LocationController, void>(() {
  return LocationController();
}); 