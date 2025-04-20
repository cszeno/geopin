import 'package:flutter/material.dart';

import 'mini_app_model.dart';

/// MiniApp基础抽象类
///
/// 所有MiniApp必须继承此类并实现相应方法
abstract class AbstractMiniApp {
  /// 获取MiniApp配置信息
  MiniAppModel get config;

  /// 构建数据页面
  ///
  /// 返回此MiniApp的主数据页面
  Widget buildPage(BuildContext context);

  /// 处理MiniApp点击事件
  ///
  /// 当用户点击MiniApp图标时调用
  void handleTap(BuildContext context);

  /// 获取MiniApp唯一标识符
  String get id => config.id;

  /// 获取MiniApp名称
  String get name => config.name;

  /// 获取MiniApp路由
  String get route => config.route;
}