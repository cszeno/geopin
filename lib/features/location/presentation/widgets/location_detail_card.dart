import 'package:flutter/material.dart';

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
    final String provider = location.provider ?? '未知';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '详细信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // 速度
            _buildDetailRow(
              title: '速度',
              value: '${(speed * 3.6).toStringAsFixed(2)} km/h',
            ),

            // 方向
            _buildDetailRow(
              title: '方向',
              value: '${bearing.toStringAsFixed(1)}°',
            ),

            // 水平精度
            _buildDetailRow(
              title: '水平精度',
              value: '±${location.accuracy.toStringAsFixed(2)}米',
            ),

            // 垂直精度
            _buildDetailRow(
              title: '垂直精度',
              value: '±${verticalAccuracy.toStringAsFixed(2)}米',
            ),

            // 提供者
            _buildDetailRow(
              title: '位置提供者',
              value: provider,
            ),

            // 速度精度
            if (location.speedAccuracy != null)
              _buildDetailRow(
                title: '速度精度',
                value: '±${location.speedAccuracy!.toStringAsFixed(2)} m/s',
              ),

            // 方向精度
            if (location.bearingAccuracy != null)
              _buildDetailRow(
                title: '方向精度',
                value: '±${location.bearingAccuracy!.toStringAsFixed(2)}°',
              ),
          ],
        ),
      ),
    );
  }

  /// 构建详细信息行
  Widget _buildDetailRow({
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