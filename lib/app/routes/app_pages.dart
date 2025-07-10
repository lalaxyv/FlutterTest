// lib/app/routes/app_pages.dart
// 该文件用于定义应用的路由表。
// 它将路由名称与相应的视图（View）和绑定（Binding）关联起来。
// GetX 使用这个配置来进行页面导航和依赖注入。

import 'package:get/get.dart'; // 导入 GetX 包

// 导入我们刚刚定义的路由名称常量
import './app_routes.dart';

// 导入未来会创建的视图和绑定文件
// 注意：这些文件此时可能还不存在，我们稍后会创建它们。
// 为了让代码结构完整，我们先在这里声明导入。
import '../modules/login/login_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/home/home_binding.dart';
// import '../modules/todo/todo_view.dart'; // 如果 TODO 是独立页面
// import '../modules/todo/todo_binding.dart'; // 如果 TODO 是独立页面
// import '../modules/profile/profile_view.dart'; // 如果 Profile 是独立页面
// import '../modules/profile/profile_binding.dart'; // 如果 Profile 是独立页面

// AppPages 类包含了应用的路由配置
class AppPages {
  AppPages._(); // 私有构造函数，防止外部实例化

  // 定义初始路由，应用启动时首先显示的页面
  // 通常是登录页或者一个启动页（Splash Screen）
  static const INITIAL = Routes.LOGIN;

  // 定义一个静态 final 列表，包含所有的 GetPage 对象
  // 每个 GetPage 对象代表一个路由配置
  static final routes = [
    GetPage(
      name: Routes.LOGIN, // 路由名称，来自 app_routes.dart 中的 _Paths
      page: () => LoginView(), // 该路由对应的视图组件
      binding: LoginBinding(), // 该路由对应的绑定类，用于依赖注入控制器
    ),
    GetPage(
      name: Routes.HOME, // 主页路由
      page: () => HomeView(), // 主页视图
      binding: HomeBinding(), // 主页绑定
      // 如果 TODO 和 Profile 是 Home 的子页面/标签页，
      // 它们的路由和绑定可能在这里通过 HomeView 的子路由或 GetX 的嵌套路由来管理。
      // 暂时我们先假设 Home 是一个容器页面。
    ),
    // 示例：如果 TODO 是一个独立的顶级页面
    // GetPage(
    //   name: _Paths.TODO,
    //   page: () => TodoView(),
    //   binding: TodoBinding(),
    // ),
    // 示例：如果 Profile 是一个独立的顶级页面
    // GetPage(
    //   name: _Paths.PROFILE,
    //   page: () => ProfileView(),
    //   binding: ProfileBinding(),
    // ),
  ];
}
