// lib/app/modules/profile/profile_view.dart
// 这是用户信息模块的视图 (View)。
// 它负责展示用户的个人信息，并提供编辑这些信息的功能。

import 'package:flutter/material.dart'; // 导入 Flutter 的 Material UI 包
import 'package:get/get.dart'; // 导入 GetX 包

import './profile_controller.dart'; // 导入当前模块的控制器
import '../../data/models/user_model.dart'; // 导入用户模型，用于类型检查

// ProfileView 继承自 GetView<ProfileController>，方便访问 ProfileController。
// ProfileController 是在 HomeBinding 中注册的。
class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 返回一个 Obx Widget，它会监听控制器中多个状态的变化 (isLoading, currentUser, isEditing)
    // 并根据这些状态构建不同的 UI。
    return Obx(() {
      // 优先处理加载状态
      if (controller.isLoading.value && controller.currentUser.value == null && !controller.isEditing.value) {
        // 如果正在加载且当前没有用户信息（通常是初次加载）
        return const Center(child: CircularProgressIndicator());
      }

      // 如果没有获取到用户信息 (例如 API 调用失败或用户不存在)
      if (controller.currentUser.value == null && !controller.isEditing.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sentiment_dissatisfied_rounded, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '无法加载用户信息',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('重试'),
                onPressed: controller.fetchUserProfile,
              )
            ],
          ),
        );
      }

      // 根据是否处于编辑模式，显示不同的界面内容
      // 使用 SingleChildScrollView 防止内容溢出时无法滚动
      return RefreshIndicator(
        onRefresh: controller.fetchUserProfile, // 下拉刷新用户信息
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // 确保总是可以滚动以触发刷新
          padding: const EdgeInsets.all(20.0), // 在内容周围添加内边距
          child: controller.isEditing.value
              ? _buildEditForm(context) // 如果是编辑模式，构建编辑表单
              : _buildProfileInfo(context, controller.currentUser.value!), // 如果是查看模式，构建信息展示区
          // ! 安全，因为前面已检查 currentUser.value != null
        ),
      );
    });
  }

  // 构建用户信息展示部分的 Widget
  // 参数 userModel 确保我们总是使用最新的用户信息来构建 UI
  Widget _buildProfileInfo(BuildContext context, UserModel userModel) {
    return Column(
      // 垂直布局
      crossAxisAlignment: CrossAxisAlignment.center, // 子组件整体居中
      children: <Widget>[
        // 用户头像 (示例)
        CircleAvatar(
          // 圆形头像
          radius: 60, // 半径
          backgroundColor: Colors.grey[300], // 背景色
          // backgroundImage: userModel.avatarUrl != null ? NetworkImage(userModel.avatarUrl!) : null, // 假设 UserModel 有 avatarUrl
          child: userModel.username.isNotEmpty // 使用 username 首字母作为头像占位符
              ? Text(
                  userModel.username[0].toUpperCase(),
                  style: TextStyle(fontSize: 50, color: Theme.of(context).primaryColorDark),
                )
              : Icon(Icons.person_rounded, size: 60, color: Colors.grey[700]), // 默认图标
        ),
        const SizedBox(height: 24), // 添加垂直间距

        // 用户名展示
        _buildInfoCard(context, Icons.person_pin_rounded, "用户名", userModel.username),
        // 邮箱展示
        _buildInfoCard(context, Icons.alternate_email_rounded, "邮箱", userModel.email),
        // 简介展示
        _buildInfoCard(context, Icons.text_snippet_rounded, "简介", userModel.bio ?? "暂无简介", maxLines: null), // maxLines null 允许自动换行
        const SizedBox(height: 32), // 添加垂直间距

        // 编辑按钮和加载指示器
        Obx(() => controller.isLoading.value && controller.isEditing.value // 仅在尝试保存时显示加载
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                icon: const Icon(Icons.edit_note_rounded), // 编辑图标
                label: const Text('编辑信息'), // 按钮文本
                onPressed: controller.toggleEditMode, // 点击时调用控制器方法切换到编辑模式
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12), // 按钮内边距
                    textStyle: const TextStyle(fontSize: 16)),
              )),
        const SizedBox(height: 16), // 间隔

        // 退出登录按钮
        OutlinedButton.icon(
          icon: const Icon(Icons.exit_to_app_rounded, color: Colors.redAccent),
          label: const Text('退出登录', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
          onPressed: controller.logout, // 调用退出登录方法
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
            side: const BorderSide(color: Colors.redAccent, width: 1.5), // 边框颜色和宽度
          ),
        ),
      ],
    );
  }

  // 构建用户信息编辑表单部分的 Widget
  Widget _buildEditForm(BuildContext context) {
    final formKey = GlobalKey<FormState>(); // 创建一个 GlobalKey 用于表单验证

    return Form(
      // 使用 Form Widget 来管理表单状态和验证
      key: formKey, //关联 GlobalKey
      child: Column(
        // 垂直布局
        crossAxisAlignment: CrossAxisAlignment.stretch, // 子组件水平拉伸填充
        children: <Widget>[
          Text("编辑个人信息", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          // 用户名编辑框
          TextFormField(
            controller: controller.nameEditingController, // 关联文本控制器
            decoration: const InputDecoration(labelText: '用户名', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline_rounded)),
            validator: (value) => (value == null || value.isEmpty) ? '用户名不能为空' : null,
          ),
          const SizedBox(height: 16), // 垂直间距

          // 邮箱编辑框
          TextFormField(
            controller: controller.emailEditingController, // 关联文本控制器
            decoration: const InputDecoration(labelText: '邮箱', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
            keyboardType: TextInputType.emailAddress, // 设置键盘类型为邮箱地址
            validator: (value) {
              // 邮箱格式简单验证
              if (value == null || value.isEmpty) return '邮箱不能为空';
              if (!GetUtils.isEmail(value)) return '请输入有效的邮箱地址';
              return null;
            },
          ),
          const SizedBox(height: 16), // 垂直间距

          // 简介编辑框
          TextFormField(
            controller: controller.bioEditingController, // 关联文本控制器
            decoration: const InputDecoration(labelText: '简介', border: OutlineInputBorder(), prefixIcon: Icon(Icons.note_alt_outlined)),
            maxLines: 3, // 最多显示3行
            maxLength: 150, // 最大输入字符数
          ),
          const SizedBox(height: 32), // 垂直间距

          // 操作按钮行 (保存和取消)
          // 根据 isLoading 状态显示加载指示器或按钮
          Obx(() {
            if (controller.isLoading.value && controller.isEditing.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return Row(
              // 水平布局
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 子组件均匀分布空间
              children: <Widget>[
                // 取消按钮
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('取消'),
                  onPressed: controller.cancelEdit, // 点击时调用控制器方法取消编辑
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                ),
                // 保存按钮
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_rounded),
                  label: const Text('保存'),
                  onPressed: () {
                    // 点击保存时，首先验证表单
                    if (formKey.currentState?.validate() ?? false) {
                      controller.saveUserProfile(); // 如果表单验证通过，则调用控制器方法保存信息
                    }
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // 辅助方法：构建信息展示卡片（图标 + 标签 + 值）
  Widget _buildInfoCard(BuildContext context, IconData icon, String label, String value, {int? maxLines = 1}) {
    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // 上下边距
        child: Row(
          // 水平布局
          crossAxisAlignment: maxLines == null ? CrossAxisAlignment.start : CrossAxisAlignment.center, // 顶部对齐，以防多行文本不对齐
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24), // 左侧图标
            const SizedBox(width: 16), // 图标和标签之间的间距
            Text(
              '$label: ', // 标签文本
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            Expanded(
              // Expanded 使值文本占据剩余空间，并能自动换行
              child: Text(
                value.isEmpty && label == "简介" ? "这家伙很神秘，什么都没留下..." : value, // 如果简介为空，显示提示
                style: TextStyle(fontSize: 16, color: Colors.grey[850]),
                maxLines: maxLines, // 最大行数
                overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible, // 超出部分显示省略号
              ),
            ),
          ],
        ),
      ),
    );
  }
}
