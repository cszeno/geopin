import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geopin/core/location/providers/location_service_provider.dart';
import 'package:geopin/features/mark_point/presentation/providers/mark_point_provider.dart';
import 'package:geopin/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../shared/mini_app/presentation/widgets/mini_app_grid_widget.dart';
import '../../domain/entities/mark_point_entity.dart';
import '../widgets/crosshair_marker.dart';
import '../widgets/nav_bar.dart';
import 'mark_point_form_page.dart';
import 'mark_point_detail_sheet.dart';

class MarkPointCollectPage extends StatefulWidget {
  const MarkPointCollectPage({super.key});

  @override
  State<MarkPointCollectPage> createState() => _MarkPointCollectPageState();
}

class _MarkPointCollectPageState extends State<MarkPointCollectPage> {
  MapController mapController = MapController();

  // 当前地图中心
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
    return Scaffold(
      body: Consumer<MarkPointProvider>(
        builder: (context, markPointProvider, child) {
          // 从Provider中创建标记列表
          final markers =
              markPointProvider.points
                  .map((markPoint) => _buildMarker(context, markPoint))
                  .toList();

          return Stack(
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
                        userAgentPackageName:
                            'dev.fleaflet.flutter_map.example',
                      ),

                      MarkerLayer(markers: markers),

                      Center(
                        child: CrossCursorMarker(
                          coordinate: _currentCenter,
                          color: Theme.of(context).primaryColor,
                          size: 40.0,
                          strokeWidth: 4,
                          showCircle: true,
                        ),
                      ),

                      Positioned(
                        left: 0,
                        right: 0,
                        top: 60,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).shadowColor.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.satellite_alt,
                                          size: 16,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "卫星位置",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.gps_fixed,
                                          size: 12,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "精度：${locationServiceProvider.currentLocation?.accuracy.toStringAsFixed(2)}m",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 60,
                                  width: 1,
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.2),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildCoordinateItem(
                                          null,
                                          "B:",
                                          "${locationServiceProvider.currentLocation?.latitude.toStringAsFixed(6)}°",
                                        ),
                                        const SizedBox(height: 4),
                                        _buildCoordinateItem(
                                          null,
                                          "L:",
                                          "${locationServiceProvider.currentLocation?.longitude.toStringAsFixed(6)}°",
                                        ),
                                        const SizedBox(height: 4),
                                        _buildCoordinateItem(
                                          null,
                                          "H:",
                                          "${locationServiceProvider.currentLocation?.altitude.toStringAsFixed(6)}m",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Positioned(
                      //     top: 20,
                      //     child: )
                    ],
                  );
                },
              ),

              // 显示加载状态
              if (markPointProvider.isLoading)
                const Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      elevation: 4,
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text('正在加载标记点...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: NavBar(
                  onTap: (index) {
                    _handleNavSelected(index, markPointProvider);
                  },
                  buttons: [
                    CustomButtonData(
                      icon: Icons.data_usage,
                      label: '数据',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    CustomButtonData(
                      icon: Icons.push_pin,
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

              // 错误提示
              if (markPointProvider.errorMessage != null)
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            markPointProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleNavSelected(int index, MarkPointProvider markPointProvider) {
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
          builder:
              (BuildContext bottomSheetContext) => MarkPointFormPage(
                latitude: _currentCenter.latitude,
                longitude: _currentCenter.longitude,
                onSubmit: (markPoint) {
                  // 添加新的标记点 - Provider会自动通知UI更新
                  markPointProvider.addPoint(markPoint);
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
  Marker _buildMarker(BuildContext context, MarkPointEntity markPointEntity) {
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
        onTap: () {
          _showMarkPointDetail(context, markPointEntity);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.push_pin, color: markPointEntity.color, size: iconSize),
            // 添加底部空间，使定位图标针尖部分对准坐标点
          ],
        ),
      ),
    );
  }

  /// 显示标记点详情
  void _showMarkPointDetail(BuildContext context, MarkPointEntity markPoint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MarkPointDetailSheet(markPoint: markPoint),
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

  /// 构建坐标项目小部件
  Widget _buildCoordinateItem(IconData? icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
