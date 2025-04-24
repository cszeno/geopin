import 'package:flutter/material.dart';

import '../../../../shared/sider_tool/map_side_toolbar.dart';


/// 工具重排序底部菜单组件
/// 用于调整工具栏中工具项的顺序
class ToolReorderSheet extends StatefulWidget {
  final List<MapToolItem> toolItems;
  final Function(List<MapToolItem>) onSave;

  const ToolReorderSheet({
    Key? key,
    required this.toolItems,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ToolReorderSheet> createState() => _ToolReorderSheetState();
}

class _ToolReorderSheetState extends State<ToolReorderSheet> {
  late List<MapToolItem> _reorderableTools;

  @override
  void initState() {
    super.initState();
    // 创建工具列表的副本
    _reorderableTools = List.from(widget.toolItems);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '调整工具顺序',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 说明文字
          const Text(
            '长按并拖动工具项来调整顺序',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // 可重排序列表
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _reorderableTools.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _reorderableTools.removeAt(oldIndex);
                  _reorderableTools.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final tool = _reorderableTools[index];
                return Card(
                  key: ValueKey(index),
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    leading: Icon(tool.icon),
                    title: Text(tool.label),
                    trailing: const Icon(Icons.drag_handle),
                  ),
                );
              },
            ),
          ),

          // 保存按钮
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  widget.onSave(_reorderableTools);
                  Navigator.pop(context);
                },
                child: const Text('保存', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 