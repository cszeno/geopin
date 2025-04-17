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
  // 权限状态
  bool _permissionRequested = false;
  // 是否发生错误
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAppInitialization();
  }

  /// 初始化启动流程
  Future<void> _startAppInitialization() async {
    try {
      // 初始化应用所需的资源和服务
      await _initializeAppServices();
      
      // 请求权限
      await _handlePermissions();
      
      // 如果在权限请求期间没有错误，继续导航
      if (mounted && _errorMessage == null) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '启动时发生错误: $e';
          _loadingProgress = 1.0; // 完成加载指示器
        });
      }
    }
  }
  
  /// 初始化应用服务
  Future<void> _initializeAppServices() async {
    // 这里可以添加实际的初始化逻辑，如预加载数据、初始化服务等
    
    // 模拟初始化过程的进度
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        setState(() {
          _loadingProgress = i / 10;
        });
      }
    }
  }

  /// 处理权限请求
  Future<void> _handlePermissions() async {
    if (_permissionRequested) return;
    
    setState(() => _permissionRequested = true);
    
    try {
      final perm = PermissionUtil();
      bool hasPermission = await perm.checkLocationPermission();

      if (!hasPermission) {
        hasPermission = await perm.requestLocationPermission();
        if (!hasPermission && mounted) {
          setState(() {
            _errorMessage = '需要位置权限才能使用此应用';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '请求权限时出错: $e';
        });
      }
    }
  }

  /// 初始化动画
  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
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
              _buildLogo(colorScheme),
              
              const SizedBox(height: 24),
              
              _buildAppInfo(theme, colorScheme),
              
              const SizedBox(height: 32),
              
              _buildLoadingIndicator(theme, colorScheme),
              
              // 显示错误信息（如果有）
              if (_errorMessage != null) ...[
                const SizedBox(height: 24),
                _buildErrorMessage(theme),
              ]
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建应用Logo
  Widget _buildLogo(ColorScheme colorScheme) {
    return Container(
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
    );
  }
  
  /// 构建应用信息
  Widget _buildAppInfo(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          'GeoPin',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '高精度位置监测',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
  
  /// 构建加载指示器
  Widget _buildLoadingIndicator(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
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
    );
  }
  
  /// 构建错误消息
  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 