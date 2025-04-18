import 'package:flutter/material.dart';

/// 标记点采集页面
class PointMarkerCollectPage extends StatelessWidget {
  /// 构造函数
  const PointMarkerCollectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_searching,
              color: Colors.blue,
              size: 48,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 标题
          const Text(
            '标记点采集',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 描述
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              '在当前位置创建新的标记点，记录位置信息和相关数据',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 采集按钮
          ElevatedButton.icon(
            onPressed: () {
              // 采集操作演示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('标记点采集成功'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.add_location),
            label: const Text('采集标记点'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
} 