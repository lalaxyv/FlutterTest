// lib/main.dart
// 这是 Flutter 应用的入口文件。
// 它负责初始化应用，特别是设置 GetMaterialApp 以启用 GetX 的路由和状态管理功能。

import 'package:flutter/material.dart'; // 导入 Flutter 的 Material UI 包
import 'package:get/get.dart'; // 导入 GetX 包

// 导入应用路由配置
import 'app/routes/app_pages.dart';
// 导入 API Provider
import 'app/data/providers/api_provider.dart';

// 异步的应用主函数，以便在 runApp 之前执行初始化操作
Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized() 确保 Flutter 引擎的绑定已初始化。
  // 这在 runApp 之前调用异步方法时是必需的。
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化全局服务
  await initServices();

  // runApp 是 Flutter 的一个函数，它接收一个 Widget 作为参数，并将其渲染到屏幕上
  runApp(MyApp()); // 运行 MyApp 组件
}

// 初始化服务函数
Future<void> initServices() async {
  print("开始初始化服务..."); // 打印日志，方便调试
  // 使用 Get.putAsync 异步注册 ApiProvider。
  // 这允许 ApiProvider 在其 onInit 方法中执行异步操作（如果需要）。
  // 使用 permanent: true 确保服务在整个应用生命周期内都可用，不会被自动移除。
  await Get.putAsync<ApiProvider>(() async => ApiProvider(), permanent: true);
  print("ApiProvider 已注册。"); // 打印日志
  // 如果有其他全局服务，也可以在这里注册
  // 例如: await Get.putAsync<MyStorageService>(() async => MyStorageService().init());
}

// MyApp 是一个 StatelessWidget，它是应用的根组件
class MyApp extends StatelessWidget {
  // StatelessWidget 的构造函数，可以接收一个可选的 key 参数
  const MyApp({Key? key}) : super(key: key);

  // build 方法描述了如何构建这个 Widget
  // 它返回一个 Widget 树
  @override
  Widget build(BuildContext context) {
    // 使用 GetMaterialApp 替代 MaterialApp 来启用 GetX 功能
    return GetMaterialApp(
      // 应用的标题，会显示在任务管理器等地方
      title: 'Flutter GetX TODO App',
      // 设置应用的初始路由，即应用启动时显示的第一个页面
      // AppPages.INITIAL 来自我们之前定义的路由配置
      initialRoute: AppPages.INITIAL,
      // 设置应用的所有命名路由页面
      // AppPages.routes 包含了所有页面的配置信息 (名称, 视图, 绑定)
      getPages: AppPages.routes,
      // 定义应用的主题数据
      theme: ThemeData(
        // 设置应用的主色调
        primarySwatch: Colors.blue,
        // 设置视觉密度，以适应不同平台的显示效果
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // 禁用右上角的 DEBUG 横幅
      debugShowCheckedModeBanner: false,
      // 你可以在这里配置其他 GetMaterialApp 的属性，
      // 例如：locale (国际化), fallbackLocale, translations (翻译), etc.
    );
  }
}
