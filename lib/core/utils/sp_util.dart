import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get_it/get_it.dart';

/// 本地存储服务
/// 封装SharedPreferences，提供应用级别的数据持久化服务
class SPUtil {
  /// 单例实例
  static final SPUtil _instance = SPUtil._internal();
  
  /// SharedPreferences实例
  SharedPreferences? _prefs;
  
  /// 是否已初始化
  bool _initialized = false;
  
  /// 获取初始化状态
  bool get isInitialized => _initialized;
  
  /// 获取单例实例
  factory SPUtil() => _instance;
  
  /// 获取通过GetIt注册的实例（如果已注册）
  static SPUtil get I {
    if (GetIt.I.isRegistered<SPUtil>()) {
      return GetIt.I<SPUtil>();
    }
    return _instance;
  }
  
  /// 注册到GetIt
  static Future<void> registerInGetIt() async {
    if (!GetIt.I.isRegistered<SPUtil>()) {
      final instance = SPUtil();
      await instance.init();
      GetIt.I.registerSingleton<SPUtil>(instance);
    }
  }
  
  /// 内部构造函数
  SPUtil._internal();
  
  /// 初始化存储服务
  /// 必须在使用其他方法前调用
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }
  
  /// 检查初始化状态
  void _checkInitialized() {
    if (!_initialized) {
      throw StateError('StorageService未初始化，请先调用init()方法');
    }
  }
  
  /// 保存字符串值
  Future<bool> setString(String key, String value) {
    _checkInitialized();
    return _prefs!.setString(key, value);
  }
  
  /// 获取字符串值
  String? getString(String key) {
    _checkInitialized();
    return _prefs!.getString(key);
  }
  
  /// 保存布尔值
  Future<bool> setBool(String key, bool value) {
    _checkInitialized();
    return _prefs!.setBool(key, value);
  }
  
  /// 获取布尔值
  bool? getBool(String key) {
    _checkInitialized();
    return _prefs!.getBool(key);
  }
  
  /// 保存整数值
  Future<bool> setInt(String key, int value) {
    _checkInitialized();
    return _prefs!.setInt(key, value);
  }
  
  /// 获取整数值
  int? getInt(String key) {
    _checkInitialized();
    return _prefs!.getInt(key);
  }
  
  /// 保存双精度浮点数值
  Future<bool> setDouble(String key, double value) {
    _checkInitialized();
    return _prefs!.setDouble(key, value);
  }
  
  /// 获取双精度浮点数值
  double? getDouble(String key) {
    _checkInitialized();
    return _prefs!.getDouble(key);
  }
  
  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) {
    _checkInitialized();
    return _prefs!.setStringList(key, value);
  }
  
  /// 获取字符串列表
  List<String>? getStringList(String key) {
    _checkInitialized();
    return _prefs!.getStringList(key);
  }
  
  /// 保存对象（JSON序列化）
  Future<bool> setObject(String key, Object value) {
    _checkInitialized();
    return _prefs!.setString(key, jsonEncode(value));
  }
  
  /// 获取对象（JSON反序列化）
  T? getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    _checkInitialized();
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return fromJson(json);
    } catch (e) {
      print('解析JSON出错: $e');
      return null;
    }
  }
  
  /// 保存Map<String,String>列表
  Future<bool> setMapStringList(String key, List<Map<String, String>> value) {
    _checkInitialized();
    final jsonString = jsonEncode(value);
    return _prefs!.setString(key, jsonString);
  }
  
  /// 获取Map<String,String>列表
  List<Map<String, String>> getMapStringList(String key) {
    _checkInitialized();
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Map<String, String>.from(item)).toList();
    } catch (e) {
      print('解析Map列表出错: $e');
      return [];
    }
  }
  
  /// 检查键是否存在
  bool containsKey(String key) {
    _checkInitialized();
    return _prefs!.containsKey(key);
  }
  
  /// 移除指定键的数据
  Future<bool> remove(String key) {
    _checkInitialized();
    return _prefs!.remove(key);
  }
  
  /// 清除所有数据
  Future<bool> clear() {
    _checkInitialized();
    return _prefs!.clear();
  }
} 