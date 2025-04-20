import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/mini_app/presentation/widgets/mini_app_grid_widget.dart';
import '../widgets/nav_bar.dart';

class MarkPointCollectPage extends StatefulWidget {
  const MarkPointCollectPage({super.key});

  @override
  State<MarkPointCollectPage> createState() => _MarkPointCollectPageState();
}

class _MarkPointCollectPageState extends State<MarkPointCollectPage> {

  @override
  Widget build(BuildContext context)  {


    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: const LatLng(31.23, 121.47)),
            children: [
              TileLayer(
                urlTemplate:
                'http://wprd04.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
            ],
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: NavBar(
              onTap: (index) {
                _handleNavSelected(index);
              },
              buttons: [
                CustomButtonData(
                  icon: Icons.data_usage,
                  label: '数据',
                  color: Theme.of(context).colorScheme.primary,
                ),
                CustomButtonData(
                  icon: Icons.location_on,
                  label: '采集',
                  color: Theme.of(context).colorScheme.primary,
                ),
                CustomButtonData(
                  icon: Icons.grid_view,
                  label: '更多',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavSelected(int index) {
    switch (index) {
      case 0: // 数据标签
        context.push("/mark_point_data");
        break;
      case 1: // 采集标签
        /// TODO 采集事件待实现
        break;
      case 2: // 更多标签
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 允许弹窗高度超过默认值
          builder: (BuildContext bottomSheetContext) => _buildBottomSheet(bottomSheetContext),
        );
        break;
    }
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖动指示条
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: MiniAppGridWidget(),
          ),
        ],
      ),
    );
  }
}


