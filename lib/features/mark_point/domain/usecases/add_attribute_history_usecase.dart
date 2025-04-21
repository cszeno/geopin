import 'package:get_it/get_it.dart';
import '../repositories/preferences_repository.dart';

/// 添加属性到历史记录用例
/// 
/// 将新添加的属性保存到历史记录中
class AddAttributeHistoryUseCase {
  final PreferencesRepository _preferencesRepository = GetIt.I<PreferencesRepository>();
  
  /// 执行用例，添加属性到历史记录
  /// 
  /// [key] - 属性名
  /// [value] - 属性值
  /// 返回是否添加成功
  Future<bool> execute(String key, String value) async {
    return await _preferencesRepository.addAttributeToHistory(key, value);
  }
} 