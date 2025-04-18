/// 事件总线模块
/// 
/// 提供全局事件发布与订阅机制，用于组件间解耦通信

/// 订阅者回调函数签名
typedef EventCallback = void Function(dynamic arg);

/// 事件总线
/// 
/// 实现了发布/订阅模式，允许应用中不同部分通过事件进行通信，
/// 而不需要直接相互依赖
class EventBus {
  /// 私有构造函数，确保单例模式
  EventBus._internal();

  /// 保存单例实例
  static final EventBus _singleton = EventBus._internal();

  /// 工厂构造函数，返回单例实例
  factory EventBus() => _singleton;

  /// 事件订阅者映射表
  /// 
  /// key: 事件名称或标识符
  /// value: 对应事件的订阅者回调函数列表
  final Map<Object, List<EventCallback>?> _emap = {};

  /// 添加订阅者
  /// 
  /// [eventName] 事件名称，可以是任何对象
  /// [callback] 事件触发时执行的回调函数
  void on(Object eventName, EventCallback callback) {
    _emap[eventName] ??= <EventCallback>[];
    _emap[eventName]!.add(callback);
  }

  /// 移除订阅者
  /// 
  /// [eventName] 事件名称
  /// [callback] 可选，要移除的特定回调函数
  ///            如果为null，则移除该事件的所有订阅者
  void off(Object eventName, [EventCallback? callback]) {
    final list = _emap[eventName];
    if (eventName == null || list == null) return;
    
    if (callback == null) {
      _emap[eventName] = null;
    } else {
      list.remove(callback);
    }
  }

  /// 触发事件
  /// 
  /// [eventName] 要触发的事件名称
  /// [arg] 可选，传递给订阅者的参数
  void emit(Object eventName, [dynamic arg]) {
    final list = _emap[eventName];
    if (list == null) return;
    
    // 反向遍历，防止订阅者在回调中移除自身带来的下标错位
    for (var i = list.length - 1; i >= 0; --i) {
      list[i](arg);
    }
  }
}

/// 全局事件总线实例
/// 
/// 应用程序中可以直接导入并使用此实例
final bus = EventBus(); 