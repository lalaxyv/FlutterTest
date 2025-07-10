// lib/app/modules/profile/profile_controller.dart
// 这是用户信息模块的控制器 (Controller)。
// 它将负责管理用户数据的显示、编辑以及与后端服务的交互。

import 'package:flutter/material.dart'; // 导入 Flutter Material 包，主要用于 TextEditingController
import 'package:get/get.dart'; // 导入 GetX 包
import '../../data/models/user_model.dart'; // 导入用户模型
import '../../data/providers/api_provider.dart'; // 导入 API Provider
import '../../routes/app_routes.dart'; // 导入路由常量

// ProfileController 类继承自 GetxController
class ProfileController extends GetxController {
  // 获取已注册的 ApiProvider 实例
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // 使用 .obs 创建响应式变量来存储当前用户的信息。
  // Rx<UserModel?> 表示一个可观察的 UserModel 对象，它可能为 null。
  var currentUser = Rx<UserModel?>(null);

  // 加载状态，用于在获取或更新数据时显示加载指示器
  var isLoading = false.obs;
  // 编辑状态的标志，用于控制是否显示编辑表单
  var isEditing = false.obs;

  // 用于编辑表单的 TextEditingControllers
  // 使用 late 初始化，因为它们的值依赖于 currentUser，在 onInit 中 currentUser 获取到后再初始化
  late TextEditingController nameEditingController;
  late TextEditingController emailEditingController;
  late TextEditingController bioEditingController;

  // 存储用户ID，用于API调用。在实际应用中，这应该在登录后安全地存储和检索。
  // 为了模拟，我们暂时硬编码一个。
  String _currentUserId = 'user-123'; // 假设这是当前登录用户的ID

  // onInit 是 GetxController 的生命周期方法，在控制器初始化时调用。
  @override
  void onInit() {
    super.onInit(); // 调用父类的 onInit 方法
    // 初始化 TextEditingControllers，这里先用空字符串，fetchUserProfile 后会更新
    nameEditingController = TextEditingController();
    emailEditingController = TextEditingController();
    bioEditingController = TextEditingController();

    // TODO: 在实际应用中，应该从 GetStorage 或 AuthService 获取当前登录用户的 ID/Token
    // String? storedUserId = GetStorage().read('userId');
    // if (storedUserId != null) {
    //   _currentUserId = storedUserId;
    //   fetchUserProfile(); // 获取用户数据
    // } else {
    //   // 如果没有用户ID，可能需要处理未登录状态，或跳转到登录页
    //   // Get.offAllNamed(Routes.LOGIN);
    //   print("ProfileController: 未找到用户ID，无法加载用户信息。");
    //   // 为了演示，即使没有真实ID，也尝试加载一个默认用户
       fetchUserProfile();
    // }
  }

  // onClose 是 GetxController 的生命周期方法，在控制器销毁前调用。
  @override
  void onClose() {
    // 释放 TextEditingController 资源，防止内存泄漏
    nameEditingController.dispose();
    emailEditingController.dispose();
    bioEditingController.dispose();
    super.onClose(); // 调用父类的 onClose 方法
  }

  // 获取用户配置信息的方法
  Future<void> fetchUserProfile() async {
    isLoading.value = true; // 开始加载
    try {
      // 使用 _currentUserId (或 token) 调用 API
      final UserModel? user = await _apiProvider.getUserProfile(_currentUserId);
      if (user != null) {
        currentUser.value = user; // 更新响应式变量
        // 使用获取到的用户信息更新 TextEditingControllers
        nameEditingController.text = user.username;
        emailEditingController.text = user.email;
        bioEditingController.text = user.bio ?? ''; // 如果 bio 为 null，则使用空字符串
      } else {
        Get.snackbar('获取失败', '未能获取用户信息 (模拟返回null)',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
      }
    } catch (e) {
      print('获取用户信息失败: $e'); // 打印错误日志
      Get.snackbar('错误', '获取用户信息失败: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false; // 结束加载
    }
  }

  // 切换编辑状态的方法
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (isEditing.value && currentUser.value != null) {
      // 进入编辑模式时，确保编辑框内容与当前数据显示一致
      nameEditingController.text = currentUser.value!.username;
      emailEditingController.text = currentUser.value!.email;
      bioEditingController.text = currentUser.value!.bio ?? '';
    }
  }

  // 保存用户信息的修改
  Future<void> saveUserProfile() async {
    if (!isEditing.value || currentUser.value == null) return; // 如果不在编辑模式或没有当前用户，则不执行

    // 创建一个包含更新后信息的 UserModel 实例
    // 注意：保持 ID 不变，只更新允许修改的字段
    UserModel updatedUser = currentUser.value!.copyWith(
      username: nameEditingController.text.trim(),
      email: emailEditingController.text.trim(),
      bio: bioEditingController.text.trim(),
    );

    isLoading.value = true; // 开始加载
    try {
      final UserModel? resultUser = await _apiProvider.updateUserProfile(updatedUser);
      if (resultUser != null) {
        currentUser.value = resultUser; // 更新本地的响应式用户数据
        // 再次确保编辑控制器与新数据同步 (尽管通常在退出编辑模式时会做)
        nameEditingController.text = resultUser.username;
        emailEditingController.text = resultUser.email;
        bioEditingController.text = resultUser.bio ?? '';
        isEditing.value = false; // 保存成功后退出编辑模式
        Get.snackbar('成功', '用户信息已更新',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      } else {
         Get.snackbar('保存失败', '更新用户信息失败 (API 返回 null)',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('更新用户信息失败: $e'); // 打印错误日志
      Get.snackbar('错误', '更新用户信息失败: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false; // 结束加载
    }
  }

  // 取消编辑并恢复原始数据
  void cancelEdit() {
    if (isEditing.value && currentUser.value != null) {
      // 恢复编辑框内容为保存前的数据
      nameEditingController.text = currentUser.value!.username;
      emailEditingController.text = currentUser.value!.email;
      bioEditingController.text = currentUser.value!.bio ?? '';
      isEditing.value = false; // 退出编辑模式
    }
  }

  // 模拟退出登录
  void logout() {
    Get.defaultDialog(
        title: "退出登录",
        middleText: "您确定要退出当前账号吗？",
        textConfirm: "确定退出",
        textCancel: "取消",
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent, // 确认按钮颜色
        onConfirm: () {
          // TODO: 实现真正的退出登录逻辑:
          // 1. 调用 API 使 token 失效 (如果后端支持)
          // 2. 清除本地存储的用户凭证 (例如 GetStorage 中的 token, userId)
          //    final storage = GetStorage();
          //    storage.remove('authToken');
          //    storage.remove('userId');
          // 3. 重置应用内的用户状态 (例如 currentUser.value = null)
          currentUser.value = null;
          // 4. 导航到登录页并清除所有历史路由
          Get.offAllNamed(Routes.LOGIN); // 使用在 app_routes.dart 中定义的路由名称
          Get.snackbar("操作提示", "已退出登录 (模拟)",
              snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
        });
  }
}
