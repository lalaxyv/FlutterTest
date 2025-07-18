// lib/app/modules/home/home_controller.dart
// 这是主页模块的控制器 (Controller)。
// 主页通常作为应用的容器页面，可能包含底部导航栏来切换不同的子页面（如 TODO、Profile）。
// 此控制器将管理底部导航栏的当前选中索引以及其他主页相关的状态和逻辑。

import 'package:get/get.dart'; // 导入 GetX 包

// HomeController 类继承自 GetxController
class HomeController extends GetxController {
  // 使用 .obs 创建一个响应式变量来存储底部导航栏的当前选中项索引。
  // 初始值为 0，表示默认选中第一个标签页。
  final RxInt tabIndex = 0.obs;
  final hideAppBarIndexes = {2};

  bool get showAppBar => !hideAppBarIndexes.contains(tabIndex.value);

  // 当底部导航栏的标签页被点击时，调用此方法来更新选中的索引。
  // newIndex 参数是新选中的标签页的索引。
  void changeTabIndex(int newIndex) {
    tabIndex.value = newIndex; // 更新响应式变量的值，UI 将自动响应变化
    print('tabIndex=$newIndex  showAppBar1=$showAppBar');
  }

  // onInit 是 GetxController 的生命周期方法，在控制器初始化时调用。
  @override
  void onInit() {
    super.onInit(); // 调用父类的 onInit 方法
    // 可以在此进行初始化操作，例如加载用户数据或配置信息
  }

  // onReady 是 GetxController 的生命周期方法，在 Widget 渲染完成后调用。
  @override
  void onReady() {
    super.onReady(); // 调用父类的 onReady 方法
  }

  // onClose 是 GetxController 的生命周期方法，在控制器销毁前调用。
  @override
  void onClose() {
    super.onClose(); // 调用父类的 onClose 方法
    // 可以在此释放资源
  }
}
