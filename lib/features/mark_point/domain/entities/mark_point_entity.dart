import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 标记点实体类
/// 
/// 位于领域层，表示业务域中的标记点对象。
/// 不依赖于任何外部框架或实现细节（除了Flutter基础类型）。
/// 包含了标记点的基本属性和业务规则。
class MarkPointEntity {
  /// 唯一标识ID
  final int id;

  /// uuid
  final String uuid;
  
  /// 标记点名称
  final String name;
  
  /// 纬度坐标
  final double latitude;
  
  /// 经度坐标
  final double longitude;
  
  /// 关联的项目ID
  late final int? projectUUID;
  
  /// 海拔高度（可选）
  final double? elevation;
  
  /// 图标颜色（可选）
  final Color? color;
  
  /// 相关图片路径列表（可选）
  final List<String>? imgPath;
  
  /// 自定义属性集合
  /// 可存储任意与标记点相关的键值对信息
  final Map<String, String>? attributes;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 最后更新时间
  final DateTime updatedAt;

  /// 构造函数
  /// 
  /// [id]: 唯一标识ID
  /// [name]: 标记点名称  
  /// [latitude]: 纬度坐标
  /// [longitude]: 经度坐标
  /// [projectUUID]: 关联的项目ID（可选）
  /// [elevation]: 海拔高度（可选）
  /// [iconId]: 图标标识符（可选）
  /// [iconColor]: 图标颜色（可选）
  /// [imgPath]: 相关图片路径列表（可选）
  /// [attributes]: 自定义属性集合（可选）
  /// [createdAt]: 创建时间，默认为当前时间
  /// [updatedAt]: 最后更新时间，默认为当前时间
  MarkPointEntity({
    required this.id,
    required this.uuid,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.projectUUID,
    this.elevation,
    this.color,
    this.imgPath,
    this.attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
        
  /// 创建更新后的标记点实体
  /// 
  /// 返回一个基于当前实体数据，但包含更新内容的新实体
  /// [newName]: 新的名称，如果为null则保持原值
  /// [newLatitude]: 新的纬度，如果为null则保持原值
  /// [newLongitude]: 新的经度，如果为null则保持原值
  /// [newprojectUUID]: 新的项目ID，如果为null则保持原值
  /// [newElevation]: 新的海拔，如果为null则保持原值
  /// [newIconId]: 新的图标ID，如果为null则保持原值
  /// [newIconColor]: 新的图标颜色，如果为null则保持原值
  /// [newImgPath]: 新的图片路径，如果为null则保持原值
  /// [newAttributes]: 新的属性集合，如果为null则保持原值
  MarkPointEntity copyWith({
    String? uuid,
    String? newName,
    double? newLatitude,
    double? newLongitude,
    int? newprojectUUID,
    double? newElevation,
    Color? newIconColor,
    List<String>? newImgPath,
    Map<String, String>? newAttributes,
  }) {
    return MarkPointEntity(
      id: id,
      uuid: uuid ?? Uuid().v1(),
      name: newName ?? name,
      latitude: newLatitude ?? latitude,
      longitude: newLongitude ?? longitude,
      projectUUID: newprojectUUID ?? projectUUID,
      elevation: newElevation ?? elevation,
      color: newIconColor ?? color,
      imgPath: newImgPath ?? imgPath,
      attributes: newAttributes ?? attributes,
      createdAt: createdAt,
      updatedAt: DateTime.now(), // 更新时间设为当前时间
    );
  }
  
  /// 判断两个标记点是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarkPointEntity &&
        other.id == id &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }
  
  /// 生成哈希码
  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
  }
  
  /// 返回字符串表示
  @override
  String toString() {
    return 'MarkPointEntity(id: $id, name: $name, lat: $latitude, lng: $longitude, projectUUID: $projectUUID)';
  }
}
