import 'package:flutter/material.dart';
import 'package:geopin/core/constants/app_colors.dart';
import 'package:geopin/core/theme/app_theme.dart';

import '../widgets/nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景
          // Container(
          //   color: Colors.grey[200],
          // ),

          // 中间内容
          Center(
            child: Text(
              'Selected Tab: ${_getTabName(_selectedIndex)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // 底部按钮栏
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: NavBar(
              selectedIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              buttons: [
                CustomButtonData(
                  icon: Icons.data_usage,
                  label: '数据',
                ),
                CustomButtonData(
                  icon: Icons.location_on,
                  label: '采集',
                  color: Theme.of(context).colorScheme.primary
                ),
                CustomButtonData(
                  icon: Icons.grid_view,
                  label: '更多',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return '数据 (Data)';
      case 1:
        return '采集 (Collect)';
      case 2:
        return '更多 (More)';
      default:
        return '';
    }
  }
}
