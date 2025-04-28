import 'package:uuid/uuid.dart';

/// 标记点项目实体类
/// 
/// 位于领域层，表示业务域中的标记点项目对象。
/// 不依赖于任何外部框架或实现细节。
/// 包含了项目的基本属性和业务规则。
class MarkPointProjectEntity {
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
  /// 
  /// [id]: 唯一标识ID
  /// [uuid]: 项目UUID
  /// [name]: 项目名称
  /// [createdAt]: 创建时间，默认为当前时间
  /// [updatedAt]: 最后更新时间，默认为当前时间
  MarkPointProjectEntity({
    required this.id,
    required this.uuid,
    required this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
        
  /// 创建更新后的项目实体
  /// 
  /// 返回一个基于当前实体数据，但包含更新内容的新实体
  /// [newName]: 新的名称，如果为null则保持原值
  MarkPointProjectEntity copyWith({
    String? uuid,
    String? newName,
  }) {
    return MarkPointProjectEntity(
      id: id,
      uuid: uuid ?? Uuid().v1(),
      name: newName ?? name,
      createdAt: createdAt,
      updatedAt: DateTime.now(), // 更新时间设为当前时间
    );
  }
  
  /// 判断两个项目是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarkPointProjectEntity &&
        other.id == id &&
        other.name == name;
  }
  
  /// 生成哈希码
  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
  
  /// 返回字符串表示
  @override
  String toString() {
    return 'MarkPointProjectEntity(id: $id, name: $name)';
  }
}
