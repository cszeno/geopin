import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';
import 'package:get_it/get_it.dart';

/// 数据库服务
/// 
/// 集中管理SQLite数据库的创建、升级和访问
/// 所有表结构变更都在此处统一维护，避免版本冲突
class DatabaseService {
  static final _logger = Logger('DatabaseService');
  
  // 数据库实例
  Database? _database;
  
  // 单例实例
  static DatabaseService? _instance;
  
  // 数据库名称
  static const String _databaseName = 'gen_pin.db';
  
  // 当前数据库版本
  static const int _databaseVersion = 1;
  
  // 项目表名
  static const String projectsTable = 'projects';
  
  // 标记点表名
  static const String markPointsTable = 'mark_points';
  
  // 私有构造函数
  DatabaseService._();
  
  /// 获取单例实例
  static DatabaseService get instance {
    if (_instance == null) {
      _instance = DatabaseService._();
      // 如果GetIt尚未注册此服务，则注册
      final getIt = GetIt.instance;
      if (!getIt.isRegistered<DatabaseService>()) {
        getIt.registerSingleton<DatabaseService>(_instance!);
      }
    }
    return _instance!;
  }
  
  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// 初始化数据库
  Future<Database> _initDatabase() async {
    _logger.info('初始化数据库: $_databaseName (版本: $_databaseVersion)');
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    _logger.info('创建数据库表 (版本: $version)');
    
    // 创建项目表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $projectsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    // 创建标记点表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $markPointsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        project_uuid INTEGER,
        elevation REAL,
        icon_color INTEGER,
        img_path TEXT,
        attributes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }
  
  /// 处理数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.info('升级数据库: $oldVersion -> $newVersion');

    if (oldVersion < 1) {
      // 如果是从0升级到1，那么执行与onCreate相同的操作
      await _onCreate(db, newVersion);
    }

    // if (oldVersion < 2) {
    //   // 版本1升级到版本2的操作
    //
    //   // 检查项目表是否存在
    //   final projectTables = await db.rawQuery(
    //     "SELECT name FROM sqlite_master WHERE type='table' AND name='$projectsTable'"
    //   );
    //
    //   if (projectTables.isEmpty) {
    //     // 创建项目表
    //     await db.execute('''
    //       CREATE TABLE IF NOT EXISTS $projectsTable (
    //         id INTEGER PRIMARY KEY AUTOINCREMENT,
    //         name TEXT NOT NULL,
    //         created_at INTEGER NOT NULL,
    //         updated_at INTEGER NOT NULL
    //       )
    //     ''');
    //   }
    //
    //   // 检查标记点表是否存在
    //   final markPointTables = await db.rawQuery(
    //     "SELECT name FROM sqlite_master WHERE type='table' AND name='$markPointsTable'"
    //   );
    //
    //   if (markPointTables.isEmpty) {
    //     // 创建标记点表
    //     await db.execute('''
    //       CREATE TABLE IF NOT EXISTS $markPointsTable (
    //         id INTEGER PRIMARY KEY AUTOINCREMENT,
    //         name TEXT NOT NULL,
    //         latitude REAL NOT NULL,
    //         longitude REAL NOT NULL,
    //         project_uuid INTEGER,
    //         elevation REAL,
    //         icon_id TEXT,
    //         icon_color INTEGER,
    //         img_path TEXT,
    //         attributes TEXT,
    //         created_at INTEGER NOT NULL,
    //         updated_at INTEGER NOT NULL
    //       )
    //     ''');
    //   } else {
    //     // 标记点表存在，但需要添加project_uuid字段
    //     try {
    //       // 检查project_uuid字段是否存在
    //       await db.rawQuery('SELECT project_uuid FROM $markPointsTable LIMIT 1');
    //     } catch (e) {
    //       // 字段不存在，添加project_uuid字段
    //       _logger.info('添加project_uuid字段到$markPointsTable表');
    //       await db.execute('ALTER TABLE $markPointsTable ADD COLUMN project_uuid INTEGER;');
    //     }
    //   }
    // }

    // 这里可以添加未来版本的升级逻辑
  }
  
  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
  
  /// 调试方法：列出数据库中的所有表和记录数
  Future<void> dumpDatabaseStats() async {
    final db = await database;
    _logger.info('==== 数据库状态 ====');
    
    // 获取所有表
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'"
    );
    
    _logger.info('数据库中有 ${tables.length} 个表:');
    
    // 遍历每个表并计算记录数
    for (var table in tables) {
      final tableName = table['name'] as String;
      final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final count = Sqflite.firstIntValue(countResult) ?? 0;
      
      _logger.info('- 表 $tableName: $count 条记录');
      
      // 如果是项目表，显示所有记录
      if (tableName == projectsTable) {
        final records = await db.query(tableName);
        for (var i = 0; i < records.length; i++) {
          _logger.info('  项目 ${i+1}: ID=${records[i]['id']}, 名称=${records[i]['name']}');
        }
      }
    }
    
    _logger.info('===================');
  }
  
  /// 重置数据库
  /// 
  /// 删除并重新创建数据库，谨慎使用！
  Future<void> resetDatabase() async {
    _logger.info('正在重置数据库...');
    
    // 关闭现有连接
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // 获取数据库路径
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    
    // 删除数据库文件
    _logger.info('删除数据库文件: $path');
    try {
      await deleteDatabase(path);
      _logger.info('数据库已删除');
    } catch (e) {
      _logger.severe('删除数据库失败: $e');
    }
    
    // 重新初始化数据库
    _database = await _initDatabase();
    _logger.info('数据库已重新初始化');
    
    // 打印数据库状态
    await dumpDatabaseStats();
  }
} 