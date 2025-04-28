import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../entities/mark_point_entity.dart';

/// 创建标记点用例
/// 
/// 负责创建新的标记点实体
class CreateMarkPointUseCase {
  /// 执行用例，创建新的标记点
  /// 
  /// [name] - 标记点名称
  /// [latitude] - 纬度
  /// [longitude] - 经度
  /// [elevation] - 海拔高度（可选）
  /// [color] - 标记点颜色
  /// [attributes] - 自定义属性（可选）
  /// [imagePaths] - 图片路径列表（可选）
  /// 返回创建的标记点实体
  MarkPointEntity execute({
    required String name,
    required double latitude,
    required double longitude,
    required int projectUUID,
    double? elevation,
    required Color color,
    Map<String, String>? attributes,
    List<String>? imagePaths,
  }) {
    // 创建标记点实体
    return MarkPointEntity(
      id: DateTime.now().millisecondsSinceEpoch, // 临时ID，实际应由数据库生成
      uuid: const Uuid().v1(),
      name: name,
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
      projectUUID: projectUUID,
      color: color,
      attributes: attributes,
      imgPath: imagePaths,
    );
  }
} 