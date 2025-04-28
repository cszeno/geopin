import 'package:get_it/get_it.dart';
import '../../../../core/services/database_service.dart';
import '../models/mark_point_project_model.dart';

/// 标记点项目本地数据源
/// 
/// 负责与本地数据库交互，执行项目的CRUD操作
class MarkPointProjectLocalDataSource {
  /// 数据库服务
  final DatabaseService _databaseService = GetIt.I<DatabaseService>();

  /// 构造函数
  MarkPointProjectLocalDataSource();

  /// 插入新项目
  /// 
  /// [model] 要插入的项目模型
  /// 返回新插入的项目ID
  Future<int> insertProject(MarkPointProjectModel model) async {
    final db = await _databaseService.database;
    return await db.insert(
      DatabaseService.projectsTable,
      {
        'uuid': model.uuid,
        'name': model.name,
        'created_at': model.createdAt.millisecondsSinceEpoch,
        'updated_at': model.updatedAt.millisecondsSinceEpoch,
      },
    );
  }

  /// 获取所有项目
  /// 
  /// 返回所有项目模型的列表
  Future<List<MarkPointProjectModel>> getAllProjects() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.projectsTable,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return MarkPointProjectModel(
        id: maps[i]['id'],
        uuid: maps[i]['uuid'],
        name: maps[i]['name'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['created_at']),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['updated_at']),
      );
    });
  }

  /// 根据ID获取项目
  /// 
  /// [id] 项目ID
  /// 返回对应的项目模型
  Future<MarkPointProjectModel> getProjectById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.projectsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('未找到ID为 $id 的项目');
    }

    return MarkPointProjectModel(
      id: maps[0]['id'],
      uuid: maps[0]['uuid'],
      name: maps[0]['name'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(maps[0]['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(maps[0]['updated_at']),
    );
  }

  /// 更新项目
  /// 
  /// [model] 包含更新内容的项目模型
  /// 返回是否更新成功
  Future<bool> updateProject(MarkPointProjectModel model) async {
    final db = await _databaseService.database;
    final result = await db.update(
      DatabaseService.projectsTable,
      {
        'uuid': model.uuid,
        'name': model.name,
        'updated_at': model.updatedAt.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [model.id],
    );

    return result > 0;
  }

  /// 删除项目
  /// 
  /// [id] 要删除的项目ID
  /// 返回是否删除成功
  Future<bool> deleteProject(int id) async {
    final db = await _databaseService.database;
    final result = await db.delete(
      DatabaseService.projectsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    return result > 0;
  }

  /// 搜索项目
  /// 
  /// [keyword] 搜索关键词
  /// 返回符合搜索条件的项目模型列表
  Future<List<MarkPointProjectModel>> searchProjects(String keyword) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.projectsTable,
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return MarkPointProjectModel(
        id: maps[i]['id'],
        uuid: maps[i]['uuid'],
        name: maps[i]['name'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['created_at']),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['updated_at']),
      );
    });
  }
} 