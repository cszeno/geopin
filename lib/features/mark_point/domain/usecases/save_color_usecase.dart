import 'package:flutter/material.dart';
import '../repositories/preferences_repository.dart';

/// 保存颜色用例
/// 
/// 将用户选择的颜色保存到偏好设置
class SaveColorUseCase {
  final PreferencesRepository _preferencesRepository;
  
  SaveColorUseCase(this._preferencesRepository);
  
  /// 执行用例，保存颜色
  /// 
  /// [color] - 要保存的颜色
  /// 返回是否保存成功
  Future<bool> execute(Color color) async {
    return await _preferencesRepository.saveSelectedColor(color);
  }
} 