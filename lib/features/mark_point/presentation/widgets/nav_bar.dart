import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final List<CustomButtonData> buttons;
  final Function(int) onTap;
  final int selectedIndex;

  const NavBar({
    super.key,
    required this.buttons,
    required this.onTap,
    this.selectedIndex = 2,
  }) : assert(buttons.length == 3, 'CustomButtonBar requires exactly 3 buttons');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // 增加总高度，为上下溢出留出空间
      child: Stack(
        alignment: Alignment.center, // 修改为中心对齐
        children: [
          // Main container
          Positioned(
            bottom: 20, // 从底部向上偏移，使中间按钮可以向下溢出
            left: 50,
            right: 50,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _buildSideButton(buttons[0], 0)),
                  const Spacer(),
                  Expanded(child: _buildSideButton(buttons[2], 2)),
                ],
              ),
            ),
          ),
          
          // Middle button that protrudes
          Positioned(
            child: _buildMiddleButton(buttons[1]),
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton(CustomButtonData button, int index) {
    final isSelected = index == selectedIndex;
    
    // 使用Material+InkWell组合提供更好的触摸反馈
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(30),
            right: Radius.circular(30),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                button.icon,
                size: 24,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 2),
              Text(
                button.label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleButton(CustomButtonData button) {
    return GestureDetector(
      onTap: () => onTap(1),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: button.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: button.color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              button.icon,
              size: 28,
              color: Colors.white,
            ),
            const SizedBox(height: 2),
            Text(
              button.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButtonData {
  final IconData icon;
  final String label;
  final Color color;

  CustomButtonData({
    required this.icon,
    required this.label,
    this.color = Colors.orange,
  });
} 