// lib/app/data/providers/api_provider.dart
// 该文件定义了 API 服务提供者 (ApiProvider)。
// ApiProvider 负责处理所有与后端 API 的通信，例如发送 HTTP 请求和接收响应。
// 它现在使用 Dio 作为 HTTP 客户端。

import 'package:flutter/material.dart'; // 导入 Material 包，用于颜色
import 'package:get/get.dart'; // 导入 GetX 包 (用于 Get.snackbar 等，非 GetConnect)
import 'package:dio/dio.dart'; // 导入 Dio 包
import '../models/user_model.dart'; // 导入用户模型
import '../models/todo_model.dart'; // 导入 TODO 模型
import '../models/song_model.dart'; // 导入歌曲模型

// 定义 API 的基础 URL。在实际应用中，这应该是你的后端服务器地址。
const String _baseUrl = 'https://api.example.com'; // 模拟的基础 URL

// ApiProvider 类不再继承自 GetConnect
class ApiProvider {
  late Dio _dio; // Dio 实例

  // --- 模拟数据区 ---

  // 用于存储模拟的 TODO 列表数据
  final List<TodoModel> _simulatedTodoList = [
    TodoModel(id: 'todo-1', task: '学习 Flutter GetX 状态管理', createdAt: DateTime.now().subtract(const Duration(days: 2)), isDone: true),
    TodoModel(id: 'todo-2', task: '编写一个示例 TODO 应用', createdAt: DateTime.now().subtract(const Duration(days: 1))),
    TodoModel(id: 'todo-3', task: '实现 API 数据模拟', createdAt: DateTime.now()),
    TodoModel(id: 'todo-4', task: '添加中文注释到所有代码', createdAt: DateTime.now().add(const Duration(hours: 1))),
    TodoModel(id: 'todo-5', task: '测试应用功能', createdAt: DateTime.now().add(const Duration(hours: 2)), isDone: false),
  ];
  int _nextTodoId = 6; // 用于生成新的 TODO ID

  // 用于存储模拟的播放列表数据 (从 PlayerController 移入)
  final List<SongModel> _simulatedPlaylist = [
      SongModel(
        id: '1', title: '夜曲', artist: '周杰伦',
        duration: const Duration(minutes: 3, seconds: 45),
        albumArtUrl: 'https://picsum.photos/seed/1/400',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        lyrics: """
[00:15.00]一群嗜血的蚂蚁
[00:18.50]被腐肉所吸引
[00:22.00]我面无表情
[00:25.50]看孤独的风景
[00:29.00]失去你 爱恨开始分明
[00:36.00]失去你 还有什么事好关心
[00:43.00]那鸽子不再象征和平
[00:46.50]我终于被提醒
[00:50.00]广场上喂食的是秃鹰
[00:57.00]我用漂亮的押韵
[01:00.50]形容被掠夺一空的爱情
"""
      ),
      SongModel(
        id: '2', title: '稻香', artist: '周杰伦',
        duration: const Duration(minutes: 3, seconds: 21),
        albumArtUrl: 'https://picsum.photos/seed/2/400',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        lyrics: """
[00:20.10]对这个世界如果你有太多的抱怨
[00:24.50]跌倒了就不敢继续往前走
[00:28.00]为什么人要这么的脆弱 堕落
[00:35.50]请你打开电视看看
[00:39.00]多少人为生命在努力勇敢的走下去
[00:43.00]我们是不是该知足
[00:46.50]珍惜一切 就算没有拥有
"""
      ),
      SongModel(
        id: '3', title: '青花瓷', artist: '周杰伦',
        duration: const Duration(minutes: 3, seconds: 58),
        albumArtUrl: 'https://picsum.photos/seed/3/400',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        lyrics: """
[00:10.00]素胚勾勒出青花笔锋浓转淡
[00:17.50]瓶身描绘的牡丹一如你初妆
[00:25.00]冉冉檀香透过窗心事我了然
[00:32.50]宣纸上走笔至此搁一半
[00:40.00]釉色渲染仕女图韵味被私藏
[00:47.50]而你嫣然的一笑如含苞待放
[00:55.00]你的美一缕飘散
[01:00.00]去到我去不了的地方
"""
      ),
  ];

  // ApiProvider 的构造函数，在这里初始化 Dio
  ApiProvider() {
    BaseOptions options = BaseOptions(
      baseUrl: _baseUrl, // 设置基础 URL
      connectTimeout: const Duration(seconds: 10), // 连接超时时间 (10秒)
      receiveTimeout: const Duration(seconds: 10), // 接收超时时间 (10秒)
    );
    _dio = Dio(options); // 创建 Dio 实例

    // 添加拦截器用于日志打印
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('发起 Dio 请求: ${options.method} ${options.uri}');
        if (options.data != null) {
          print('Dio 请求体: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('收到 Dio 响应: ${response.statusCode} for ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Dio 请求错误: ${e.requestOptions.uri}');
        print('Dio 错误信息: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // --- 登录相关 API ---
  Future<UserModel?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (username == 'testuser' && password == 'password123') {
      return UserModel(
        id: 'user-123',
        username: username,
        email: 'testuser@example.com',
        token: 'fake-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
        bio: '我是一个快乐的测试用户！',
      );
    } else if (username == 'jules' && password == 'flutter') {
      return UserModel(
        id: 'user-789',
        username: username,
        email: 'jules@example.dev',
        token: 'another-fake-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
        bio: '热爱 Flutter 开发！',
      );
    }
    else {
      Get.snackbar(
        '登录失败', '用户名或密码错误 (模拟)',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white,
      );
      return null;
    }
  }

  // --- TODO 相关 API ---
  Future<List<TodoModel>?> getTodos() async {
    await Future.delayed(const Duration(milliseconds: 700));
    print('API 模拟: 获取了 ${_simulatedTodoList.length} 条 TODO 事项。');
    return List<TodoModel>.from(_simulatedTodoList);
  }

  Future<TodoModel?> addTodo(String taskContent) async {
    await Future.delayed(const Duration(milliseconds: 500));
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
    _simulatedTodoList.add(newTodo);
    print('API 模拟: 添加了新的 TODO: ${newTodo.task}');
    return newTodo;
  }

  Future<TodoModel?> updateTodo(TodoModel todoToUpdate) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _simulatedTodoList.indexWhere((todo) => todo.id == todoToUpdate.id);
    if (index != -1) {
      _simulatedTodoList[index] = todoToUpdate.copyWith(updatedAt: DateTime.now());
      print('API 模拟: 更新了 TODO: ${todoToUpdate.task}, isDone: ${todoToUpdate.isDone}');
      return _simulatedTodoList[index];
    }
    Get.snackbar('错误', '未找到要更新的 TODO 项', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    return null;
  }

  Future<bool> deleteTodo(String todoId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final initialLength = _simulatedTodoList.length;
    _simulatedTodoList.removeWhere((todo) => todo.id == todoId);
    if (_simulatedTodoList.length < initialLength) {
      print('API 模拟: 删除了 TODO ID: $todoId');
      return true;
    }
    Get.snackbar('错误', '未找到要删除的 TODO 项', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    return false;
  }

  // --- 用户信息相关 API ---
  Future<UserModel?> getUserProfile(String userIdOrToken) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (userIdOrToken.contains('user-123') || userIdOrToken.contains('testuser')) {
      return UserModel(
          id: 'user-123', username: 'testuser', email: 'testuser@example.com',
          bio: '这是通过 API 获取的测试用户简介。',
      );
    } else if (userIdOrToken.contains('user-789') || userIdOrToken.contains('jules')) {
       return UserModel(
          id: 'user-789', username: 'jules', email: 'jules@example.dev', bio: 'Flutter 开发者，热爱开源。',
      );
    }
    return UserModel(
        id: 'user-123', username: 'testuser', email: 'testuser@example.com',
        bio: '这是默认的测试用户简介。',
    );
  }

  Future<UserModel?> updateUserProfile(UserModel userToUpdate) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (userToUpdate.id == 'user-123' || userToUpdate.id == 'user-789') {
        Get.snackbar('成功', '用户信息已在服务器端更新 (模拟)', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        return userToUpdate;
    }
    Get.snackbar('错误', '更新用户信息失败，用户未找到 (模拟)', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    return null;
  }

  // --- 播放器相关 API ---

  // 模拟获取播放列表
  Future<List<SongModel>?> getPlaylist() async {
    await Future.delayed(const Duration(milliseconds: 400)); // 模拟网络延迟
    print('API 模拟: 获取了 ${_simulatedPlaylist.length} 条播放列表歌曲。');
    return List<SongModel>.from(_simulatedPlaylist);
  }
}
