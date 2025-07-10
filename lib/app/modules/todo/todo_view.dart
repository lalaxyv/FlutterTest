// lib/app/modules/todo/todo_view.dart
// 这是 TODO 列表模块的视图 (View)。
// 它负责展示 TODO 事项列表，并提供用户交互（如添加、删除、标记完成）。

import 'package:flutter/material.dart'; // 导入 Flutter 的 Material UI 包
import 'package:get/get.dart'; // 导入 GetX 包
import 'package:intl/intl.dart'; // 导入 intl 包用于日期格式化

import './todo_controller.dart'; // 导入当前模块的控制器
import '../../data/models/todo_model.dart'; // 导入 TODO 模型

// TodoView 继承自 GetView<TodoController>，方便访问 TodoController。
// 由于 TodoController 是在 HomeBinding 中注册的，
// 当 TodoView 作为 HomeView 的一部分被构建时，GetX 能够找到已存在的 TodoController 实例。
class TodoView extends GetView<TodoController> {
  const TodoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 返回一个 Padding Widget，为列表内容提供边距
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0, bottom: 0.0), // 调整边距
      child: Column( // 垂直布局
        children: [
          // 输入区域：用于添加新的 TODO 事项
          _buildAddTodoInput(context), // 抽取为私有方法
          // 分隔线 (可选，如果输入区域和列表间需要更明显区隔)
          // const Divider(height: 1),
          // TODO 列表显示区域
          // Expanded 使 ListView 占据 Column 中的剩余垂直空间
          Expanded(
            // Obx 用于监听 controller.isLoading 和 controller.todoList 的变化。
            child: Obx(() {
              // 如果正在加载，显示一个居中的圆形进度指示器
              if (controller.isLoading.value && controller.todoList.isEmpty) { // 初始加载时显示
                return const Center(child: CircularProgressIndicator());
              }
              // 如果列表为空且不在加载中，显示提示信息
              if (controller.todoList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt_rounded, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        '没有 TODO 事项。\n尝试添加一些吧！',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              // 如果列表不为空，使用 ListView.builder 构建列表项
              // 使用 RefreshIndicator 包裹 ListView 以支持下拉刷新
              return RefreshIndicator(
                onRefresh: controller.fetchTodos, // 下拉时调用控制器的 fetchTodos 方法
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(), // 确保即使内容不足一屏也能触发下拉刷新
                  itemCount: controller.todoList.length, // 列表项的数量
                  // itemBuilder 用于构建每个列表项的 Widget
                  itemBuilder: (context, index) {
                    final TodoModel todo = controller.todoList[index]; // 获取当前索引的 TODO 对象
                    return _buildTodoItem(context, todo); // 抽取为私有方法
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 私有方法：构建添加 TODO 的输入区域
  Widget _buildAddTodoInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // 内边距
      child: Row( // 水平布局，包含输入框和添加按钮
        children: [
          Expanded( // Expanded 使 TextFormField 占据剩余空间
            child: TextFormField(
              controller: controller.newTodoInputController, // 关联文本控制器
              decoration: InputDecoration(
                hintText: '输入新的 TODO 事项...', // 输入框提示文本
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), // 边框样式
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // 内容边距
                isDense: true, // 使输入框更紧凑
              ),
              // 当用户在软键盘上按下 "done" 或提交时触发
              onFieldSubmitted: (value) {
                controller.addTodo(); // 调用控制器添加 TODO (无需传参，控制器会从 newTodoInputController 获取)
              },
              textInputAction: TextInputAction.done, // 软键盘动作按钮为 "完成"
            ),
          ),
          const SizedBox(width: 8), // 添加一个小间隔
          // 添加按钮
          IconButton(
            icon: Icon(Icons.add_task_rounded, color: Theme.of(context).primaryColor, size: 28), // 图标
            tooltip: '添加任务', // 长按提示
            onPressed: controller.addTodo, // 调用控制器添加 TODO
          ),
        ],
      ),
    );
  }

  // 私有方法：构建单个 TODO 列表项
  Widget _buildTodoItem(BuildContext context, TodoModel todo) {
    // 使用 DateFormat 来格式化日期时间，使其更易读
    // 需要添加 intl 包依赖: flutter pub add intl
    final DateFormat dateFormat = DateFormat('MM-dd HH:mm'); // 例如: 07-15 14:30

    // Card 提供了一个带有圆角和阴影的 Material Design 卡片容器
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.5), // 外边距
      elevation: 1.5, // 卡片阴影深度
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // 圆角
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 8.0, right: 0.0, top: 4.0, bottom: 4.0), // 调整内边距
        // 列表项前面的图标，用于标记完成状态
        leading: IconButton(
          icon: Icon(
            todo.isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, // 根据状态显示不同图标
            color: todo.isDone ? Colors.green : Theme.of(context).colorScheme.primary, // 根据状态显示不同颜色
            size: 26, // 图标大小
          ),
          tooltip: todo.isDone ? '标记为未完成' : '标记为已完成', // 长按提示
          onPressed: () {
            controller.toggleTodoStatus(todo); // 点击时切换任务状态
          },
        ),
        // 列表项的主要内容，显示任务文本
        title: Text(
          todo.task, // 显示任务文本
          style: TextStyle(
            fontSize: 16, // 字体大小
            // 根据完成状态设置删除线和颜色
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey[600] : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: todo.isDone ? FontWeight.normal : FontWeight.w500, // 未完成的加粗一点
          ),
        ),
        // 副标题，显示创建/更新时间 (可选)
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3.0), // 与标题间距
          child: Text(
            '创建于: ${dateFormat.format(todo.createdAt)}' +
            (todo.updatedAt != null && todo.updatedAt != todo.createdAt ? ' (更新于: ${dateFormat.format(todo.updatedAt!)})' : ''),
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ),
        // 列表项后面的图标，用于删除任务
        trailing: IconButton(
          icon: Icon(Icons.delete_sweep_rounded, color: Colors.redAccent[100], size: 24), // 删除图标
          tooltip: '删除任务', // 长按提示
          onPressed: () {
            // 显示确认删除对话框
            Get.defaultDialog(
              title: "确认删除",
              titleStyle: const TextStyle(fontWeight: FontWeight.bold),
              middleText: "您确定要删除这条 TODO 吗？\n\"${todo.task}\"",
              confirm: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  controller.deleteTodo(todo.id); // 确认后调用控制器删除任务
                  Get.back(); // 关闭对话框
                },
                child: const Text("删除", style: TextStyle(color: Colors.white)),
              ),
              cancel: OutlinedButton(
                onPressed: () => Get.back(), // 关闭对话框
                child: const Text("取消"),
              ),
              radius: 8.0, // 对话框圆角
            );
          },
        ),
        // 点击列表项本身也切换状态 (可选，因为前面已经有 IconButton 了)
        onTap: () {
           controller.toggleTodoStatus(todo);
        },
        // 长按操作 (可选，例如编辑)
        // onLongPress: () {
        //   // Get.snackbar('提示', '长按了: ${todo.task}');
        // },
      ),
    );
  }
}
