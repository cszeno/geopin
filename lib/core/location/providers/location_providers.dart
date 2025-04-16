import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/result.dart';
import '../data/datasources/platform_location_data_source.dart';
import '../data/repositories/location_repository_impl.dart';
import '../domain/entities/location.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/usecases/get_last_location.dart';
import '../domain/usecases/get_location_updates.dart';
import '../domain/usecases/initialize_location_service.dart';
import '../domain/usecases/set_location_accuracy.dart';
import '../domain/usecases/stop_location_updates.dart';

/// 位置数据源提供者
final locationDataSourceProvider = Provider<PlatformLocationDataSource>((ref) {
  return PlatformLocationDataSource();
});

/// 位置仓库提供者
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final dataSource = ref.watch(locationDataSourceProvider);
  return LocationRepositoryImpl(dataSource);
});

/// 初始化位置服务用例提供者
final initializeLocationServiceProvider = Provider<InitializeLocationService>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return InitializeLocationService(repository);
});

/// 获取位置更新用例提供者
final getLocationUpdatesProvider = Provider<GetLocationUpdates>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return GetLocationUpdates(repository);
});

/// 获取最后一次位置用例提供者
final getLastLocationProvider = Provider<GetLastLocation>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return GetLastLocation(repository);
});

/// 设置位置精度用例提供者
final setLocationAccuracyProvider = Provider<SetLocationAccuracy>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return SetLocationAccuracy(repository);
});

/// 停止位置更新用例提供者
final stopLocationUpdatesProvider = Provider<StopLocationUpdates>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return StopLocationUpdates(repository);
});

/// 位置流提供者
final locationStreamProvider = StreamProvider<Location>((ref) {
  final getLocationUpdates = ref.watch(getLocationUpdatesProvider);
  return getLocationUpdates().where((result) => result.isSuccess).map((result) => result.data!);
});

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

/// 位置服务状态提供者
final locationServiceStatusProvider = StateProvider<LocationServiceStatus>((ref) {
  return LocationServiceStatus.uninitialized;
});

/// 位置服务错误消息提供者
final locationErrorMessageProvider = StateProvider<String?>((ref) {
  return null;
});

/// 位置精度提供者 (0-低, 1-平衡, 2-高)
final locationAccuracyProvider = StateProvider<int>((ref) {
  return 2; // 默认高精度
});

/// 最后一次位置提供者
final lastLocationProvider = FutureProvider<Location?>((ref) async {
  final getLastLocation = ref.watch(getLastLocationProvider);
  final Result<Location> result = await getLastLocation();
  
  if (result.isSuccess) {
    return result.data;
  }
  
  return null;
}); 