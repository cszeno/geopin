import 'package:flutter/material.dart';

/// 动画位置标记组件
/// 用于在地图上显示当前位置，带有脉冲动画效果
class AnimatedLocationMarker extends StatefulWidget {
  final Color color;
  final double size;
  
  const AnimatedLocationMarker({
    super.key,
    this.color = Colors.blue,
    this.size = 20.0,
  });

  @override
  State<AnimatedLocationMarker> createState() => _AnimatedLocationMarkerState();
}

class _AnimatedLocationMarkerState extends State<AnimatedLocationMarker> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    
    _animation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 外层脉冲圆圈
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: widget.size * _animation.value * 5,
              height: widget.size * _animation.value * 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.2),
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
            );
          },
        ),

        // 中层圆圈1
        Container(
          width: widget.size * 3,
          height: widget.size * 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.5),
          ),
        ),

        // 中层圆圈2
        Container(
          width: widget.size * 4,
          height: widget.size * 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.2),
          ),
        ),
        
        // 中心点
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            border: Border.all(
              color: Colors.red,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 