// lib/app/routes/app_routes.dart
// 该文件用于定义应用中所有页面的路由名称常量。
// 这样做的好处是避免在代码中硬编码路由字符串，减少出错的可能性，并方便管理。

// 定义一个抽象类 _Paths，用于集中管理路由路径。
// 使用 abstract class 和私有构造函数可以防止这个类被实例化。
// 将所有路由路径作为静态常量字符串存放在这里。
abstract class Routes {
  Routes._(); // 私有构造函数，防止外部实例化

  static const LOGIN = _Paths.LOGIN; // 登录页路由
  static const HOME = _Paths.HOME; // 主页路由 (可能包含 TODO 和 Profile)
  static const TODO = _Paths.TODO; // TODO 列表页路由 (如果作为独立页面)
  static const PROFILE = _Paths.PROFILE; // 用户信息页路由 (如果作为独立页面)
  // 如果 TODO 和 Profile 是 HOME 的一部分（例如通过 BottomNavigationBar 切换），
  // 那么它们可能不需要顶级的独立路由，而是作为 HOME 的子路由或部分。
  // 为了示例清晰，我们先定义它们为可能的独立路由。
}

abstract class _Paths {
  _Paths._(); // 私有构造函数

  static const LOGIN = '/login'; // 登录页的具体路径
  static const HOME = '/home'; // 主页的具体路径
  static const TODO = '/todo'; // TODO 列表页的具体路径
  static const PROFILE = '/profile'; // 用户信息页的具体路径
}
