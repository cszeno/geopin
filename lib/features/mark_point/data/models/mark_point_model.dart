import 'dart:ui';

import 'package:flutter/material.dart';

import '../../domain/entities/mark_point_entity.dart';

/// 标记点数据模型
/// 
/// 位于数据层，负责标记点数据的序列化、反序列化和数据转换。
/// 与领域层的实体对应，但专注于数据处理而非业务规则。
class MarkPointModel {
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
  final int? projectId;
  
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
  MarkPointModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.projectId,
    this.elevation,
    this.color,
    this.imgPath,
    this.attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从实体转换为模型
  /// 
  /// 将领域层的实体对象转换为数据层的模型对象
  factory MarkPointModel.fromEntity(MarkPointEntity entity) {
    return MarkPointModel(
      id: entity.id,
      uuid: entity.uuid,
      name: entity.name,
      latitude: entity.latitude,
      longitude: entity.longitude,
      projectId: entity.projectId,
      elevation: entity.elevation,
      color: entity.color,
      imgPath: entity.imgPath,
      attributes: entity.attributes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  
  /// 转换为实体
  /// 
  /// 将数据层的模型对象转换为领域层的实体对象
  MarkPointEntity toEntity() {
    return MarkPointEntity(
      id: id,
      uuid: uuid,
      name: name,
      latitude: latitude,
      longitude: longitude,
      projectId: projectId,
      elevation: elevation,
      color: color,
      imgPath: imgPath,
      attributes: attributes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// 从JSON构造
  /// 
  /// 将JSON数据转换为模型对象
  /// 用于从API或本地存储中反序列化数据
  factory MarkPointModel.fromJson(Map<String, dynamic> json) {
    return MarkPointModel(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      projectId: json['projectId'],
      elevation: json['elevation'],
      color: json['color'] != null
          ? Color(json['color'])
          : null,
      imgPath: json['imgPath'] != null
          ? List<String>.from(json['imgPath'])
          : null,
      attributes: json['attributes'] != null
          ? Map<String, String>.from(json['attributes'])
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']) 
          : null,
    );
  }

  /// 转换为JSON
  /// 
  /// 将模型对象转换为JSON数据
  /// 用于序列化数据到API或本地存储
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'projectId': projectId,
      'elevation': elevation,
      'color': color?.value,
      'imgPath': imgPath,
      'attributes': attributes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
  

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarkPointModel &&
        other.id == id &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
  }
}
