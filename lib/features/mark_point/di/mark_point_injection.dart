import 'package:get_it/get_it.dart';
import 'package:geopin/core/services/database_service.dart';
import 'package:geopin/features/mark_point/data/datasources/image_data_source.dart';
import 'package:geopin/features/mark_point/data/datasources/mark_point_local_data_source.dart';
import 'package:geopin/features/mark_point/data/repositories/image_repository_impl.dart';
import 'package:geopin/features/mark_point/data/repositories/mark_point_repository_impl.dart';
import 'package:geopin/features/mark_point/data/repositories/preferences_repository_impl.dart';
import 'package:geopin/features/mark_point/domain/repositories/image_repository.dart';
import 'package:geopin/features/mark_point/domain/repositories/mark_point_repository.dart';
import 'package:geopin/features/mark_point/domain/repositories/preferences_repository.dart';
import 'package:geopin/features/mark_point/domain/usecases/add_attribute_history_usecase.dart';
import 'package:geopin/features/mark_point/domain/usecases/create_mark_point_usecase.dart';
import 'package:geopin/features/mark_point/domain/usecases/get_attribute_history_usecase.dart';
import 'package:geopin/features/mark_point/domain/usecases/get_saved_color_usecase.dart';
import 'package:geopin/features/mark_point/domain/usecases/save_color_usecase.dart';
import 'package:geopin/features/mark_point/domain/usecases/save_image_usecase.dart';
import 'package:geopin/features/mark_point/presentation/providers/mark_point_form_provider.dart';
import 'package:geopin/features/mark_point/presentation/providers/mark_point_provider.dart';

/// 标记点模块的依赖注入配置
///
/// 负责注册标记点模块所需的所有依赖
class MarkPointInjection {
  /// 注册所有依赖
  static void init(GetIt sl) {
    // 注册图片相关功能
    _registerImageFeatures(sl);
    
    // 注册表单相关功能
    _registerFormFeatures(sl);
    
    // 注册标记点表单Provider
    _registerFormProvider(sl);
  }
  
  /// 注册图片相关功能
  static void _registerImageFeatures(GetIt sl) {
    // 图片数据源
    if (!sl.isRegistered<ImageDataSource>()) {
      sl.registerLazySingleton<ImageDataSource>(
        () => ImageDataSourceImpl(),
      );
    }
    
    // 图片仓库
    if (!sl.isRegistered<ImageRepository>()) {
      sl.registerLazySingleton<ImageRepository>(
        () => ImageRepositoryImpl(),
      );
    }
    
    // 图片用例
    if (!sl.isRegistered<SaveImageUseCase>()) {
      sl.registerLazySingleton(
        () => SaveImageUseCase(),
      );
    }
  }
  
  /// 注册表单相关功能
  static void _registerFormFeatures(GetIt sl) {
    // 首选项仓库
    if (!sl.isRegistered<PreferencesRepository>()) {
      sl.registerLazySingleton<PreferencesRepository>(
        () => PreferencesRepositoryImpl(),
      );
    }
    
    // 表单相关用例
    if (!sl.isRegistered<GetSavedColorUseCase>()) {
      sl.registerLazySingleton(
        () => GetSavedColorUseCase(),
      );
    }
    
    if (!sl.isRegistered<SaveColorUseCase>()) {
      sl.registerLazySingleton(
        () => SaveColorUseCase(),
      );
    }
    
    if (!sl.isRegistered<GetAttributeHistoryUseCase>()) {
      sl.registerLazySingleton(
        () => GetAttributeHistoryUseCase(),
      );
    }
    
    if (!sl.isRegistered<AddAttributeHistoryUseCase>()) {
      sl.registerLazySingleton(
        () => AddAttributeHistoryUseCase(),
      );
    }
    
    if (!sl.isRegistered<CreateMarkPointUseCase>()) {
      sl.registerLazySingleton(
        () => CreateMarkPointUseCase(),
      );
    }
  }
  
  /// 注册标记点表单Provider
  static void _registerFormProvider(GetIt sl) {
    // 表单Provider
    if (!sl.isRegistered<MarkPointFormProvider>()) {
      sl.registerFactory(
        () => MarkPointFormProvider(),
      );
    }
  }
} 