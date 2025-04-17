import 'package:flutter/services.dart';

class PermissionConstant {

  // 私有静态实例
  static PermissionConstant? _instance;

  // 私有构造函数，放置外部实例化
  PermissionConstant._internal();

  // 工厂构造函数控制实例化逻辑
  factory PermissionConstant() {
    _instance ??= PermissionConstant._internal();
    return _instance!;
  }

  static const MethodChannel _methodChannel = MethodChannel('cn.geopin.geopin/location_method');
  static const EventChannel _eventChannel = EventChannel('cn.geopin.geopin/location_event');

  get methodChannel => _methodChannel;
  get eventChannel => _eventChannel;
}