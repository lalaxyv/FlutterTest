// lib/app/modules/todo/todo_controller.dart
// 这是 TODO 列表模块的控制器 (Controller)。
// 它将负责管理 TODO 事项的数据、获取、添加、删除、标记完成等业务逻辑。

import 'package:flutter/material.dart'; // 导入 Material 包，用于 TextEditingController 和颜色
import 'package:get/get.dart'; // 导入 GetX 包
import '../../data/models/todo_model.dart'; // 导入 TODO 模型
import '../../data/providers/api_provider.dart'; // 导入 API Provider

// TodoController 类继承自 GetxController
class TodoController extends GetxController {
  // 获取已注册的 ApiProvider 实例
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // 使用 .obs 创建一个响应式的 TODO 事项列表。
  // RxList 是 GetX提供的响应式列表类型，用于存储 TodoModel 对象。
  var todoList = <TodoModel>[].obs;

  // 加载状态，用于在获取数据时显示加载指示器
  var isLoading = true.obs; // 初始为 true，因为一开始就要加载数据

  // 用于输入新 TODO 事项的文本控制器 (来自 Flutter Material 包)
  final TextEditingController newTodoInputController = TextEditingController();

  // onInit 是 GetxController 的生命周期方法，在控制器初始化时调用。
  @override
  void onInit() {
    super.onInit(); // 调用父类的 onInit 方法
    fetchTodos(); // 初始化时获取 TODO 列表
  }

  // onClose 是 GetxController 的生命周期方法，在控制器销毁前调用。
  @override
  void onClose() {
    newTodoInputController.dispose(); // 释放 TextEditingController 资源
    super.onClose(); // 调用父类的 onClose 方法
  }

  // 获取 TODO 列表的方法
  Future<void> fetchTodos() async {
    try {
      isLoading.value = true; // 开始加载
      final List<TodoModel>? todosFromApi = await _apiProvider.getTodos(); // 调用 API 获取数据
      if (todosFromApi != null) {
        // 对获取到的 TODO 事项按创建时间降序排序 (最新的在前面)
        todosFromApi.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        todoList.assignAll(todosFromApi); // 使用 assignAll 更新整个列表，会触发 UI 更新
      } else {
        // 如果 API 返回 null (模拟中不太可能，除非 API Provider 逻辑改变)
        Get.snackbar('获取失败', '未能从服务器获取 TODO 列表',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
      }
    } catch (e) {
      // 捕获 API 调用或处理过程中的异常
      print('获取 TODO 列表失败: $e'); // 打印错误日志
      Get.snackbar('错误', '获取 TODO 列表失败: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      todoList.clear(); // 出错时清空列表，避免显示旧数据
    } finally {
      isLoading.value = false; // 结束加载
    }
  }

  // 添加新的 TODO 事项的方法
  Future<void> addTodo() async {
    final String taskContent = newTodoInputController.text.trim(); // 获取输入内容并去除首尾空格
    if (taskContent.isEmpty) {
      Get.snackbar('提示', '请输入 TODO 内容',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orangeAccent);
      return; // 如果内容为空，则不执行添加操作
    }

    isLoading.value = true; // 开始加载 (可选，添加操作通常较快)
    try {
      final TodoModel? newTodo = await _apiProvider.addTodo(taskContent); // 调用 API 添加 TODO
      if (newTodo != null) {
        // todoList.add(newTodo); // 直接添加到列表末尾
        todoList.insert(0, newTodo); // 添加到列表开头，使新添加的项显示在最上面
        newTodoInputController.clear(); // 清空输入框
        Get.snackbar('成功', 'TODO "${newTodo.task}" 已添加',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      }
      // ApiProvider 内部已处理 newTodo 为 null 的情况 (例如 taskContent 为空)
    } catch (e) {
      print('添加 TODO 失败: $e'); // 打印错误日志
      Get.snackbar('错误', '添加 TODO 失败: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false; // 结束加载
    }
  }

  // 删除 TODO 事项的方法
  Future<void> deleteTodo(String todoId) async {
    isLoading.value = true; // 开始加载 (可选)
    try {
      final bool success = await _apiProvider.deleteTodo(todoId); // 调用 API 删除 TODO
      if (success) {
        final String deletedTaskName = todoList.firstWhereOrNull((t) => t.id == todoId)?.task ?? "该任务";
        todoList.removeWhere((todo) => todo.id == todoId); // 从本地列表中移除
        Get.snackbar('成功', 'TODO "$deletedTaskName" 已删除',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.grey[700], colorText: Colors.white);
      }
      // ApiProvider 内部已处理删除失败 (未找到项) 的情况
    } catch (e) {
      print('删除 TODO 失败: $e'); // 打印错误日志
      Get.snackbar('错误', '删除 TODO 失败: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false; // 结束加载
    }
  }

  // 切换 TODO 事项完成状态的方法
  Future<void> toggleTodoStatus(TodoModel todo) async {
    // isLoading.value = true; // 开始加载 (可选, 状态切换通常非常快)
    final originalStatus = todo.isDone; // 保存原始状态，以便出错时恢复
    todo.isDone = !todo.isDone; // 立即更新本地状态以获得即时反馈
    todoList.refresh(); // 强制刷新列表以更新UI (因为我们修改了列表内对象的属性)

    try {
      final TodoModel? updatedTodo = await _apiProvider.updateTodo(todo); // 调用 API 更新状态
      if (updatedTodo == null) {
        // 如果 API 更新失败，恢复本地状态
        todo.isDone = originalStatus;
        todoList.refresh(); // 再次刷新列表
        // ApiProvider 内部已处理更新失败 (未找到项) 的情况
      } else {
        // API 更新成功，可以根据需要显示提示
        // Get.snackbar('状态更新', 'TODO "${updatedTodo.task}" 状态已更新',
        //     snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
      }
    } catch (e) {
      print('更新 TODO 状态失败: $e'); // 打印错误日志
      // 出错时恢复本地状态
      todo.isDone = originalStatus;
      todoList.refresh(); // 再次刷新列表
      Get.snackbar('错误', '更新 TODO 状态失败: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      // isLoading.value = false; // 结束加载
    }
  }
}
