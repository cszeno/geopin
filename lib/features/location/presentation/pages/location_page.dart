import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/location/domain/entities/location.dart';
import '../../../../core/location/providers/location_service_provider.dart';
import '../widgets/accuracy_indicator.dart';
import '../widgets/location_card.dart';
import '../widgets/location_detail_card.dart';

/// 位置显示页面
class LocationPage extends StatelessWidget {
  /// 构造函数
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取位置服务提供者
    final locationService = Provider.of<LocationServiceProvider>(context);
    
    // 监听位置服务状态
    final serviceStatus = locationService.serviceStatus;
    final errorMessage = locationService.errorMessage;
    final accuracyLevel = locationService.accuracyLevel;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('高精度位置监测'),
        actions: [
          // 精度切换按钮
          PopupMenuButton<int>(
            icon: const Icon(Icons.tune),
            tooltip: '调整精度',
            onSelected: (value) => locationService.changeAccuracy(value),
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
        context: context,
        serviceStatus: serviceStatus,
        errorMessage: errorMessage,
        accuracyLevel: accuracyLevel,
        locationStream: locationService.locationStream,
        currentLocation: locationService.currentLocation,
        retryInitialization: locationService.retryInitialization,
      ),
    );
  }

  /// 构建页面主体
  Widget _buildBody({
    required BuildContext context,
    required LocationServiceStatus serviceStatus,
    required String? errorMessage,
    required int accuracyLevel,
    required Stream<Location>? locationStream,
    required Location? currentLocation,
    required Function() retryInitialization,
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
                onPressed: retryInitialization,
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

    // 如果已有当前位置，直接显示
    if (currentLocation != null) {
      return _buildLocationContent(currentLocation, accuracyLevel);
    }
    
    // 否则监听位置流
    return StreamBuilder<Location>(
      stream: locationStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildLocationContent(snapshot.data!, accuracyLevel);
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    '获取位置数据失败: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
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