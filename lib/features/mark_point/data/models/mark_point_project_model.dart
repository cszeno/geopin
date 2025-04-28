import '../../domain/entities/mark_point_project_entity.dart';

/// 标记点项目数据模型
/// 
/// 位于数据层，负责项目数据的序列化、反序列化和数据转换。
/// 与领域层的实体对应，但专注于数据处理而非业务规则。
class MarkPointProjectModel {
  /// 唯一标识ID
  final int id;

  /// 项目UUID
  final String uuid;
  
  /// 项目名称
  final String name;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 最后更新时间
  final DateTime updatedAt;

  /// 构造函数
  MarkPointProjectModel({
    required this.id,
    required this.uuid,
    required this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从实体转换为模型
  /// 
  /// 将领域层的实体对象转换为数据层的模型对象
  factory MarkPointProjectModel.fromEntity(MarkPointProjectEntity entity) {
    return MarkPointProjectModel(
      id: entity.id,
      uuid: entity.uuid,
      name: entity.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  
  /// 转换为实体
  /// 
  /// 将数据层的模型对象转换为领域层的实体对象
  MarkPointProjectEntity toEntity() {
    return MarkPointProjectEntity(
      id: id,
      uuid: uuid,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// 从JSON构造
  /// 
  /// 将JSON数据转换为模型对象
  /// 用于从API或本地存储中反序列化数据
  factory MarkPointProjectModel.fromJson(Map<String, dynamic> json) {
    return MarkPointProjectModel(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
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
      'uuid': uuid,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarkPointProjectModel &&
        other.id == id &&
        other.name == name;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
} 