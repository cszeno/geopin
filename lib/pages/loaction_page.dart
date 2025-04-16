import 'dart:async';
import 'package:flutter/material.dart';

import '../services/location_service.dart';

/// 位置显示页面
/// 展示实时高精度位置信息
class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  // 位置服务实例
  final LocationService _locationService = LocationService();

  // 位置数据
  Map<String, dynamic>? _locationData;

  // 位置流订阅
  StreamSubscription<Map<String, dynamic>>? _locationSubscription;

  // 位置精度级别
  int _accuracyLevel = 2; // 默认高精度

  // 是否已初始化
  bool _isInitialized = false;

  // 错误信息
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  @override
  void dispose() {
    // 取消位置订阅
    _locationSubscription?.cancel();
    // 停止位置服务
    _locationService.stopLocationUpdates();
    super.dispose();
  }

  /// 初始化位置服务
  Future<void> _initLocationService() async {
    try {
      // 请求位置权限
      final bool hasPermission = await _locationService.requestLocationPermission();

      if (!hasPermission) {
        setState(() {
          _errorMessage = '未获得位置权限，请在设置中开启位置服务和应用权限';
        });
        return;
      }

      // 初始化位置服务
      final bool initialized = await _locationService.initLocationService();

      if (!initialized) {
        setState(() {
          _errorMessage = '位置服务初始化失败';
        });
        return;
      }

      // 设置位置精度
      await _locationService.setLocationAccuracy(_accuracyLevel);

      // 开始监听位置更新
      _locationSubscription = _locationService.startLocationUpdates().listen(
              (locationData) {
            setState(() {
              _locationData = locationData;
              _isInitialized = true;
              _errorMessage = null;
            });
          },
          onError: (error) {
            setState(() {
              _errorMessage = '位置监听错误: $error';
            });
          }
      );

      setState(() {
        _isInitialized = true;
      });

    } catch (e) {
      setState(() {
        _errorMessage = '初始化位置服务出错: $e';
      });
    }
  }

  /// 更改位置精度
  Future<void> _changeAccuracy(int level) async {
    if (_accuracyLevel == level) return;

    setState(() {
      _accuracyLevel = level;
    });

    await _locationService.setLocationAccuracy(level);

    // 显示精度变更提示
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已切换到${level == 0 ? '低' : level == 1 ? '平衡' : '高'}精度模式'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高精度位置监测'),
        actions: [
          // 精度切换按钮
          PopupMenuButton<int>(
            icon: const Icon(Icons.tune),
            tooltip: '调整精度',
            onSelected: _changeAccuracy,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Text('低精度 (省电)'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('平衡精度'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('高精度 (最准确)'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    // 显示错误信息
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initLocationService,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    // 显示加载中
    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在初始化位置服务...'),
          ],
        ),
      );
    }

    // 显示位置信息
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 精度指示器
          _buildAccuracyIndicator(),

          const SizedBox(height: 24),

          // 位置数据卡片
          _buildLocationCard(),

          const SizedBox(height: 24),

          // 详细信息卡片
          _buildDetailCard(),
        ],
      ),
    );
  }

  /// 构建精度指示器
  Widget _buildAccuracyIndicator() {
    final String accuracyText = _accuracyLevel == 0
        ? '低精度模式'
        : _accuracyLevel == 1
        ? '平衡精度模式'
        : '高精度模式';

    final Color accuracyColor = _accuracyLevel == 0
        ? Colors.orange
        : _accuracyLevel == 1
        ? Colors.blue
        : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: accuracyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accuracyColor),
      ),
      child: Row(
        children: [
          Icon(Icons.gps_fixed, color: accuracyColor),
          const SizedBox(width: 8),
          Text(
            accuracyText,
            style: TextStyle(
              color: accuracyColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_locationData != null && _locationData!.containsKey('accuracy'))
            Text(
              '精度: ±${_locationData!['accuracy'].toStringAsFixed(2)}米',
              style: TextStyle(color: accuracyColor),
            ),
        ],
      ),
    );
  }

  /// 构建位置数据卡片
  Widget _buildLocationCard() {
    if (_locationData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('等待位置数据...'),
          ),
        ),
      );
    }

    // 提取位置数据
    final double latitude = _locationData!['latitude'] ?? 0.0;
    final double longitude = _locationData!['longitude'] ?? 0.0;
    final double altitude = _locationData!['altitude'] ?? 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前位置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // 纬度
            _buildLocationRow(
              icon: Icons.north,
              title: '纬度',
              value: '${latitude.toStringAsFixed(8)}°',
              subtitle: latitude > 0 ? '北纬' : '南纬',
            ),

            const SizedBox(height: 12),

            // 经度
            _buildLocationRow(
              icon: Icons.east,
              title: '经度',
              value: '${longitude.toStringAsFixed(8)}°',
              subtitle: longitude > 0 ? '东经' : '西经',
            ),

            const SizedBox(height: 12),

            // 海拔
            _buildLocationRow(
              icon: Icons.height,
              title: '海拔',
              value: '${altitude.toStringAsFixed(2)}米',
              subtitle: '相对海平面',
            ),

            const SizedBox(height: 8),
            const Divider(),

            // 更新时间
            if (_locationData!.containsKey('time'))
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '更新时间: ${_formatTime(_locationData!['time'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建位置数据行
  Widget _buildLocationRow({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue[700]),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 构建详细信息卡片
  Widget _buildDetailCard() {
    if (_locationData == null) {
      return const SizedBox.shrink();
    }

    // 提取详细数据
    final double speed = _locationData!['speed'] ?? 0.0;
    final double bearing = _locationData!['bearing'] ?? 0.0;
    final double verticalAccuracy = _locationData!['verticalAccuracy'] ?? 0.0;
    final String provider = _locationData!['provider'] ?? '未知';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '详细信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // 速度
            _buildDetailRow(
              title: '速度',
              value: '${(speed * 3.6).toStringAsFixed(2)} km/h',
            ),

            // 方向
            _buildDetailRow(
              title: '方向',
              value: '${bearing.toStringAsFixed(1)}°',
            ),

            // 垂直精度
            _buildDetailRow(
              title: '垂直精度',
              value: '±${verticalAccuracy.toStringAsFixed(2)}米',
            ),

            // 提供者
            _buildDetailRow(
              title: '位置提供者',
              value: provider,
            ),

            // 速度精度
            if (_locationData!.containsKey('speedAccuracy'))
              _buildDetailRow(
                title: '速度精度',
                value: '±${_locationData!['speedAccuracy'].toStringAsFixed(2)} m/s',
              ),

            // 方向精度
            if (_locationData!.containsKey('bearingAccuracy'))
              _buildDetailRow(
                title: '方向精度',
                value: '±${_locationData!['bearingAccuracy'].toStringAsFixed(2)}°',
              ),
          ],
        ),
      ),
    );
  }

  /// 构建详细信息行
  Widget _buildDetailRow({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化时间戳
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '未知';

    try {
      final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          timestamp is double ? timestamp.toInt() : timestamp
      );

      return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
    } catch (e) {
      return '未知';
    }
  }

  /// 格式化为两位数
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}