/// 用例抽象基类
/// 
/// 所有用例(Use Cases)的基础接口，定义了Clean Architecture中用例层的标准行为。
/// 
/// [Type] 是用例执行后返回的结果类型
/// [Params] 是用例执行时需要的参数类型
abstract class UseCase<Type, Params> {
  /// 执行用例的方法
  /// 
  /// 每个用例必须实现此方法以实现其特定的业务逻辑
  /// [params] 用例执行所需的参数
  /// 返回执行结果，类型为Type
  Future<Type> call(Params params);
}

/// 无参数用例抽象类
/// 
/// 用于不需要参数的用例
/// 
/// [Type] 是用例执行后返回的结果类型
abstract class NoParamsUseCase<Type> {
  /// 执行用例的方法
  /// 
  /// 无需参数，直接执行用例逻辑
  /// 返回执行结果，类型为Type
  Future<Type> call();
} 