// lib/app/modules/login/login_controller.dart
// 这是登录模块的控制器 (Controller)。
// 控制器负责处理页面的业务逻辑、状态管理以及与数据层（例如 API 服务）的交互。

import 'package:flutter/material.dart'; // 导入 Material 包，用于 TextEditingController
import 'package:get/get.dart'; // 导入 GetX 包
import '../../data/providers/api_provider.dart'; // 导入 API 服务提供者
import '../../data/models/user_model.dart'; // 导入用户模型
import '../../routes/app_routes.dart'; // 导入路由名称常量

// LoginController 类继承自 GetxController
class LoginController extends GetxController {
  // 获取已注册的 ApiProvider 实例
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // 创建 TextEditingController 用于获取用户名和密码输入框的文本
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 使用 .obs 创建响应式变量来管理加载状态
  // 当正在进行登录操作时，isLoading.value 为 true，可以用于在 UI 上显示加载指示器
  var isLoading = false.obs;

  // 使用 .obs 创建响应式变量来管理密码是否可见的状态
  var isPasswordHidden = true.obs;

  // onInit 方法是 GetxController 生命周期的一部分，在控制器初始化时调用。
  @override
  void onInit() {
    super.onInit(); // 调用父类的 onInit 方法
    // 可以在这里添加初始化代码
    // 示例：可以预填用户名，如果之前保存过
    // usernameController.text = GetStorage().read('last_username') ?? '';
  }

  // onClose 方法在控制器被销毁前调用。
  // 在这里释放 TextEditingController 资源，防止内存泄漏。
  @override
  void onClose() {
    usernameController.dispose(); // 释放用户名控制器
    passwordController.dispose(); // 释放密码控制器
    super.onClose(); // 调用父类的 onClose 方法
  }

  // 切换密码可见性的方法
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value; // 切换状态
  }

  // 执行登录操作的方法
  Future<void> login() async {
    // 从输入框获取用户名和密码
    final String username = usernameController.text.trim(); // trim() 移除首尾空格
    final String password = passwordController.text;

    // 基本的输入验证
    if (username.isEmpty) {
      Get.snackbar(
        '输入错误',
        '请输入用户名',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return; // 验证失败，提前返回
    }
    if (password.isEmpty) {
      Get.snackbar(
        '输入错误',
        '请输入密码',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return; // 验证失败，提前返回
    }

    // 开始加载，更新 isLoading 状态
    isLoading.value = true;

    try {
      // 调用 ApiProvider 的 login 方法进行登录请求
      final UserModel? user = await _apiProvider.login(username, password);

      if (user != null && user.token != null) {
        // 登录成功
        Get.snackbar(
          '登录成功',
          '欢迎回来, ${user.username}!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // TODO: 在实际应用中，这里应该保存用户的 token 和信息
        // 例如使用 GetStorage:
        // final storage = GetStorage();
        // await storage.write('authToken', user.token);
        // await storage.write('userId', user.id);
        // await storage.write('username', user.username);
        // print('Token 和用户信息已保存到 GetStorage');

        // 导航到主页 (Routes.HOME)，并移除之前的所有路由记录 (offAllNamed)
        // 这样用户登录后按返回键不会回到登录页。
        Get.offAllNamed(Routes.HOME);
      } else {
        // login 方法内部已经通过 Get.snackbar 显示了错误信息，所以这里不需要重复显示
        // if (user == null) { // 进一步判断是 API 返回 null 还是其他错误
        //   // Get.snackbar('登录失败', '用户名或密码错误，或服务器无响应');
        // }
      }
    } catch (e) {
      // 捕获在 API 调用或处理过程中可能发生的其他异常
      print('登录控制器捕获到异常: $e'); // 打印异常信息到控制台
      Get.snackbar(
        '登录异常',
        '发生未知错误，请稍后再试。详情: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // 无论登录成功还是失败，最终都要结束加载状态
      isLoading.value = false;
    }
  }

  // (可选) 跳转到注册页面的方法
  void navigateToRegister() {
    // Get.toNamed(Routes.REGISTER); // 假设有注册页面路由
    Get.snackbar('提示', '注册功能暂未开放 (模拟)', snackPosition: SnackPosition.BOTTOM);
  }

  // (可选) 跳转到忘记密码页面的方法
  void navigateToForgotPassword() {
    // Get.toNamed(Routes.FORGOT_PASSWORD); // 假设有忘记密码页面路由
    Get.snackbar('提示', '忘记密码功能暂未开放 (模拟)', snackPosition: SnackPosition.BOTTOM);
  }
}
