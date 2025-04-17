import 'package:flutter/services.dart';
import 'package:geopin/core/constants/permission_constant.dart';
import 'package:geopin/core/utils/app_logger.dart';

class PermissionUtil {
  // 单例模式
  static final PermissionUtil _instance = PermissionUtil._internal();

  factory PermissionUtil() {
    return _instance;
  }

  PermissionUtil._internal();

  // 跟踪初始化状态
  bool _isInitialized = false;

  // 检查位置权限
  Future<bool> checkLocationPermission() async {
    try {
      final bool hasPermission = await PermissionConstant().methodChannel
          .invokeMethod('checkLocationPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      AppLogger.error('检查位置权限失败', error: e, loggerName: 'PermissionUtil');
      return false;
    }
  }


  // 请求位置权限
  Future<bool> requestLocationPermission() async {
    try {
      final bool granted = await PermissionConstant().methodChannel
          .invokeMethod('requestLocationPermission');
      return granted;
    } on PlatformException catch (e) {
      AppLogger.error('请求位置权限失败', error: e, loggerName: 'PermissionUtil');
      return false;
    }
  }
}