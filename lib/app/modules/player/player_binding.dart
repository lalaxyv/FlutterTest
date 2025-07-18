// lib/app/modules/player/player_binding.dart
// 这是播放器模块的绑定 (Binding)。
// 它负责在导航到播放器页面时，创建并注入 PlayerController。

import 'package:get/get.dart'; // 导入 GetX 包

import './player_controller.dart'; // 导入当前模块的控制器

// PlayerBinding 类继承自 Bindings
class PlayerBinding extends Bindings {
  // dependencies 方法用于声明和注册当前路由所需的依赖项
  @override
  void dependencies() {
    // 使用 Get.lazyPut 来懒加载 PlayerController。
    // 这意味着 PlayerController 只会在第一次被使用时才会被实例化。
    Get.lazyPut<PlayerController>(
      () => PlayerController(),
    );
  }
}
