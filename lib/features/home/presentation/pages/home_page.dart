import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/event/event_bus.dart';
import '../../../../shared/mini_app/domain/models/base_mini_app.dart';
import '../../../../shared/mini_app/domain/registry/mini_app_hub.dart';
import '../../../../shared/mini_app/domain/registry/mini_app_registry.dart';
import '../../../../shared/mini_app/presentation/provider/mini_app_provider.dart';
import '../../../../shared/mini_app/presentation/widgets/mini_app_grid_widget.dart';
import '../widgets/nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // 默认选中采集标签
  final PageController _pageController = PageController(initialPage: 0);

  // 当前活跃的小程序ID
  String _activeMiniAppId = 'mark_point'; // 默认使用mark_point

  @override
  void initState() {
    super.initState();
    // 订阅通用MiniApp事件，用于处理所有MiniApp的页面切换
    bus.on(MiniAppEvent.tapAnyMiniApp, _handleMiniAppEvent);
  }

  @override
  void dispose() {
    // 取消事件订阅
    bus.off(MiniAppEvent.tapAnyMiniApp, _handleMiniAppEvent);
    _pageController.dispose();
    super.dispose();
  }

  /// 通用的MiniApp事件处理函数
  void _handleMiniAppEvent(dynamic arg) {
    // 只处理BaseMiniApp类型的事件参数
    if (arg is! BaseMiniApp) return;

    final miniApp = arg;

    // 如果有弹窗，先关闭
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // 判断MiniApp是否支持采集页面
    final hasCollectPage =
        MiniAppHub.instance.getCollectPage(miniApp.id, context) != null;

    if (hasCollectPage) {
      setState(() {
        // 如果支持采集页面，切换到采集标签
        _activeMiniAppId = miniApp.id;
        _pageController.jumpToPage(1); // 切换到采集页面
        _selectedIndex = 1; // 选中采集标签
      });
    }
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
                _selectedIndex = index;
              });
            },
            children: [
              // 数据
              _buildDataPage(),

              // 采集
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

  /// 构建数据页面
  Widget _buildDataPage() {
    // 使用MiniAppHub获取当前活跃小程序的数据页面
    final dataPage = MiniAppHub.instance.getDataPage(_activeMiniAppId, context);

    // 如果找不到对应页面，显示默认页面
    if (dataPage == null) {
      return const Center(
        child: Text(
          '未找到对应的数据页面',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return dataPage;
  }

  /// 构建采集页面
  Widget _buildCollectPage() {
    // 使用MiniAppHub获取当前活跃小程序的采集页面
    final collectPage = MiniAppHub.instance.getCollectPage(
      _activeMiniAppId,
      context,
    );

    // 如果找不到对应页面，显示默认页面
    if (collectPage == null) {
      return const Center(
        child: Text(
          '该小程序不支持采集功能',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return collectPage;
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
        // 只有当前MiniApp支持采集页面时才切换到采集标签
        final hasCollectPage =
            MiniAppHub.instance.getCollectPage(_activeMiniAppId, context) !=
            null;
        if (hasCollectPage) {
          setState(() {
            _selectedIndex = index;
            _pageController.jumpToPage(1); // 切换到采集页面
          });
        } else {
          // 如果不支持采集页面，显示提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('当前功能不支持采集页面'),
              duration: Duration(seconds: 2),
            ),
          );
        }
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
                    // 应用网格
                    Expanded(child: MiniAppGridWidget()),
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
