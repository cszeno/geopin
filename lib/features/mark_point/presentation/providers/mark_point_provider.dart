import 'package:flutter/material.dart';
import 'package:geopin/features/mark_point/domain/entities/mark_point_entity.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class MarkPointProvider with ChangeNotifier {
  
  List<MarkPointEntity> _points = [];
  List<LatLng> _latLngs = [];

  get points => _points;
  get latLngs => _latLngs;
  
  /// 添加标记点（通过LatLng坐标点）
  /// 
  /// 这是为了向后兼容现有代码的方法
  /// [latLng]: 地理坐标点
  void addPoint(dynamic pointData) {
    if (pointData is LatLng) {
      // 旧的方法，接收LatLng对象
      _addPointFromLatLng(pointData);
    } else if (pointData is MarkPointEntity) {
      // 新的方法，直接接收MarkPointEntity对象
      _addPointEntity(pointData);
    }
  }

  /// 内部方法：从LatLng添加点
  void _addPointFromLatLng(LatLng latLng) {
    var markPoint = MarkPointEntity(
      id: DateTime.now().millisecondsSinceEpoch, // 使用时间戳作为临时ID
      uuid: const Uuid().v4(),
      name: "标记点 ${_points.length + 1}",
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
    _latLngs.add(latLng);
    _points.add(markPoint);

    notifyListeners();
  }

  /// 内部方法：直接添加MarkPointEntity
  void _addPointEntity(MarkPointEntity markPoint) {
    _latLngs.add(LatLng(markPoint.latitude, markPoint.longitude));
    _points.add(markPoint);

    notifyListeners();
  }
  
  void getLatLngList() {
    
  }
}
