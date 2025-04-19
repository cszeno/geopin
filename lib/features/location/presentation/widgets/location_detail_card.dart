import 'package:flutter/material.dart';
import 'package:geopin/i18n/app_localizations_extension.dart';

import '../../../../core/location/domain/entities/location.dart';

/// 显示位置详细信息的卡片
class LocationDetailCard extends StatelessWidget {
  /// 位置数据
  final Location location;

  /// 构造函数
  const LocationDetailCard({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    // 提取详细数据
    final double speed = location.speed ?? 0.0;
    final double bearing = location.bearing ?? 0.0;
    final double verticalAccuracy = location.verticalAccuracy ?? 0.0;
    final String provider = location.provider ?? context.l10n.unknown;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.detailedInfo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // 速度
            _buildDetailRow(
              context: context,
              title: context.l10n.speed,
              value: '${(speed * 3.6).toStringAsFixed(2)} km/h',
            ),

            // 方向
            _buildDetailRow(
              context: context,
              title: context.l10n.direction,
              value: '${bearing.toStringAsFixed(1)}°',
            ),

            // 水平精度
            _buildDetailRow(
              context: context,
              title: context.l10n.horizontalAccuracy,
              value: '±${location.accuracy.toStringAsFixed(2)}${context.l10n.meters}',
            ),

            // 垂直精度
            _buildDetailRow(
              context: context,
              title: context.l10n.verticalAccuracy,
              value: '±${verticalAccuracy.toStringAsFixed(2)}${context.l10n.meters}',
            ),

            // 提供者
            _buildDetailRow(
              context: context,
              title: context.l10n.locationProvider,
              value: provider,
            ),

            // 速度精度
            if (location.speedAccuracy != null)
              _buildDetailRow(
                context: context,
                title: context.l10n.speedAccuracy,
                value: '±${location.speedAccuracy!.toStringAsFixed(2)} m/s',
              ),

            // 方向精度
            if (location.bearingAccuracy != null)
              _buildDetailRow(
                context: context,
                title: context.l10n.directionAccuracy,
                value: '±${location.bearingAccuracy!.toStringAsFixed(2)}°',
              ),
          ],
        ),
      ),
    );
  }

  /// 构建详细信息行
  Widget _buildDetailRow({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 