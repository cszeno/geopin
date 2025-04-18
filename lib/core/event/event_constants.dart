/// 事件常量
/// 
/// 集中定义应用中使用的各种事件名称，
/// 避免硬编码，便于统一管理和重构

/// 小程序相关事件
enum MiniAppEvent {
  /// 点击标记点小程序事件
  tapPointMarker,
  
  /// 点击标记线小程序事件
  tapLineMarker,
  
  /// 点击任意小程序事件
  tapAnyMiniApp,
} 