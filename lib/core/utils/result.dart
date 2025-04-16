import '../error/failures.dart';

/// 结果类，用于包装成功或失败的返回结果
class Result<T> {
  /// 成功时的数据
  final T? data;
  
  /// 失败时的错误
  final Failure? error;
  
  /// 是否成功
  bool get isSuccess => error == null;
  
  /// 是否失败
  bool get isFailure => error != null;
  
  /// 私有构造函数
  const Result._({this.data, this.error});
  
  /// 创建成功结果
  factory Result.success(T data) => Result._(data: data);
  
  /// 创建失败结果
  factory Result.failure(Failure error) => Result._(error: error);
} 