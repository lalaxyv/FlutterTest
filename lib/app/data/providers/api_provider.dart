// lib/app/data/providers/api_provider.dart
// 该文件定义了 API 服务提供者 (ApiProvider)。
// ApiProvider 负责处理所有与后端 API 的通信，例如发送 HTTP 请求和接收响应。
// 它使用 GetConnect (GetX 内置的 HTTP 客户端) 来执行这些操作。

import 'package:flutter/material.dart'; // 导入 Material 包，用于颜色
import 'package:get/get.dart'; // 导入 GetX 包
import '../models/user_model.dart'; // 导入用户模型
import '../models/todo_model.dart'; // 导入 TODO 模型

// 定义 API 的基础 URL。在实际应用中，这应该是你的后端服务器地址。
const String _baseUrl = 'https://api.example.com'; // 模拟的基础 URL

// ApiProvider 类继承自 GetConnect，获得了 HTTP 请求的能力。
class ApiProvider extends GetConnect {
  // 用于存储模拟的 TODO 列表数据
  final List<TodoModel> _simulatedTodoList = [
    TodoModel(id: 'todo-1', task: '学习 Flutter GetX 状态管理', createdAt: DateTime.now().subtract(const Duration(days: 2)), isDone: true),
    TodoModel(id: 'todo-2', task: '编写一个示例 TODO 应用', createdAt: DateTime.now().subtract(const Duration(days: 1))),
    TodoModel(id: 'todo-3', task: '实现 API 数据模拟', createdAt: DateTime.now()),
    TodoModel(id: 'todo-4', task: '添加中文注释到所有代码', createdAt: DateTime.now().add(const Duration(hours: 1))),
    TodoModel(id: 'todo-5', task: '测试应用功能', createdAt: DateTime.now().add(const Duration(hours: 2)), isDone: false),
  ];
  int _nextTodoId = 6; // 用于生成新的 TODO ID

  // onInit 方法在 GetConnect 实例初始化时调用。
  // 可以在这里进行一些全局配置，例如设置基础 URL、超时时间、拦截器等。
  @override
  void onInit() {
    // httpClient 是 GetConnect 提供的 HTTP 客户端实例。
    httpClient.baseUrl = _baseUrl; // 设置所有请求的基础 URL
    httpClient.timeout = const Duration(seconds: 10); // 设置默认超时时间为10秒

    // 添加请求拦截器 (可选)
    // 可以在每个请求发送前执行一些操作，例如添加认证 Token 到请求头。
    httpClient.addRequestModifier<dynamic>((request) {
      print('发起请求: ${request.method} ${request.url}'); // 打印请求信息以供调试
      // 示例：如果本地存储了 token，可以添加到请求头
      // final token = GetStorage().read('authToken');
      // if (token != null) {
      //   request.headers['Authorization'] = 'Bearer $token';
      // }
      return request; // 返回修改后的请求对象
    });

    // 添加响应拦截器 (可选)
    // 可以在收到响应后执行一些操作，例如统一处理错误、解析数据等。
    httpClient.addResponseModifier<dynamic>((request, response) {
      print('收到响应: ${response.statusCode} for ${request.url}'); // 打印响应状态码
      // print('响应体: ${response.bodyString}'); // 打印响应体 (调试时小心数据量过大)
      // 示例：处理常见的 HTTP 错误状态码
      // if (response.status.hasError) {
      //   if (response.status.isUnauthorized) {
      //     // 处理未授权错误，例如跳转到登录页
      //     Get.offAllNamed(Routes.LOGIN);
      //   }
      //   // 可以抛出自定义异常或显示错误提示
      //   // Get.snackbar('API 错误', response.statusText ?? '未知错误');
      // }
      return response; // 返回原始响应对象
    });
  }

  // --- 登录相关 API ---

  // 模拟登录请求
  // 参数: username (用户名), password (密码)
  // 返回: Future<UserModel?>，成功则为 UserModel，失败则为 null 或抛出异常
  Future<UserModel?> login(String username, String password) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // 模拟 API 请求和响应
    // 在实际应用中，这里会是类似这样的代码：
    // final response = await post(
    //   '/auth/login', // 登录接口的路径
    //   {'username': username, 'password': password}, // 请求体
    // );
    // if (response.isOk && response.body != null) {
    //   // 假设响应体是包含用户数据和 token 的 JSON
    //   return UserModel.fromJson(response.body as Map<String, dynamic>);
    // } else {
    //   // 处理错误情况，例如显示提示或返回 null
    //   Get.snackbar('登录失败', response.body?['message'] ?? response.statusText ?? '用户名或密码错误');
    //   return null;
    // }

    // --- 以下为模拟逻辑 ---
    if (username == 'testuser' && password == 'password123') {
      // 模拟成功登录
      print('模拟登录成功: $username');
      // 返回一个模拟的 UserModel 对象
      return UserModel(
        id: 'user-123',
        username: username,
        email: 'testuser@example.com',
        token: 'fake-jwt-token-${DateTime.now().millisecondsSinceEpoch}', // 生成一个伪造的 token
        bio: '我是一个快乐的测试用户！',
      );
    } else if (username == 'jules' && password == 'flutter') {
      // 模拟另一个成功登录的用户
      print('模拟登录成功: $username');
      return UserModel(
        id: 'user-789',
        username: username,
        email: 'jules@example.dev',
        token: 'another-fake-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
        bio: '热爱 Flutter 开发！',
      );
    }
    else {
      // 模拟登录失败
      print('模拟登录失败: $username');
      Get.snackbar(
        '登录失败',
        '用户名或密码错误 (模拟)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null; // 返回 null 表示登录失败
    }
    // --- 模拟逻辑结束 ---
  }


  // --- TODO 相关 API ---

  // 模拟获取所有 TODO 事项
  Future<List<TodoModel>?> getTodos() async {
    await Future.delayed(const Duration(milliseconds: 700)); // 模拟网络延迟
    // 在实际应用中:
    // final response = await get('/todos');
    // if (response.isOk && response.body != null) {
    //   return (response.body as List).map((json) => TodoModel.fromJson(json)).toList();
    // }
    // return null;
    print('API 模拟: 获取了 ${_simulatedTodoList.length} 条 TODO 事项。');
    return List<TodoModel>.from(_simulatedTodoList); // 返回模拟列表的副本
  }

  // 模拟添加新的 TODO 事项
  Future<TodoModel?> addTodo(String taskContent) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
    if (taskContent.isEmpty) {
      Get.snackbar('错误', '任务内容不能为空', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
      return null;
    }
    final newTodo = TodoModel(
      id: 'todo-${_nextTodoId++}',
      task: taskContent,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    // 在实际应用中:
    // final response = await post('/todos', newTodo.toJson());
    // if (response.isOk && response.body != null) {
    //   return TodoModel.fromJson(response.body);
    // }
    // return null;
    _simulatedTodoList.add(newTodo);
    print('API 模拟: 添加了新的 TODO: ${newTodo.task}');
    return newTodo;
  }

  // 模拟更新 TODO 事项 (例如切换完成状态)
  Future<TodoModel?> updateTodo(TodoModel todoToUpdate) async {
    await Future.delayed(const Duration(milliseconds: 300)); // 模拟网络延迟
    final index = _simulatedTodoList.indexWhere((todo) => todo.id == todoToUpdate.id);
    if (index != -1) {
      _simulatedTodoList[index] = todoToUpdate.copyWith(updatedAt: DateTime.now());
      // 在实际应用中:
      // final response = await put('/todos/${todoToUpdate.id}', todoToUpdate.toJson());
      // if (response.isOk && response.body != null) {
      //   return TodoModel.fromJson(response.body);
      // }
      // return null;
      print('API 模拟: 更新了 TODO: ${todoToUpdate.task}, isDone: ${todoToUpdate.isDone}');
      return _simulatedTodoList[index];
    }
    Get.snackbar('错误', '未找到要更新的 TODO 项', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    return null;
  }

  // 模拟删除 TODO 事项
  Future<bool> deleteTodo(String todoId) async {
    await Future.delayed(const Duration(milliseconds: 400)); // 模拟网络延迟
    final initialLength = _simulatedTodoList.length;
    _simulatedTodoList.removeWhere((todo) => todo.id == todoId);
    // 在实际应用中:
    // final response = await delete('/todos/$todoId');
    // return response.isOk;
    if (_simulatedTodoList.length < initialLength) {
      print('API 模拟: 删除了 TODO ID: $todoId');
      return true;
    }
    Get.snackbar('错误', '未找到要删除的 TODO 项', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    return false;
  }

  // --- 用户信息相关 API (占位) ---
  // Future<UserModel?> getUserProfile() async { /* ... */ return null;}
  // Future<bool> updateUserProfile(UserModel user) async { /* ... */ return false;}


  // 模拟获取当前登录用户的个人信息
  // 通常这需要一个 token 或用户 ID，但在模拟中我们简化处理
  Future<UserModel?> getUserProfile(String userIdOrToken) async {
    await Future.delayed(const Duration(milliseconds: 600)); // 模拟网络延迟

    // 在实际应用中，你可能会从本地存储获取当前用户ID或token，然后请求特定用户的信息
    // final response = await get('/users/profile'); // 或者 /users/{userId}
    // if (response.isOk && response.body != null) {
    //   return UserModel.fromJson(response.body);
    // }
    // return null;

    // --- 模拟逻辑 ---
    // 假设我们根据之前登录时生成的 token 或 id 来返回用户信息
    // 为了简单，我们只返回一个固定的模拟用户数据，或者可以基于登录时的用户数据
    // 这里我们用一个固定的 testuser 的信息作为示例，因为 Profile 模块的 Controller
    // 还没有与 LoginController 的登录结果进行真正的关联。
    // 理想情况下，LoginController 登录成功后会将 UserModel 存到某个全局状态或者传递过来。
    if (userIdOrToken.contains('user-123') || userIdOrToken.contains('testuser')) {
      print('API 模拟: 获取用户 "testuser" 的个人信息');
      return UserModel(
          id: 'user-123',
          username: 'testuser',
          email: 'testuser@example.com',
          bio: '这是通过 API 获取的测试用户简介。',
          // token 不需要在这里返回，因为通常 token 是登录时获取的，用于后续请求认证
      );
    } else if (userIdOrToken.contains('user-789') || userIdOrToken.contains('jules')) {
       print('API 模拟: 获取用户 "jules" 的个人信息');
       return UserModel(
          id: 'user-789',
          username: 'jules',
          email: 'jules@example.dev',
          bio: 'Flutter 开发者，热爱开源。',
      );
    }

    // 如果没有匹配的用户，或者模拟一个未找到的情况
    // Get.snackbar('错误', '未能获取用户信息 (模拟)', snackPosition: SnackPosition.BOTTOM);
    // return null;
    // 为了让 ProfileController 能获取到数据，我们默认返回 testuser
     print('API 模拟: userIdOrToken "$userIdOrToken" 未直接匹配，默认返回 testuser 的信息');
    return UserModel(
        id: 'user-123',
        username: 'testuser',
        email: 'testuser@example.com',
        bio: '这是默认的测试用户简介。',
    );
    // --- 模拟逻辑结束 ---
  }

  // 模拟更新用户个人信息
  Future<UserModel?> updateUserProfile(UserModel userToUpdate) async {
    await Future.delayed(const Duration(milliseconds: 800)); // 模拟网络延迟

    // 在实际应用中:
    // final response = await put('/users/profile', userToUpdate.toJson()); // 或者 /users/{userId}
    // if (response.isOk && response.body != null) {
    //   // API 应该返回更新后的用户信息
    //   return UserModel.fromJson(response.body);
    // }
    // return null; // 或抛出异常

    // --- 模拟逻辑 ---
    // 在这个模拟中，我们只是打印信息并直接返回传入的用户数据，假装更新成功
    // 实际应用中，服务器会验证数据、持久化存储，并可能返回包含更新时间戳等信息的对象
    print('API 模拟: 尝试更新用户信息 ID: ${userToUpdate.id}');
    print('API 模拟: 更新后的数据: Username: ${userToUpdate.username}, Email: ${userToUpdate.email}, Bio: ${userToUpdate.bio}');

    // 简单地返回传入的对象，可以加上一些服务器可能做的修改，比如更新时间
    // return userToUpdate.copyWith( /* 假设服务器会更新某些字段，比如 updatedAt */ );

    // 为了让 ProfileController 的逻辑能够顺利进行，我们假设更新成功并返回更新后的 userToUpdate
    // 注意：这个模拟不会持久化 _simulatedLoginUser 或其他地方的数据。
    // 如果希望 Profile 页能反映真实的登录用户数据，需要在 LoginController 登录成功后
    // 将 UserModel 存储到 GetX Service 或 GetStorage 中，ProfileController 再从中读取。

    // 查找是否存在该用户（基于ID），如果存在则更新
    // （这个模拟的API Provider没有一个用户列表来更新，所以我们直接返回）
    if (userToUpdate.id == 'user-123' || userToUpdate.id == 'user-789') {
        Get.snackbar('成功', '用户信息已在服务器端更新 (模拟)', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        return userToUpdate; // 直接返回传入的对象，模拟更新成功
    }

    Get.snackbar('错误', '更新用户信息失败，用户未找到 (模拟)', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    return null; // 模拟用户不存在的情况
    // --- 模拟逻辑结束 ---
  }
  // Future<bool> updateUserProfile(UserModel user) async { /* ... */ return false;}

}
