// lib/app/modules/login/login_view.dart
// 这是登录模块的视图 (View)。
// 视图负责展示 UI 界面，并将用户的交互事件传递给控制器 (Controller)。
// 在 GetX 中，视图通常是一个 StatelessWidget 或 StatefulWidget。
// 使用 GetView<T> 或 GetWidget<T> 可以方便地访问已注册的控制器 T。

import 'package:flutter/material.dart'; // 导入 Flutter 的 Material UI 包
import 'package:get/get.dart'; // 导入 GetX 包

import './login_controller.dart'; // 导入当前模块的控制器

// LoginView 类继承自 GetView<LoginController>。
// GetView 会自动查找并提供一个 LoginController 的实例，可以通过 `controller` 属性访问。
// GetView 是一个 StatelessWidget，适用于不需要自身状态管理的视图。
class LoginView extends GetView<LoginController> {
  // 构造函数，可以接收一个可选的 key
  const LoginView({Key? key}) : super(key: key);

  // build 方法描述了如何构建这个 Widget 的 UI
  @override
  Widget build(BuildContext context) {
    // Scaffold 是 Material Design 布局结构的基本实现。
    // 它提供了例如 AppBar, Drawer, SnackBar, BottomNavigationBar 等常用 UI 元素的容器。
    return Scaffold(
      // AppBar 通常位于屏幕顶部，显示标题和操作按钮等。
      appBar: AppBar(
        title: const Text('用户登录'), // AppBar 的标题
        centerTitle: true, // 标题居中显示
        elevation: 0.5, // AppBar 底部阴影
      ),
      // body 是 Scaffold 的主要内容区域。
      // 使用 SingleChildScrollView 包裹，以防止内容过多时键盘弹出导致溢出。
      body: SingleChildScrollView(
        // 使用 Center Widget 使其子组件在屏幕上居中显示（如果空间足够）。
        // 对于表单，通常更希望内容从顶部开始，所以这里可以不用 Center，
        // 而是通过 Padding 和 Column 的 mainAxisAlignment 来控制。
        child: Padding(
          padding: const EdgeInsets.all(24.0), // 在子组件周围添加内边距
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 主轴居中对齐（垂直方向）
            crossAxisAlignment: CrossAxisAlignment.stretch, // 交叉轴拉伸填充（水平方向）
            children: <Widget>[
              // 应用 Logo 或欢迎语 (可选)
              Icon(
                Icons.flutter_dash_rounded, // Flutter Dash 图标
                size: 80, // 图标大小
                color: Theme.of(context).primaryColor, // 使用主题色
              ),
              const SizedBox(height: 16), // 垂直间隔
              Text(
                '欢迎使用 TODO 应用', // 欢迎文本
                textAlign: TextAlign.center, // 文本居中
                style: TextStyle(
                  fontSize: 22, // 字体大小
                  fontWeight: FontWeight.bold, // 字体加粗
                  color: Theme.of(context).primaryColorDark, // 颜色
                ),
              ),
              const SizedBox(height: 40), // 主要内容前的较大垂直间隔

              // 用户名输入框
              TextFormField(
                controller: controller.usernameController, // 关联用户名控制器
                decoration: InputDecoration(
                  labelText: '用户名', // 输入框标签
                  hintText: '请输入您的用户名', // 提示文本
                  prefixIcon: const Icon(Icons.person_outline_rounded), // 前置图标
                  border: OutlineInputBorder( // 边框样式
                    borderRadius: BorderRadius.circular(8.0), // 圆角边框
                  ),
                ),
                keyboardType: TextInputType.text, // 键盘类型为普通文本
                textInputAction: TextInputAction.next, // 软键盘 "下一步" 按钮
              ),
              const SizedBox(height: 16), // 垂直间隔

              // 密码输入框
              // Obx 用于监听 controller.isPasswordHidden 的变化，并据此更新 UI
              Obx(() => TextFormField(
                    controller: controller.passwordController, // 关联密码控制器
                    decoration: InputDecoration(
                      labelText: '密码', // 输入框标签
                      hintText: '请输入您的密码', // 提示文本
                      prefixIcon: const Icon(Icons.lock_outline_rounded), // 前置图标
                      border: OutlineInputBorder( // 边框样式
                        borderRadius: BorderRadius.circular(8.0), // 圆角边框
                      ),
                      // 后置图标，用于切换密码可见性
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden.value
                              ? Icons.visibility_off_rounded // 如果密码隐藏，显示 "不可见" 图标
                              : Icons.visibility_rounded, // 如果密码可见，显示 "可见" 图标
                        ),
                        onPressed: controller.togglePasswordVisibility, // 点击时调用控制器方法切换可见性
                      ),
                    ),
                    obscureText: controller.isPasswordHidden.value, // 根据状态隐藏或显示密码文本
                    keyboardType: TextInputType.visiblePassword, // 键盘类型
                    textInputAction: TextInputAction.done, // 软键盘 "完成" 按钮
                    onFieldSubmitted: (_) => controller.login(), // 在软键盘上按 "完成" 时尝试登录
                  )),
              const SizedBox(height: 8), // 垂直间隔

              // 忘记密码链接 (可选)
              Align(
                alignment: Alignment.centerRight, // 右对齐
                child: TextButton(
                  onPressed: controller.navigateToForgotPassword, // 点击事件
                  child: const Text('忘记密码?'), // 文本
                ),
              ),
              const SizedBox(height: 24), // 垂直间隔

              // 登录按钮
              // Obx 用于监听 controller.isLoading 的变化
              Obx(() => ElevatedButton(
                    // 如果正在加载 (controller.isLoading.value 为 true)，则禁用按钮 (onPressed 为 null)
                    onPressed: controller.isLoading.value ? null : controller.login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0), // 按钮内边距
                      shape: RoundedRectangleBorder( // 按钮形状
                        borderRadius: BorderRadius.circular(8.0), // 圆角
                      ),
                    ),
                    // 根据加载状态显示不同的按钮内容
                    child: controller.isLoading.value
                        ? const SizedBox( // 如果正在加载，显示一个加载指示器
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0, // 指示器线条宽度
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // 指示器颜色
                            ),
                          )
                        : const Text( // 如果未加载，显示 "登录" 文本
                            '登 录',
                            style: TextStyle(fontSize: 16), // 文本样式
                          ),
                  )),
              const SizedBox(height: 16), // 垂直间隔

              // 注册链接 (可选)
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 居中对齐
                children: [
                  const Text('还没有账户?'), // 提示文本
                  TextButton(
                    onPressed: controller.navigateToRegister, // 点击事件
                    child: const Text('立即注册'), // 按钮文本
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
