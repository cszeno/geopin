import 'package:flutter/material.dart';

import '../../../../core/location/domain/entities/location.dart';

/// 显示位置数据的卡片
class LocationCard extends StatelessWidget {
  /// 位置数据
  final Location location;

  /// 构造函数
  const LocationCard({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前位置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // 纬度
            _buildLocationRow(
              icon: Icons.north,
              title: '纬度',
              value: '${location.latitude.toStringAsFixed(8)}°',
              subtitle: location.latitude > 0 ? '北纬' : '南纬',
            ),

            const SizedBox(height: 12),

            // 经度
            _buildLocationRow(
              icon: Icons.east,
              title: '经度',
              value: '${location.longitude.toStringAsFixed(8)}°',
              subtitle: location.longitude > 0 ? '东经' : '西经',
            ),

            const SizedBox(height: 12),

            // 海拔
            _buildLocationRow(
              icon: Icons.height,
              title: '海拔',
              value: '${location.altitude.toStringAsFixed(2)}米',
              subtitle: '相对海平面',
            ),

            const SizedBox(height: 8),
            const Divider(),

            // 更新时间
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '更新时间: ${_formatTime(location.timestamp)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建位置数据行
  Widget _buildLocationRow({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue[700]),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 格式化时间戳
  String _formatTime(int timestamp) {
    try {
      final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
    } catch (e) {
      return '未知';
    }
  }

  /// 格式化为两位数
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
} 