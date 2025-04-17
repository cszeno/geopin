import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

/// APP日志工具类
/// 封装了日志打印和本地存储功能
/// 使用方法：
/// 1. 在main.dart中初始化: await AppLogger.init();
/// 2. 在任意位置调用:
///    - AppLogger.debug('调试信息');
///    - AppLogger.info('信息日志');
///    - AppLogger.warning('警告信息');
///    - AppLogger.error('错误信息', error: e, stackTrace: s);
///    - AppLogger.fatal('严重错误', error: e, stackTrace: s);
class AppLogger {
  /// 私有构造函数，防止直接实例化
  AppLogger._();

  /// 日志配置
  static final LogConfig _config = LogConfig();
  
  /// 日志文件
  static File? _logFile;
  
  /// 当前日期（用于按日期分割日志文件）
  static String _currentDate = '';
  
  /// 日志文件写入锁（防止并发写入导致的文件损坏）
  static final _writeLock = Object();

  /// 初始化日志系统
  /// [config] 日志配置信息，可选
  static Future<void> init({LogConfig? config}) async {
    // 如果提供了配置，则使用提供的配置
    if (config != null) {
      _config.copyFrom(config);
    }

    // 设置日志级别
    Logger.root.level = _config.level;
    
    // 监听日志记录
    Logger.root.onRecord.listen((record) {
      // 格式化日志消息
      final formattedMessage = _formatLogMessage(record);
      
      // 控制台输出日志（仅在调试模式或者配置允许时）
      if (kDebugMode || _config.printInReleaseMode) {
        print(formattedMessage);
      }
      
      // 保存日志到文件（如果启用）
      if (_config.saveToFile) {
        _writeToFile(record, formattedMessage);
      }
    });
    
    // 如果启用了文件存储，则初始化日志文件
    if (_config.saveToFile) {
      await _initLogFile();
    }
    
    // 输出初始化日志
    debug('日志系统初始化完成: ${_config.toString()}');
  }

  /// 初始化日志文件
  static Future<void> _initLogFile() async {
    try {
      // 获取当前日期作为文件名的一部分
      _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();
      
      // 创建日志目录
      final logDir = Directory('${appDocDir.path}/${_config.logFolderName}');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      // 创建或打开日志文件
      _logFile = File('${logDir.path}/log_$_currentDate.txt');
      if (!await _logFile!.exists()) {
        await _logFile!.create(recursive: true);
      }
      
      // 清理旧日志文件
      if (_config.maxLogFiles > 0) {
        await _cleanOldLogFiles(logDir);
      }
    } catch (e, s) {
      print('初始化日志文件失败: $e');
      print('堆栈信息: $s');
    }
  }

  /// 清理旧的日志文件
  static Future<void> _cleanOldLogFiles(Directory logDir) async {
    try {
      // 获取所有日志文件
      final logFiles = await logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.txt'))
          .toList();
      
      // 按修改时间排序
      logFiles.sort((a, b) {
        return File(b.path).lastModifiedSync()
            .compareTo(File(a.path).lastModifiedSync());
      });
      
      // 删除超过最大保留数量的旧文件
      if (logFiles.length > _config.maxLogFiles) {
        for (int i = _config.maxLogFiles; i < logFiles.length; i++) {
          await File(logFiles[i].path).delete();
        }
      }
    } catch (e) {
      print('清理旧日志文件失败: $e');
    }
  }

  /// 格式化日志消息
  static String _formatLogMessage(LogRecord record) {
    final time = DateFormat('HH:mm:ss.SSS').format(record.time);
    final loggerName = record.loggerName.isNotEmpty ? '[${record.loggerName}]' : '';
    final levelName = record.level.name.padRight(7);
    
    String message = '[$time] $levelName $loggerName: ${record.message}';
    
    if (record.error != null) {
      message += '\nError: ${record.error}';
    }
    
    if (_config.includeStackTrace && record.stackTrace != null) {
      message += '\nStackTrace: ${record.stackTrace}';
    }
    
    return message;
  }

  /// 将日志写入文件
  static void _writeToFile(LogRecord record, String formattedMessage) {
    // 检查日志级别是否需要写入文件
    if (record.level.value < _config.fileLogLevel.value) {
      return;
    }
    
    // 使用锁防止并发写入
    _synchronizedWrite(() async {
      try {
        // 检查是否需要切换到新的日志文件（新的一天）
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        if (today != _currentDate || _logFile == null) {
          await _initLogFile();
        }
        
        // 写入日志到文件
        if (_logFile != null) {
          await _logFile!.writeAsString(
            '$formattedMessage\n',
            mode: FileMode.append,
            flush: _config.flushImmediately,
          );
        }
      } catch (e) {
        // 写入失败，输出到控制台
        if (kDebugMode) {
          print('写入日志到文件失败: $e');
        }
      }
    });
  }

  /// 同步执行写入操作，防止并发
  static Future<void> _synchronizedWrite(Future<void> Function() fn) async {
    synchronized(_writeLock, fn);
  }
  
  /// 使用锁对象同步执行函数，防止并发
  static Future<T> synchronized<T>(Object lock, Future<T> Function() fn) async {
    if (!_locks.containsKey(lock)) {
      _locks[lock] = false;
    }
    
    // 等待锁释放
    while (_locks[lock] == true) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    // 获取锁
    _locks[lock] = true;
    
    try {
      // 执行临界区代码
      return await fn();
    } finally {
      // 释放锁
      _locks[lock] = false;
    }
  }

  /// 锁状态映射
  static final Map<Object, bool> _locks = {};

  /// 获取指定名称的Logger
  static Logger getLogger(String name) {
    return Logger(name);
  }

  /// 获取所有日志文件
  static Future<List<File>> getLogFiles() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDocDir.path}/${_config.logFolderName}');
      
      if (!await logDir.exists()) {
        return [];
      }
      
      final files = await logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.txt'))
          .map((entity) => File(entity.path))
          .toList();
      
      // 按修改时间排序，最新的在前面
      files.sort((a, b) {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });
      
      return files;
    } catch (e) {
      if (kDebugMode) {
        print('获取日志文件列表失败: $e');
      }
      return [];
    }
  }

  /// 获取当前日志文件内容
  static Future<String> getCurrentLogContent() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        return await _logFile!.readAsString();
      }
    } catch (e) {
      if (kDebugMode) {
        print('读取当前日志文件失败: $e');
      }
    }
    return '';
  }

  /// 清空所有日志文件
  static Future<bool> clearAllLogs() async {
    try {
      final files = await getLogFiles();
      for (final file in files) {
        await file.delete();
      }
      await _initLogFile();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('清空日志文件失败: $e');
      }
      return false;
    }
  }

  /// 导出日志文件为JSON格式
  static Future<String> exportLogsAsJson() async {
    try {
      final files = await getLogFiles();
      final Map<String, String> result = {};
      
      for (final file in files) {
        final fileName = file.path.split('/').last;
        final content = await file.readAsString();
        result[fileName] = content;
      }
      
      return jsonEncode(result);
    } catch (e) {
      if (kDebugMode) {
        print('导出日志为JSON失败: $e');
      }
      return '{}';
    }
  }

  // 以下是便捷的日志方法

  /// 输出调试日志
  static void debug(String message, {String? loggerName, Object? error, StackTrace? stackTrace}) {
    final logger = loggerName != null ? Logger(loggerName) : Logger('');
    logger.fine(message, error, stackTrace);
  }

  /// 输出信息日志
  static void info(String message, {String? loggerName, Object? error, StackTrace? stackTrace}) {
    final logger = loggerName != null ? Logger(loggerName) : Logger('');
    logger.info(message, error, stackTrace);
  }

  /// 输出警告日志
  static void warning(String message, {String? loggerName, Object? error, StackTrace? stackTrace}) {
    final logger = loggerName != null ? Logger(loggerName) : Logger('');
    logger.warning(message, error, stackTrace);
  }

  /// 输出错误日志
  static void error(String message, {String? loggerName, Object? error, StackTrace? stackTrace}) {
    final logger = loggerName != null ? Logger(loggerName) : Logger('');
    logger.severe(message, error, stackTrace);
  }

  /// 输出致命错误日志
  static void fatal(String message, {String? loggerName, Object? error, StackTrace? stackTrace}) {
    final logger = loggerName != null ? Logger(loggerName) : Logger('');
    logger.shout(message, error, stackTrace);
  }
}

/// 日志配置类
class LogConfig {
  /// 日志级别
  Level level;
  
  /// 文件日志级别（可能比控制台日志级别更高，以减少文件大小）
  Level fileLogLevel;
  
  /// 是否在发布模式下输出日志到控制台
  bool printInReleaseMode;
  
  /// 是否保存日志到文件
  bool saveToFile;
  
  /// 是否包含堆栈信息
  bool includeStackTrace;
  
  /// 日志文件夹名称
  String logFolderName;
  
  /// 最大保留日志文件数量（0表示不限制）
  int maxLogFiles;
  
  /// 是否立即刷新日志到磁盘
  bool flushImmediately;

  /// 日志配置构造函数
  LogConfig({
    this.level = Level.ALL,
    this.fileLogLevel = Level.INFO,
    this.printInReleaseMode = false,
    this.saveToFile = true,
    this.includeStackTrace = true,
    this.logFolderName = 'logs',
    this.maxLogFiles = 7,  // 默认保留一周的日志
    this.flushImmediately = true,
  });

  /// 从另一个配置对象复制配置
  void copyFrom(LogConfig other) {
    level = other.level;
    fileLogLevel = other.fileLogLevel;
    printInReleaseMode = other.printInReleaseMode;
    saveToFile = other.saveToFile;
    includeStackTrace = other.includeStackTrace;
    logFolderName = other.logFolderName;
    maxLogFiles = other.maxLogFiles;
    flushImmediately = other.flushImmediately;
  }
  
  @override
  String toString() {
    return 'LogConfig{level: ${level.name}, fileLogLevel: ${fileLogLevel.name}, '
        'saveToFile: $saveToFile, includeStackTrace: $includeStackTrace, '
        'maxLogFiles: $maxLogFiles}';
  }
} 