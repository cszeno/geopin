import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';



enum CrossCursorMode {
  /// 全屏光标.
  full,

  /// 屏幕中心
  center,

  /// 不可见
  none,
}

/// 十字光标组件
/// 用于在地图中央显示位置标记
class CrossCursorMarker extends StatelessWidget {
  /// 光标颜色
  final Color color;

  /// 光标大小
  final double size;

  /// 光标线宽
  final double strokeWidth;

  /// 是否显示圆形外框
  final bool showCircle;

  /// 平面坐标
  final LatLng coordinate;

  /// 是否为紧凑模式
  /// false : 紧凑模式，十字光标仅限于size大小范围内
  /// true: 全屏贯穿模式，十字光标贯穿整个屏幕
  final CrossCursorMode crossharMode;

  const CrossCursorMarker({
    super.key,
    required this.coordinate,
    this.color = Colors.red,
    this.size = 24.0,
    this.strokeWidth = 2.0,
    this.showCircle = false,
    this.crossharMode = CrossCursorMode.center,
  });

  /// 是否为全屏模式
  bool get isFullScreen => crossharMode == CrossCursorMode.full;

  @override
  Widget build(BuildContext context) {
    return _buildFullScreenCrosshair();
  }

  /// 构建十字光标
  Widget _buildFullScreenCrosshair() {
    // 如果是none模式，则不显示任何内容
    if (crossharMode == CrossCursorMode.none) {
      return const SizedBox.shrink();
    }
    
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 主十字光标
          LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: isFullScreen ? Size(
                  constraints.maxWidth > 0 ? constraints.maxWidth : double
                      .infinity,
                  constraints.maxHeight > 0 ? constraints.maxHeight : double
                      .infinity,
                ) : Size(size, size),
                painter: _CrosshairPainter(
                  color: color,
                  strokeWidth: strokeWidth,
                  isFullScreen: isFullScreen,
                ),
              );
            },
          ),

          // 坐标显示 - 在屏幕中心上方
          Padding(
            padding: const EdgeInsets.only(top: 80), // 位于中心点下方
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.5), width: 1),
              ),
              child: Text(
                '${coordinate.latitude.toStringAsFixed(6)}°, ${coordinate
                    .longitude.toStringAsFixed(6)}°',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 十字光标绘制器
class _CrosshairPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isFullScreen;

  _CrosshairPainter({
    required this.color,
    required this.strokeWidth,
    this.isFullScreen = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    // 获取中心点
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    if (isFullScreen) {
      // 全屏模式：线条贯穿整个屏幕
      // 绘制横线

      paint.strokeWidth = strokeWidth / 2;

      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width, centerY),
        paint,
      );
      
      // 绘制竖线
      canvas.drawLine(
        Offset(centerX, 0),
        Offset(centerX, size.height),
        paint,
      );
    } else {
      // 紧凑模式：四条短线和中心点
      final lineLength = size.width / 2; // 留出空间放中心点
      final centerGap = 10.0; // 中心点周围的间隙

      // 绘制左线
      canvas.drawLine(
        Offset(centerX - lineLength, centerY),
        Offset(centerX - centerGap, centerY),
        paint,
      );

      // 绘制右线
      canvas.drawLine(
        Offset(centerX + centerGap, centerY),
        Offset(centerX + lineLength, centerY),
        paint,
      );

      // 绘制上线
      canvas.drawLine(
        Offset(centerX, centerY - lineLength),
        Offset(centerX, centerY - centerGap),
        paint,
      );

      // 绘制下线
      canvas.drawLine(
        Offset(centerX, centerY + centerGap),
        Offset(centerX, centerY + lineLength),
        paint,
      );

      // 绘制中心点
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        Offset(centerX, centerY),
        strokeWidth, // 使用线宽作为点的大小
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CrosshairPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
