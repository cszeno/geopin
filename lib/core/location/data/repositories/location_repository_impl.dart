import 'dart:async';

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
  Future<bool> initLocationService() async {
    try {
      return await _dataSource.initLocationService();
    } catch (e) {
      print('初始化位置服务失败: $e');
      return false;
    }
  }

  @override
  Future<bool> setLocationAccuracy(int accuracy) async {
    try {
      return await _dataSource.setLocationAccuracy(accuracy);
    } catch (e) {
      print('设置位置精度失败: $e');
      return false;
    }
  }

  @override
  Stream<Location> getLocationUpdates() {
    try {
      // 将数据源的Map转换为Location实体
      return _dataSource.startLocationUpdates().map((locationData) {
        try {
          return Location.fromMap(locationData);
        } catch (e) {
          print('解析位置数据失败: $e');
          throw Exception('解析位置数据失败: $e');
        }
      });
    } catch (e) {
      print('获取位置更新失败: $e');
      // 发生错误时返回空流
      return Stream.empty();
    }
  }

  @override
  Future<Location?> getLastLocation() async {
    try {
      final Map<String, dynamic>? locationData = await _dataSource.getLastLocation();
      
      if (locationData == null) {
        return null;
      }
      
      return Location.fromMap(locationData);
    } catch (e) {
      print('获取最后位置失败: $e');
      return null;
    }
  }

  @override
  Future<bool> stopLocationUpdates() async {
    try {
      return await _dataSource.stopLocationUpdates();
    } catch (e) {
      print('停止位置更新失败: $e');
      return false;
    }
  }
} 