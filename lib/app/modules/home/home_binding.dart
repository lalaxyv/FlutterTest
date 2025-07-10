// lib/app/modules/home/home_binding.dart
// 这是主页模块的绑定 (Binding)。
// 它负责为主页路由注入 HomeController 以及可能的子页面控制器。

import 'package:get/get.dart'; // 导入 GetX 包

import './home_controller.dart'; // 导入主页控制器
// 导入未来会创建的 TODO 和 Profile 控制器，因为它们将作为 Home 页的一部分
import '../todo/todo_controller.dart';
import '../profile/profile_controller.dart';

// HomeBinding 类继承自 Bindings
class HomeBinding extends Bindings {
  // dependencies 方法用于声明和注册当前路由及其子模块所需的依赖项
  @override
  void dependencies() {
    // 懒加载主页控制器
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // 懒加载 TODO 列表控制器，它将在 Home 页面的 TODO 标签页中使用
    Get.lazyPut<TodoController>(
      () => TodoController(),
    );
    // 懒加载用户信息控制器，它将在 Home 页面的 Profile 标签页中使用
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
    // 注意：如果 Todo 和 Profile 模块有它们自己的 Binding 文件，
    // 并且你希望通过独立路由访问它们，那么这里的 lazyPut 可能需要调整，
    // 或者在 AppPages.dart 中为它们各自的路由配置相应的 Binding。
    // 当前设计是将它们作为 Home 的一部分，由 HomeBinding 统一管理其控制器的初始注入。
  }
}
