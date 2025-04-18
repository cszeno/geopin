import 'package:flutter/material.dart';

/// 标记线数据页面
class LineMarkerDataPage extends StatelessWidget {
  /// 构造函数
  const LineMarkerDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Text(
            '标记线数据',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 数据卡片
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题行
                        Row(
                          children: [
                            const Icon(
                              Icons.linear_scale,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '线段 #${index + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        
                        const Divider(height: 24),
                        
                        // 详细信息
                        _buildInfoRow('点数', '${3 + index} 个点'),
                        _buildInfoRow('总长度', '${(index + 1) * 54.8} 米'),
                        _buildInfoRow('起点', '39°54′N, 116°23′E'),
                        _buildInfoRow('终点', '39°${54 + index}′N, 116°${23 + index}′E'),
                        
                        const SizedBox(height: 16),
                        
                        // 点位列表
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '点位列表',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...List.generate(3 + index, (pointIndex) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    '点 ${pointIndex + 1}: 39°${54 + pointIndex}′N, 116°${23 + pointIndex}′E',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 操作按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('查看'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('编辑'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('删除'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 