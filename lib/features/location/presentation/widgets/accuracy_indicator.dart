import 'package:flutter/material.dart';

/// 位置精度指示器组件
class AccuracyIndicator extends StatelessWidget {
  /// 精度级别: 0-低, 1-平衡, 2-高
  final int accuracyLevel;
  
  /// 精度值（米）
  final double? accuracy;

  /// 构造函数
  const AccuracyIndicator({
    super.key,
    required this.accuracyLevel,
    this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    final String accuracyText = accuracyLevel == 0
        ? '低精度模式'
        : accuracyLevel == 1
            ? '平衡精度模式'
            : '高精度模式';

    final Color accuracyColor = accuracyLevel == 0
        ? Colors.orange
        : accuracyLevel == 1
            ? Colors.blue
            : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: accuracyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accuracyColor),
      ),
      child: Row(
        children: [
          Icon(Icons.gps_fixed, color: accuracyColor),
          const SizedBox(width: 8),
          Text(
            accuracyText,
            style: TextStyle(
              color: accuracyColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (accuracy != null)
            Text(
              '精度: ±${accuracy!.toStringAsFixed(2)}米',
              style: TextStyle(color: accuracyColor),
            ),
        ],
      ),
    );
  }
} 