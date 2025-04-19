import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/event/event_bus.dart';
import '../../../../features/location/presentation/pages/location_page.dart';
import '../../../mark_line/presentation/pages/line_marker_collect_page.dart';
import '../../../mark_line/presentation/pages/line_marker_data_page.dart';
import '../../../mark_point/presentation/pages/point_marker_collect_page.dart';
import '../../../mark_point/presentation/pages/point_marker_data_page.dart';
import '../../../mini_app/domain/registry/mini_app_registry.dart';
import '../../../mini_app/presentation/provider/mini_app_provider.dart';
import '../../../mini_app/presentation/widgets/mini_app_grid_widget.dart';
import '../widgets/nav_bar.dart';

/// 当前活跃的小程序类型
enum ActiveMiniAppType {
  /// 无活跃小程序
  none,
  
  /// 标记点小程序
  pointMarker,
  
  /// 标记线小程序
  lineMarker,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // 默认选中采集标签
  final PageController _pageController = PageController(initialPage: 0);
  
  // 当前活跃的小程序类型
  ActiveMiniAppType _activeMiniAppType = ActiveMiniAppType.pointMarker;
  
  @override
  void initState() {
    super.initState();
    // 订阅标记点点击事件
    bus.on(MiniAppEvent.tapPointMarker, _handlePointMarkerTap);
    // 订阅标记线点击事件
    bus.on(MiniAppEvent.tapLineMarker, _handleLineMarkerTap);
  }

  @override
  void dispose() {
    // 取消事件订阅
    bus.off(MiniAppEvent.tapPointMarker, _handlePointMarkerTap);
    bus.off(MiniAppEvent.tapLineMarker, _handleLineMarkerTap);
    _pageController.dispose();
    super.dispose();
  }
  
  /// 处理标记点点击事件
  void _handlePointMarkerTap(dynamic arg) {
    // 关闭底部弹窗 (如果存在)
    Navigator.of(context).pop();
    
    setState(() {
      _activeMiniAppType = ActiveMiniAppType.pointMarker;
      _pageController.jumpToPage(1); // 切换到标记点采集页面
      _selectedIndex = 1; // 选中采集标签
    });
  }
  
  /// 处理标记线点击事件
  void _handleLineMarkerTap(dynamic arg) {
    // 关闭底部弹窗 (如果存在)
    Navigator.of(context).pop();
    
    setState(() {
      _activeMiniAppType = ActiveMiniAppType.lineMarker;
      _pageController.jumpToPage(1); // 切换到标记线采集页面
      _selectedIndex = 1; // 选中采集标签
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 页面内容
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // 禁用滑动切换
            onPageChanged: (index) {
              setState(() {
                // 页面变化时更新状态
              });
            },
            children: [
              // 主页内容 (对应数据页)
              _buildDataPage(),
              
              // 采集页面
              _buildCollectPage(),
            ],
          ),

          // 底部按钮栏
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: NavBar(
              selectedIndex: _selectedIndex,
              onTap: (index) {
                _handleNavSelected(index);
              },
              buttons: [
                CustomButtonData(
                  icon: Icons.data_usage,
                  label: '数据',
                  color: Theme.of(context).colorScheme.primary
                ),
                CustomButtonData(
                  icon: Icons.location_on,
                  label: '采集',
                  color: Theme.of(context).colorScheme.primary
                ),
                CustomButtonData(
                  icon: Icons.grid_view,
                  label: '更多',
                  color: Theme.of(context).colorScheme.primary
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建数据页面
  Widget _buildDataPage() {
    // 根据当前活跃的小程序类型显示对应的数据页面
    switch (_activeMiniAppType) {
      case ActiveMiniAppType.pointMarker:
        return const PointMarkerDataPage();
      case ActiveMiniAppType.lineMarker:
        return const LineMarkerDataPage();
      case ActiveMiniAppType.none:
      default:
        // 默认数据页面
        return Center(
          child: Text(
            '数据页面',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );
    }
  }
  
  /// 构建采集页面
  Widget _buildCollectPage() {
    // 根据当前活跃的小程序类型显示对应的采集页面
    switch (_activeMiniAppType) {
      case ActiveMiniAppType.pointMarker:
        return const PointMarkerCollectPage();
      case ActiveMiniAppType.lineMarker:
        return const LineMarkerCollectPage();
      case ActiveMiniAppType.none:
      default:
        // 默认采集页面，如LocationPage
        return const LocationPage();
    }
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

  void _handleNavSelected(int index) {
    switch (index) {
      case 0: // 数据标签
        setState(() {
          _selectedIndex = index;
          _pageController.jumpToPage(0); // 切换到数据页面
        });
        break;
      case 1: // 采集标签
        setState(() {
          _selectedIndex = index;
          _pageController.jumpToPage(1); // 切换到采集页面
        });
        break;
      case 2: // 更多标签
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 允许弹窗高度超过默认值
          builder: (context) => _buildBottomSheet(),
        );
        break;
    }
  }

  Widget _buildBottomSheet() {
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
            child: Consumer<MiniAppProvider>(
              builder: (ctx, miniAppProvider, _) {
                return Column(
                  children: [
                    // 排序按钮
                    if (miniAppProvider.isDraggingMode)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.done),
                              label: const Text('完成排序'),
                              onPressed: () {
                                miniAppProvider.setDraggingMode(false);
                              },
                            ),
                          ],
                        ),
                      ),

                    // 应用网格
                    Expanded(
                      child: MiniAppGridWidget(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
