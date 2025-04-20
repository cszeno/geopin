import 'package:flutter/material.dart';

/// 颜色选择器组件
/// 
/// 用于选择标记点颜色的横向滚动列表
class ColorPickerWidget extends StatelessWidget {
  /// 当前选中的颜色
  final Color selectedColor;
  
  /// 可选的颜色列表
  final List<Color> availableColors;
  
  /// 颜色选择回调
  final Function(Color) onColorSelected;
  
  /// 构造函数
  const ColorPickerWidget({
    Key? key,
    required this.selectedColor,
    required this.availableColors,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // 固定高度
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // 横向滚动
        itemCount: availableColors.length,
        itemBuilder: (context, index) {
          final color = availableColors[index];
          // 比较颜色值而不是对象引用
          final isSelected = selectedColor.value == color.value;
          
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
} 