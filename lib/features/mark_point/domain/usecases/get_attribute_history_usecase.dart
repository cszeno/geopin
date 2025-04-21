import 'package:get_it/get_it.dart';
import '../repositories/preferences_repository.dart';

/// 获取属性历史记录用例
/// 
/// 从偏好设置中获取用户之前添加过的属性历史记录
class GetAttributeHistoryUseCase {
  final PreferencesRepository _preferencesRepository = GetIt.I<PreferencesRepository>();
  
  /// 执行用例，获取属性历史记录
  /// 
  /// 返回属性历史记录列表
  Future<List<Map<String, String>>> execute() async {
    return await _preferencesRepository.getAttributeHistory();
  }
} 