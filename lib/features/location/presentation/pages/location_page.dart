import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/location/domain/entities/location.dart';
import '../../../../core/location/providers/location_providers.dart';
import '../providers/location_controller.dart';
import '../widgets/accuracy_indicator.dart';
import '../widgets/location_card.dart';
import '../widgets/location_detail_card.dart';

/// 位置显示页面
class LocationPage extends ConsumerStatefulWidget {
  /// 构造函数
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  @override
  void initState() {
    super.initState();
    // 在初始化时启动位置服务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationControllerProvider.notifier).initializeLocationService();
    });
  }

  @override
  void dispose() {
    // 在页面销毁时停止位置服务
    ref.read(locationControllerProvider.notifier).stopLocationService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听位置服务状态
    final serviceStatus = ref.watch(locationServiceStatusProvider);
    final errorMessage = ref.watch(locationErrorMessageProvider);
    final accuracyLevel = ref.watch(locationAccuracyProvider);
    
    // 监听位置数据流
    final locationData = ref.watch(locationStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('高精度位置监测'),
        actions: [
          // 精度切换按钮
          PopupMenuButton<int>(
            icon: const Icon(Icons.tune),
            tooltip: '调整精度',
            onSelected: (accuracy) {
              ref.read(locationControllerProvider.notifier).changeAccuracy(accuracy);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Text('低精度 (省电)'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('平衡精度'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('高精度 (最准确)'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(
        serviceStatus: serviceStatus,
        errorMessage: errorMessage,
        accuracyLevel: accuracyLevel,
        locationData: locationData,
      ),
    );
  }

  /// 构建页面主体
  Widget _buildBody({
    required LocationServiceStatus serviceStatus,
    required String? errorMessage,
    required int accuracyLevel,
    required AsyncValue<Location> locationData,
  }) {
    // 显示错误信息
    if (serviceStatus == LocationServiceStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? '位置服务发生错误',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(locationControllerProvider.notifier).initializeLocationService();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    // 显示加载中
    if (serviceStatus == LocationServiceStatus.initializing || 
        serviceStatus == LocationServiceStatus.uninitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在初始化位置服务...'),
          ],
        ),
      );
    }

    // 根据位置数据状态显示内容
    return locationData.when(
      data: (location) => _buildLocationContent(location, accuracyLevel),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                '获取位置数据失败: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建位置内容
  Widget _buildLocationContent(Location location, int accuracyLevel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 精度指示器
          AccuracyIndicator(
            accuracyLevel: accuracyLevel,
            accuracy: location.accuracy,
          ),

          const SizedBox(height: 24),

          // 位置数据卡片
          LocationCard(location: location),

          const SizedBox(height: 24),

          // 详细信息卡片
          LocationDetailCard(location: location),
        ],
      ),
    );
  }
} 