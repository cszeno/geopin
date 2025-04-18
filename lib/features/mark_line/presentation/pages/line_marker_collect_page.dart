import 'package:flutter/material.dart';

/// 标记线采集页面
class LineMarkerCollectPage extends StatefulWidget {
  /// 构造函数
  const LineMarkerCollectPage({super.key});

  @override
  State<LineMarkerCollectPage> createState() => _LineMarkerCollectPageState();
}

class _LineMarkerCollectPageState extends State<LineMarkerCollectPage> {
  final List<String> _points = [];
  
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
              Icons.linear_scale,
              color: Colors.blue,
              size: 48,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 标题
          const Text(
            '标记线采集',
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
              '添加多个点位创建线段，测量距离和相关数据',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 已添加的点位列表
          if (_points.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已添加 ${_points.length} 个点',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_points.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Text('点 ${index + 1}: ${_points[index]}'),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 16),
                            onPressed: () {
                              setState(() {
                                _points.removeAt(index);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Colors.red[300],
                          ),
                        ],
                      ),
                    );
                  }),
                  if (_points.length >= 2) ...[
                    const Divider(),
                    Text(
                      '总距离: ${(_points.length * 12.5).toStringAsFixed(1)} 米',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    // 模拟添加新点位
                    _points.add('39°${54 + _points.length}′N, 116°${23 + _points.length}′E');
                  });
                },
                icon: const Icon(Icons.add_location),
                label: const Text('添加点位'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              
              const SizedBox(width: 16),
              
              ElevatedButton.icon(
                onPressed: _points.length >= 2 ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已保存标记线'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } : null,
                icon: const Icon(Icons.save),
                label: const Text('保存标记线'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 