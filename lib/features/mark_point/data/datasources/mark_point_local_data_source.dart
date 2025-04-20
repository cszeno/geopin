import 'dart:ui';

import 'package:sqflite/sqflite.dart';

import '../../../../core/services/database_service.dart';
import '../models/mark_point_model.dart';


/// 标记点本地数据源接口
///
/// 定义了标记点在本地存储的操作方法
abstract class MarkPointLocalDataSource {
  /// 获取所有标记点
  Future<List<MarkPointModel>> getAllMarkPoints();

  /// 根据ID获取标记点
  Future<MarkPointModel> getMarkPointById(int id);

  /// 插入新标记点
  Future<int> insertMarkPoint(MarkPointModel markPointModel);

  /// 更新已有标记点
  Future<bool> updateMarkPoint(MarkPointModel markPointModel);

  /// 删除标记点
  Future<bool> deleteMarkPoint(int id);

  /// 搜索标记点
  Future<List<MarkPointModel>> searchMarkPoints(String keyword);
}

/// 标记点本地数据源实现类
///
/// 使用SQLite数据库实现标记点的本地存储与检索
class MarkPointLocalDataSourceImpl implements MarkPointLocalDataSource {
  /// 数据库实例
  late final Database database;

  /// 标记点表名
  static const String tableName = DatabaseService.markPointsTable;

  /// 构造函数
  MarkPointLocalDataSourceImpl({required this.database});

  /// 工厂方法，初始化并返回数据源实例
  ///
  /// 使用中央数据库服务来获取数据库实例
  static Future<MarkPointLocalDataSourceImpl> create() async {
    // 获取数据库实例
    final database = await DatabaseService.instance.database;
    return MarkPointLocalDataSourceImpl(database: database);
  }

  /// 将JSON格式的属性转换为字符串
  String? _encodeAttributes(Map<String, String>? attributes) {
    if (attributes == null) return null;
    return attributes.entries.map((e) => '${e.key}:${e.value}').join(';');
  }

  /// 将字符串格式的属性转换为Map
  Map<String, String>? _decodeAttributes(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;

    final Map<String, String> result = {};
    final pairs = encoded.split(';');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        result[parts[0]] = parts[1];
      }
    }
    return result;
  }

  /// 将图片路径列表转换为字符串
  String? _encodeImgPaths(List<String>? paths) {
    if (paths == null) return null;
    return paths.join(';');
  }

  /// 将字符串转换为图片路径列表
  List<String>? _decodeImgPaths(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    return encoded.split(';');
  }

  /// 将模型转换为数据库记录
  Map<String, dynamic> _modelToDbMap(MarkPointModel model) {
    return {
      if (model.id > 0) 'id': model.id,
      'name': model.name,
      'latitude': model.latitude,
      'longitude': model.longitude,
      'project_id': model.projectId,
      'elevation': model.elevation,
      'color': model.color?.value,
      'img_path': _encodeImgPaths(model.imgPath),
      'attributes': _encodeAttributes(model.attributes),
      'created_at': model.createdAt.millisecondsSinceEpoch,
      'updated_at': model.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 将数据库记录转换为模型
  MarkPointModel _dbMapToModel(Map<String, dynamic> map) {
    return MarkPointModel(
      id: map['id'],
      uuid: map['uuid'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      projectId: map['project_id'],
      elevation: map['elevation'],
      color: map['icon_color'] != null ? Color(map['icon_color']) : null,
      imgPath: _decodeImgPaths(map['img_path']),
      attributes: _decodeAttributes(map['attributes']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  @override
  Future<bool> deleteMarkPoint(int id) async {
    // 执行删除操作，返回受影响行数
    final count = await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0; // 返回是否成功删除
  }

  @override
  Future<List<MarkPointModel>> getAllMarkPoints() async {
    // 查询所有记录
    final List<Map<String, dynamic>> maps = await database.query(tableName);

    // 转换为Model列表
    return maps.map((map) => _dbMapToModel(map)).toList();
  }

  @override
  Future<MarkPointModel> getMarkPointById(int id) async {
    // 查询指定ID的记录
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      throw Exception('未找到ID为$id的标记点');
    }

    return _dbMapToModel(maps.first);
  }

  @override
  Future<int> insertMarkPoint(MarkPointModel markPointModel) async {
    // 插入新记录
    final id = await database.insert(
      tableName,
      _modelToDbMap(markPointModel),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id; // 返回新插入记录的ID
  }

  @override
  Future<bool> updateMarkPoint(MarkPointModel markPointModel) async {
    // 确保ID存在
    if (markPointModel.id <= 0) {
      throw Exception('更新标记点需要有效的ID');
    }

    // 更新现有记录
    final count = await database.update(
      tableName,
      _modelToDbMap(markPointModel),
      where: 'id = ?',
      whereArgs: [markPointModel.id],
    );
    return count > 0; // 返回是否更新成功
  }

  @override
  Future<List<MarkPointModel>> searchMarkPoints(String keyword) async {
    // 关键词搜索，匹配名称和属性
    final String searchPattern = '%$keyword%';
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'name LIKE ? OR attributes LIKE ?',
      whereArgs: [searchPattern, searchPattern],
    );

    return maps.map((map) => _dbMapToModel(map)).toList();
  }
}
