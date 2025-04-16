import 'dart:async';

import '../../../error/failures.dart';
import '../../../utils/result.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_data_source.dart';

/// 位置仓库实现
class LocationRepositoryImpl implements LocationRepository {
  /// 位置数据源
  final LocationDataSource _dataSource;

  /// 构造函数
  LocationRepositoryImpl(this._dataSource);

  @override
  Future<Result<bool>> checkLocationPermission() async {
    try {
      final bool hasPermission = await _dataSource.checkLocationPermission();
      return Result.success(hasPermission);
    } catch (e) {
      return Result.failure(
        LocationFailure.general(message: '检查位置权限失败: $e'),
      );
    }
  }

  @override
  Future<Result<bool>> requestLocationPermission() async {
    try {
      final bool granted = await _dataSource.requestLocationPermission();
      if (!granted) {
        return Result.failure(LocationFailure.permissionDenied());
      }
      return Result.success(true);
    } catch (e) {
      return Result.failure(
        LocationFailure.general(message: '请求位置权限失败: $e'),
      );
    }
  }

  @override
  Future<Result<bool>> initLocationService() async {
    try {
      final bool initialized = await _dataSource.initLocationService();
      if (!initialized) {
        return Result.failure(LocationFailure.serviceInitFailed());
      }
      return Result.success(true);
    } catch (e) {
      return Result.failure(
        LocationFailure.general(message: '初始化位置服务失败: $e'),
      );
    }
  }

  @override
  Future<Result<bool>> setLocationAccuracy(int accuracy) async {
    try {
      final bool success = await _dataSource.setLocationAccuracy(accuracy);
      return Result.success(success);
    } catch (e) {
      return Result.failure(
        LocationFailure.general(message: '设置位置精度失败: $e'),
      );
    }
  }

  @override
  Stream<Result<Location>> getLocationUpdates() {
    try {
      // 使用正确的方式处理流中的错误
      final stream = _dataSource.startLocationUpdates().map<Result<Location>>((locationData) {
        try {
          return Result.success(Location.fromMap(locationData));
        } catch (e) {
          return Result.failure(
            LocationFailure.general(message: '解析位置数据失败: $e'),
          );
        }
      });
      
      // 使用transform方法处理流中的错误
      return stream.transform(
        StreamTransformer<Result<Location>, Result<Location>>.fromHandlers(
          handleError: (error, stackTrace, sink) {
            // 将错误转换为失败的Result并添加到流中
            sink.add(Result.failure(
              error is LocationFailure
                  ? error
                  : LocationFailure.general(message: '位置更新错误: $error'),
            ));
          },
        ),
      );
    } catch (e) {
      // 创建只包含一个错误的流
      return Stream.value(
        Result.failure(
          LocationFailure.general(message: '启动位置更新失败: $e'),
        ),
      );
    }
  }

  @override
  Future<Result<Location>> getLastLocation() async {
    try {
      final Map<String, dynamic>? locationData = await _dataSource.getLastLocation();
      
      if (locationData == null) {
        return Result.failure(
          LocationFailure.general(message: '没有获取到位置信息'),
        );
      }
      
      return Result.success(Location.fromMap(locationData));
    } catch (e) {
      return Result.failure(
        LocationFailure.general(message: '获取最后位置失败: $e'),
      );
    }
  }

  @override
  Future<Result<bool>> stopLocationUpdates() async {
    try {
      final bool success = await _dataSource.stopLocationUpdates();
      return Result.success(success);
    } catch (e) {
      return Result.failure(
        LocationFailure.general(message: '停止位置更新失败: $e'),
      );
    }
  }
} 