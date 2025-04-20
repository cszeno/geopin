import 'package:get_it/get_it.dart';
import 'package:geopin/features/mark_point/data/datasources/image_data_source.dart';
import 'package:geopin/features/mark_point/data/repositories/image_repository_impl.dart';
import 'package:geopin/features/mark_point/data/repositories/preferences_repository_impl.dart';
import 'package:geopin/features/mark_point/domain/repositories/image_repository.dart';
import 'package:geopin/features/mark_point/domain/repositories/preferences_repository.dart';
import 'package:geopin/features/mark_point/domain/usecases/add_attribute_history_usecase.dart';
import 'package:geopin/features/mark_point/domain/usecases/create_mark_point_usecase.dart';
import 'package:geopin/features/mark_point/domain/usecases/get_attribute_history_usecase.dart';
import 'package:geopin/features/mark_point/domain/usecases/get_saved_color_usecase.dart';
import 'package:geopin/features/mark_point/domain/usecases/save_color_usecase.dart';
import 'package:geopin/features/mark_point/domain/usecases/save_image_usecase.dart';
import 'package:geopin/features/mark_point/presentation/providers/mark_point_form_provider.dart';

/// 标记点模块的依赖注入配置
///
/// 负责注册标记点模块所需的所有依赖
class MarkPointInjection {
  /// 注册所有依赖
  static void init(GetIt sl) {
    // 数据源
    sl.registerLazySingleton<ImageDataSource>(
      () => ImageDataSourceImpl(),
    );
    
    // 仓库
    sl.registerLazySingleton<ImageRepository>(
      () => ImageRepositoryImpl(sl<ImageDataSource>()),
    );
    
    sl.registerLazySingleton<PreferencesRepository>(
      () => PreferencesRepositoryImpl(),
    );
    
    // 用例
    sl.registerLazySingleton(
      () => SaveImageUseCase(sl<ImageRepository>()),
    );
    
    sl.registerLazySingleton(
      () => GetSavedColorUseCase(sl<PreferencesRepository>()),
    );
    
    sl.registerLazySingleton(
      () => SaveColorUseCase(sl<PreferencesRepository>()),
    );
    
    sl.registerLazySingleton(
      () => GetAttributeHistoryUseCase(sl<PreferencesRepository>()),
    );
    
    sl.registerLazySingleton(
      () => AddAttributeHistoryUseCase(sl<PreferencesRepository>()),
    );
    
    sl.registerLazySingleton(
      () => CreateMarkPointUseCase(),
    );
    
    // ViewModel
    sl.registerFactory(
      () => MarkPointFormProvider(
        saveImageUseCase: sl<SaveImageUseCase>(),
        getSavedColorUseCase: sl<GetSavedColorUseCase>(),
        saveColorUseCase: sl<SaveColorUseCase>(),
        getAttributeHistoryUseCase: sl<GetAttributeHistoryUseCase>(),
        addAttributeHistoryUseCase: sl<AddAttributeHistoryUseCase>(),
        createMarkPointUseCase: sl<CreateMarkPointUseCase>(),
      ),
    );
  }
} 