import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate:
      'http://wprd04.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}',
  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
);

/// 标记点数据页面
class MarkPointPage extends StatelessWidget {
  /// 构造函数
  const MarkPointPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(initialCenter: const LatLng(31.23, 121.47)),
          children: [openStreetMapTileLayer],
        ),
      ],
    );
  }
}
