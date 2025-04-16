import 'package:flutter/foundation.dart';

/// 失败处理基类
abstract class Failure {
  /// 失败消息
  final String message;
  
  /// 构造函数
  const Failure({required this.message});
}

/// 位置服务失败
class LocationFailure extends Failure {
  /// 构造函数
  const LocationFailure({required super.message});
  
  /// 位置权限未授予失败
  factory LocationFailure.permissionDenied() {
    return const LocationFailure(message: '未获得位置权限，请在设置中开启位置服务和应用权限');
  }
  
  /// 位置服务初始化失败
  factory LocationFailure.serviceInitFailed() {
    return const LocationFailure(message: '位置服务初始化失败');
  }
  
  /// 位置服务不可用
  factory LocationFailure.serviceUnavailable() {
    return const LocationFailure(message: '位置服务不可用，请检查设备设置');
  }
  
  /// 通用错误
  factory LocationFailure.general({required String message}) {
    return LocationFailure(message: message);
  }
} 