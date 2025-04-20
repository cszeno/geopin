import 'package:flutter/material.dart';

/// 属性标签组件
/// 
/// 显示键值对属性的标签组件
class AttributeTagWidget extends StatelessWidget {
  /// 属性键
  final String keyText;
  
  /// 属性值
  final String valueText;
  
  /// 是否可点击状态
  final bool isActive;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 构造函数
  const AttributeTagWidget({
    Key? key,
    required this.keyText,
    required this.valueText,
    this.isActive = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
            : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3) 
              : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$keyText: $valueText',
              style: TextStyle(
                fontSize: 12,
                color: isActive 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey,
              ),
            ),
            if (isActive && onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.edit_outlined,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ] else if (!isActive && onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.add_circle_outline,
                size: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ]
          ],
        ),
      ),
    );
  }
} 