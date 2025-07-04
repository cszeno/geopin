import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geopin/core/utils/app_logger.dart';
import 'package:geopin/features/mark_point/data/repositories/image_repository_impl.dart';

/// 全屏图片查看组件
class FullScreenImageViewWidget extends StatefulWidget {
  /// 图片路径列表
  final List<String> images;
  
  /// 初始显示的图片索引
  final int initialIndex;
  
  /// 构造函数
  const FullScreenImageViewWidget({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewWidget> createState() => _FullScreenImageViewWidgetState();
}

class _FullScreenImageViewWidgetState extends State<FullScreenImageViewWidget> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isFullScreen = true;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // 设置全屏模式
    _setFullScreen(true);
  }
  
  @override
  void dispose() {
    // 恢复正常显示模式
    _setFullScreen(false);
    _pageController.dispose();
    super.dispose();
  }
  
  /// 设置全屏模式
  void _setFullScreen(bool fullScreen) {
    if (fullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
  
  /// 切换控制UI的显示
  void _toggleUI() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    _setFullScreen(_isFullScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            // 图片查看器
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return FutureBuilder<String>(
                  future: ImageRepositoryImpl.getAbsoluteImagePath(widget.images[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (snapshot.hasError) {
                      AppLogger.error('加载图片失败: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              '无法加载图片',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              '路径: ${widget.images[index]}',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasData) {
                      return InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: Center(
                          child: Image.file(
                            File(snapshot.data!),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              AppLogger.error('渲染图片失败: $error');
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.broken_image, color: Colors.white, size: 48),
                                    const SizedBox(height: 16),
                                    const Text(
                                      '图片格式错误或已损坏',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text('未找到图片', style: TextStyle(color: Colors.white)),
                      );
                    }
                  },
                );
              },
            ),
            
            // 顶部控制栏
            if (!_isFullScreen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 8,
                    left: 8,
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // 返回按钮
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      
                      const Spacer(),
                      
                      // 分享按钮
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: 实现分享功能
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
            // 底部控制栏
            if (!_isFullScreen && widget.images.length > 1)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // 图片索引指示器
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.images.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      
                      // 图片计数器
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${_currentIndex + 1}/${widget.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 