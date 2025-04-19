import 'package:flutter/material.dart';
import 'package:geopin/i18n/app_localizations_extension.dart';
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
    // 使用监听构建器确保能够响应更新
    return Consumer<LocationServiceProvider>(
      builder: (context, locationService, _) {

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.appTitle),
            actions: [
              // 精度切换按钮
              PopupMenuButton<int>(
                icon: const Icon(Icons.tune),
                tooltip: context.l10n.adjustAccuracy,
                onSelected: (value) => locationService.changeAccuracy(value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text(context.l10n.lowAccuracy),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Text(context.l10n.balancedAccuracy),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text(context.l10n.highAccuracy),
                  ),
                ],
              ),
            ],
          ),
          body: _buildBody(
            context: context,
            locationStream: locationService.locationStream,
            currentLocation: locationService.currentLocation,
            retryInitialization: locationService.retryInitialization,
            accuracyLevel: locationService.accuracyLevel,
          ),
        );
      },
    );
  }

  /// 构建页面主体
  Widget _buildBody({
    required BuildContext context,
    required int accuracyLevel,
    required Stream<Location>? locationStream,
    required Location? currentLocation,
    required Function() retryInitialization,
  }) {
    // 如果已有当前位置，优先显示
    if (currentLocation != null) {
      // 同时监听流以获取更新
      return _buildLocationWithUpdates(
        currentLocation: currentLocation, 
        locationStream: locationStream,
        accuracyLevel: accuracyLevel
      );
    }
    
    // 否则仅监听位置流
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
                    context.l10n.failedToGetLocation(snapshot.error.toString()),
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
  
  /// 构建位置内容，并监听更新
  Widget _buildLocationWithUpdates({
    required Location currentLocation,
    required Stream<Location>? locationStream,
    required int accuracyLevel,
  }) {
    if (locationStream == null) {
      return _buildLocationContent(currentLocation, accuracyLevel);
    }
    
    return StreamBuilder<Location>(
      stream: locationStream,
      initialData: currentLocation,
      builder: (context, snapshot) {
        // 显示最新的位置数据
        final location = snapshot.data ?? currentLocation;
        return _buildLocationContent(location, accuracyLevel);
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