import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/primission_util.dart';

/// 应用启动页
/// 
/// 在应用启动时显示，展示品牌信息并执行初始化操作
class SplashPage extends StatefulWidget {
  /// 构造函数
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // 动画控制器
  late AnimationController _animationController;
  // 缩放动画
  late Animation<double> _scaleAnimation;
  // 透明度动画
  late Animation<double> _opacityAnimation;
  // 加载进度
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _simulateLoading();
  }

  Future<void> _handlePermissions() async {
    final perm = PermissionUtil();
    bool hasPermission = await perm.checkLocationPermission();

    if (!hasPermission) {
      hasPermission = await perm.requestLocationPermission();
    }
  }

  /// 初始化动画
  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  /// 模拟加载过程
  Future<void> _simulateLoading() async {
    // 模拟加载进度
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _loadingProgress = i / 10;
        });
      }
    }

    // 加载完成后导航到主页
    if (mounted) {
      // 延迟一点以便用户看到100%
      await Future.delayed(const Duration(milliseconds: 300));
      await _handlePermissions();
      context.go('/');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 应用名称
              Text(
                'GeoPin',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 应用描述
              Text(
                '高精度位置监测',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                ),
              ),
              
              // const SizedBox(height: 48),
              
              // 加载进度条
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _loadingProgress,
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_loadingProgress * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 