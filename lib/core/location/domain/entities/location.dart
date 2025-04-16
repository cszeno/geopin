import 'package:flutter/foundation.dart';

/// 位置信息实体类
/// 
/// 包含位置的所有必要信息，如经纬度、海拔、速度等
class Location {
  /// 纬度（度）
  final double latitude;
  
  /// 经度（度）
  final double longitude;
  
  /// 海拔高度（米）
  final double altitude;
  
  /// 水平精度（米）
  final double accuracy;
  
  /// 垂直精度（米）
  final double? verticalAccuracy;
  
  /// 速度（米/秒）
  final double? speed;
  
  /// 速度精度（米/秒）
  final double? speedAccuracy;
  
  /// 方向角（度，0-359.9）
  final double? bearing;
  
  /// 方向角精度（度）
  final double? bearingAccuracy;
  
  /// 位置提供者（GPS, network, fused, 等）
  final String? provider;
  
  /// 时间戳（毫秒）
  final int timestamp;

  /// 构造函数
  const Location({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    this.verticalAccuracy,
    this.speed,
    this.speedAccuracy,
    this.bearing,
    this.bearingAccuracy,
    this.provider,
    required this.timestamp,
  });

  /// 从Map创建Location对象
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      altitude: map['altitude'] ?? 0.0,
      accuracy: map['accuracy'] ?? 0.0,
      verticalAccuracy: map['verticalAccuracy'],
      speed: map['speed'],
      speedAccuracy: map['speedAccuracy'],
      bearing: map['bearing'],
      bearingAccuracy: map['bearingAccuracy'],
      provider: map['provider'],
      timestamp: map['time'] is double ? map['time'].toInt() : (map['time'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  /// 复制Location对象并修改部分属性
  Location copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    double? verticalAccuracy,
    double? speed,
    double? speedAccuracy,
    double? bearing,
    double? bearingAccuracy,
    String? provider,
    int? timestamp,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      verticalAccuracy: verticalAccuracy ?? this.verticalAccuracy,
      speed: speed ?? this.speed,
      speedAccuracy: speedAccuracy ?? this.speedAccuracy,
      bearing: bearing ?? this.bearing,
      bearingAccuracy: bearingAccuracy ?? this.bearingAccuracy,
      provider: provider ?? this.provider,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// 格式化的经纬度字符串
  String get formattedCoordinates => 
      '${latitude.toStringAsFixed(8)}°${latitude >= 0 ? 'N' : 'S'}, ${longitude.toStringAsFixed(8)}°${longitude >= 0 ? 'E' : 'W'}';

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'verticalAccuracy': verticalAccuracy,
      'speed': speed,
      'speedAccuracy': speedAccuracy,
      'bearing': bearing,
      'bearingAccuracy': bearingAccuracy,
      'provider': provider,
      'time': timestamp,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Location &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.altitude == altitude &&
      other.accuracy == accuracy &&
      other.verticalAccuracy == verticalAccuracy &&
      other.speed == speed &&
      other.speedAccuracy == speedAccuracy &&
      other.bearing == bearing &&
      other.bearingAccuracy == bearingAccuracy &&
      other.provider == provider &&
      other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      latitude,
      longitude,
      altitude,
      accuracy,
      verticalAccuracy,
      speed,
      speedAccuracy,
      bearing,
      bearingAccuracy,
      provider,
      timestamp,
    );
  }
} 