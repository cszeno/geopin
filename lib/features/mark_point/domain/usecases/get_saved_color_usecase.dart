import 'package:flutter/material.dart';
import '../repositories/preferences_repository.dart';

/// 获取保存颜色用例
/// 
/// 从偏好设置中获取用户上次选择的颜色
class GetSavedColorUseCase {
  final PreferencesRepository _preferencesRepository;
  
  GetSavedColorUseCase(this._preferencesRepository);
  
  /// 执行用例，获取保存的颜色
  /// 
  /// 如果没有保存的颜色，返回默认颜色 (红色)
  Future<Color> execute() async {
    final savedColor = await _preferencesRepository.getSavedColor();
    return savedColor ?? Colors.red;
  }
} 