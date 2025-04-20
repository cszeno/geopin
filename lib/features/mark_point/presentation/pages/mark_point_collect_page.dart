import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geopin/core/location/providers/location_service_provider.dart';
import 'package:geopin/features/mark_point/presentation/providers/mark_point_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../shared/mini_app/presentation/widgets/mini_app_grid_widget.dart';
import '../../domain/entities/mark_point_entity.dart';
import '../widgets/crosshair_marker.dart';
import '../widgets/nav_bar.dart';
import '../widgets/mark_point_form_sheet.dart';

class MarkPointCollectPage extends StatefulWidget {
  const MarkPointCollectPage({super.key});

  @override
  State<MarkPointCollectPage> createState() => _MarkPointCollectPageState();
}

class _MarkPointCollectPageState extends State<MarkPointCollectPage> {
  MapController mapController = MapController();

  // 获取所有标记点
  final List<Marker> allMarkers = [];
  LatLng _currentCenter = const LatLng(31.23, 121.47); // 默认初始位置

  @override
  void initState() {
    super.initState();
    // 监听地图控制器的地图准备好事件
    mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {
          _currentCenter = event.camera.center;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final markPointCollectProvider = Provider.of<MarkPointProvider>(context);

    for (int i = 0; i < markPointCollectProvider.points.length; i++) {
      final markPointEntity = markPointCollectProvider.points[i];
      allMarkers.add(_buildMarker(context, i, markPointEntity));
    }


    return Scaffold(
      body: Stack(
        children: [
          Consumer<LocationServiceProvider>(
            builder: (context, locationServiceProvider, child) {
              return FlutterMap(
                options: MapOptions(
                  initialCenter: _currentCenter,
                  onMapEvent: (event) {
                    if (event is MapEventMove) {
                      setState(() {
                        _currentCenter = event.camera.center;
                      });
                    }
                  },
                ),
                mapController: mapController,
                children: [
                  TileLayer(
                    urlTemplate:
                        'http://wprd04.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),

                  MarkerLayer(markers: allMarkers),

                  Center(
                    child: CrossCursorMarker(
                      coordinate: _currentCenter,
                      color: Colors.red,
                      size: 40.0,
                      strokeWidth: 4,
                      showCircle: true,
                    ),
                  ),
                ],
              );
            },
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: NavBar(
              onTap: (index) {
                _handleNavSelected(index, markPointCollectProvider);
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

  void _handleNavSelected(
    int index,
    MarkPointProvider markPointCollectProvider,
  ) {
    switch (index) {
      case 0: // 数据标签
        context.push("/mark_point_data");
        break;
      case 1: // 采集标签
        /// 打开标记点表单弹窗
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 允许弹窗高度超过默认值
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext bottomSheetContext) => MarkerPointFormSheet(
            latitude: _currentCenter.latitude,
            longitude: _currentCenter.longitude,
            onSubmit: (markPoint) {
              // 添加新的标记点
              markPointCollectProvider.addPoint(markPoint);
            },
          ),
        );
        break;
      case 2: // 更多标签
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 允许弹窗高度超过默认值
          builder:
              (BuildContext bottomSheetContext) =>
                  _buildBottomSheet(bottomSheetContext),
        );
        break;
    }
  }

  /// 构建单个标记
  Marker _buildMarker(
    BuildContext context,
    int index,
    MarkPointEntity markPointEntity,
  ) {
    // 使用主题中定义的尺寸常量
    const double markerWidth = 50;
    /// 高度必须和children中所有子组件之和高度相同，否则容易出问题
    const double markerHeight = 30;
    const double iconSize = 30;

    return Marker(
      point: LatLng(markPointEntity.latitude, markPointEntity.longitude),
      width: markerWidth,
      height: markerHeight,
      rotate: true,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_pin, color: markPointEntity.color, size: iconSize),
            // 添加底部空间，使定位图标针尖部分对准坐标点
          ],
        ),
      ),
    );
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

          Expanded(child: MiniAppGridWidget()),
        ],
      ),
    );
  }
}
