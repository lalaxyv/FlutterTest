// lib/app/modules/home/home_view.dart
// 这是主页模块的视图 (View)。
// 它将作为应用的主要导航中心，使用 BottomNavigationBar 在不同的子页面间切换。
// 子页面（例如 TODO 列表和用户信息）将在这里被实例化和显示。

import 'package:flutter/material.dart'; // 导入 Flutter 的 Material UI 包
import 'package:get/get.dart'; // 导入 GetX 包

import './home_controller.dart'; // 导入主页控制器
// 导入将要作为标签页显示的视图
// 注意：这些文件此时可能还未完全实现，我们先进行引用。
import '../todo/todo_view.dart';
import '../profile/profile_view.dart';
import '../player/player_view.dart';

// HomeView 继承自 GetView<HomeController>，方便访问 HomeController
class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold 是 Material Design 布局的基本结构
    return Scaffold(
      // AppBar 通常显示在屏幕顶部
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          // 动画切换器，用于在显示和隐藏 AppBar 时添加动画效果
          child: Obx(
            () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: controller.showAppBar
                    ? AppBar(
                        // Obx 用于监听 controller.tabIndex 的变化，并根据其值更新 AppBar 的标题
                        title: Obx(() {
                          // 根据当前选中的标签页索引来设置不同的标题
                          switch (controller.tabIndex.value) {
                            case 0:
                              return const Text('TODO 列表'); // 第一个标签页的标题
                            case 1:
                              return const Text('用户信息'); // 第二个标签页的标题
                            case 2:
                              return const Text('音乐播放'); // 第三个标签页的标题
                            default:
                              return const Text('首页'); // 默认标题
                          }
                        }),
                        centerTitle: true, // 标题居中
                        // actions: [ // 可以在 AppBar 右侧添加操作按钮
                        //   IconButton(
                        //     icon: Icon(Icons.logout),
                        //     onPressed: () {
                        //       // TODO: 实现退出登录逻辑
                        //       // Get.offAllNamed(Routes.LOGIN);
                        //     },
                        //   ),
                        // ],
                      )
                    : SizedBox.shrink()),
          )),
      // body 部分根据当前选中的标签页动态显示不同的视图
      // 使用 Obx 包裹以响应 controller.tabIndex 的变化
      body: Obx(() {
        // IndexedStack 用于管理一组子 Widget，但一次只显示一个。
        // 它根据 index 属性来决定显示哪个子 Widget，并且会保持所有子 Widget 的状态。
        return IndexedStack(
          index: controller.tabIndex.value, // 当前显示的子 Widget 的索引
          children: const [
            // 第一个标签页对应的视图
            // 注意：TodoView 和 ProfileView 此时可能只是骨架文件
            TodoView(), // TODO 列表视图
            // 第二个标签页对应的视图
            ProfileView(), // 用户信息视图
            // 第三个标签页对应的视图
            PlayerView(), // 音乐播放视图
          ],
        );
      }),
      // BottomNavigationBar 是位于屏幕底部的导航栏
      // 使用 Obx 包裹以响应 controller.tabIndex 的变化，并更新选中状态
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            // items 是一个 BottomNavigationBarItem 列表，定义了导航栏的每个标签
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded), // 未选中时的图标
                label: 'TODO', // 标签文本
                activeIcon: Icon(Icons.list_alt), // 选中时的图标 (可选)
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded), // 未选中时的图标
                label: 'About', // 标签文本
                activeIcon: Icon(Icons.person_rounded), // 选中时的图标 (可选)
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle), // 未选中时的图标
                label: 'Music', // 标签文本
                activeIcon: Icon(Icons.person_rounded), // 选中时的图标 (可选)
              ),
            ],
            currentIndex: controller.tabIndex.value, // 当前选中的标签页索引
            selectedItemColor: Colors.amber[800], // 选中项的颜色
            unselectedItemColor: Colors.grey, // 未选中项的颜色
            showUnselectedLabels: true, // 是否显示未选中项的标签文本
            onTap: controller.changeTabIndex, // 点击标签页时的回调，调用控制器的方法更新索引
            type: BottomNavigationBarType.fixed, // 导航栏类型，fixed 表示所有标签都可见且宽度固定
          )),
    );
  }
}
