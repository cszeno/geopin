import 'package:flutter/services.dart';

class AppConstant {
  // 私有静态实例
  static AppConstant? _instance;

  // 私有构造函数，放置外部实例化
  AppConstant._internal();

  // 工厂构造函数控制实例化逻辑
  factory AppConstant() {
    _instance ??= AppConstant._internal();
    return _instance!;
  }

  // 定义平台通道
  /// TODO: 独立一个原生权限
  static const MethodChannel _permissionMethodChannel = MethodChannel(
      'cn.geopin.geopin/location_method');

  static const MethodChannel _locationMethodChannel = MethodChannel(
      'cn.geopin.geopin/location_method');
  static const EventChannel _locationEventChannel = EventChannel(
      'cn.geopin.geopin/location_event');

  get permissionMethodChannel => _permissionMethodChannel;
  get locationMethodChannel => _locationMethodChannel;
  get locationEventChannel => _locationEventChannel;
}