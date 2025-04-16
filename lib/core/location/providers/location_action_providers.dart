import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_providers.dart';
import 'location_service_manager.dart';

/// 位置精度调整回调函数
/// 
/// 提供给Feature层使用，不暴露内部实现细节
final locationAccuracyChangerProvider = Provider<void Function(int accuracy)>((ref) {
  return (int accuracy) {
    ref.read(locationServiceManagerProvider.notifier).changeAccuracy(accuracy);
  };
});

/// 位置服务重试初始化回调函数
/// 
/// 提供给Feature层使用，不暴露内部实现细节
final locationRetryProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(locationServiceManagerProvider.notifier).retryInitialization();
  };
}); 