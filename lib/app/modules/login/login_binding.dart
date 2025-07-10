// lib/app/modules/login/login_binding.dart
// 这是登录模块的绑定 (Binding)。
// Binding 类用于将控制器 (Controller) 与视图 (View) 解耦，并负责依赖注入。
// 当导航到某个路由时，GetX 会查找并执行对应的 Binding 类中的 dependencies 方法，
// 从而创建并初始化该路由所需的控制器实例。

import 'package:get/get.dart'; // 导入 GetX 包

import './login_controller.dart'; // 导入当前模块的控制器

// LoginBinding 类继承自 Bindings
// Bindings 是一个抽象类，需要实现其 dependencies 方法
class LoginBinding extends Bindings {
  // dependencies 方法用于声明和注册当前路由所需的依赖项（通常是控制器）
  @override
  void dependencies() {
    // 使用 Get.lazyPut 来懒加载 LoginController。
    // 这意味着 LoginController 只会在第一次被使用时才会被实例化。
    // 这种方式有助于优化应用的启动性能和内存使用。
    Get.lazyPut<LoginController>(
      () => LoginController(), // 返回一个新的 LoginController 实例
    );
    // 如果有其他依赖项，例如某个服务，也可以在这里注册：
    // Get.lazyPut<MyApiService>(() => MyApiService());
  }
}
