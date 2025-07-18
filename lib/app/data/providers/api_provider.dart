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
        id: '1',
        title: '夜曲',
        artist: '周杰伦',
        duration: const Duration(minutes: 3, seconds: 45),
        albumArtUrl:
            'https://links.jianshu.com/go?to=https%3A%2F%2Fupload-images.jianshu.io%2Fupload_images%2F5809200-a99419bb94924e6d.jpg%3FimageMogr2%2Fauto-orient%2Fstrip%257CimageView2%2F2%2Fw%2F1240',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        lyrics: """
            [ti:夜曲]
            [ar:周杰伦]
            [al:十一月的萧邦]
            [offset:0]
            [by:谢鑫 ]
            [00:00.00]歌曲：夜曲
            [00:04.51]歌手：周杰伦
            [00:07.65]专辑：十一月的萧邦
            [00:21.06]一群嗜血的蚂蚁被腐肉所吸引
            [00:25.18]我面无表情看孤独的风景
            [00:27.87]失去你爱开始分明
            [00:30.68]失去你还有什么事好关心
            [00:33.43]当鸽子不再象征和平
            [00:35.43]我终於被提醒
            [00:36.80]广场上餵食的是秃鹰
            [00:38.62]我用漂亮的押韵
            [00:40.37]形容被掠夺一空的爱情
            [00:43.81]啊乌云开始遮蔽夜色不乾净
            [00:46.99]公园里葬礼的回音在漫天飞行
            [00:49.62]送你的白色玫瑰
            [00:51.24]在纯黑的环境凋零
            [00:52.81]乌鸦在树枝上诡异的很安静
            [00:55.12]静静听我黑色的大衣
            [00:57.50]想温暖你日渐冰冷的回忆
            [00:59.87]走过的走过的生命
            [01:00.99]啊四周弥漫雾气
            [01:02.50]我在空旷的墓地
            [01:03.88]老去后还爱你
            [01:05.56]为你弹奏萧邦的夜曲
            [01:09.12]纪念我死去的爱情
            [01:11.74]跟夜风一样的声音
            [01:14.75]心碎的很好听
            [01:17.31]手在键盘敲很轻
            [01:20.06]我给的思念很小心
            [01:22.87]你埋葬的地方叫幽冥
            [01:27.69]为你弹奏萧邦的夜曲
            [01:31.12]纪念我死去的爱情
            [01:33.80]而我为你隐姓埋名
            [01:36.87]在月光下弹琴
            [01:39.43]对你心跳的感应
            [01:42.19]还是如此温热亲近
            [01:44.94]怀念你那鲜红的唇印
            [02:06.51]那些断翅的蜻蜓散落在这森林
            [02:15.51]而我的眼睛没有丝毫同情
            [02:18.31]失去你泪水混浊不清
            [02:20.94]失去你我连笑容都有阴影
            [02:23.69]风在长满青苔的屋顶
            [02:25.81]嘲笑我的伤心
            [02:27.13]像一口没有水的枯井
            [02:29.32]我用凄美的字型
            [02:30.81]描绘后悔莫及的那爱情
            [02:33.87]为你弹奏萧邦的夜曲
            [02:37.30]纪念我死去的爱情
            [02:40.13]跟夜风一样的声音
            [02:43.00]心碎的很好听
            [02:45.75]手在键盘敲很轻
            [02:48.38]我给的思念很小心
            [02:51.12]你埋葬的地方叫幽冥
            [02:55.88]为你弹奏萧邦的夜曲
            [02:59.44]纪念我死去的爱情
            [03:02.13]而我为你隐姓埋名在月光下弹琴
            [03:07.75]对你心跳的感应还是如此温热亲近
            [03:13.19]怀念你那鲜红的唇印
            [03:18.12]一群嗜血的蚂蚁被腐肉所吸引
            [03:21.69]我面无表情看孤独的风景
            [03:24.44]失去你爱开始分明
            [03:27.18]失去你还有什么事好关心
            [03:30.06]当鸽子不再象征和平
            [03:32.00]我终於被提醒
            [03:33.31]广场上餵食的是秃鹰
            [03:35.32]我用漂亮的押韵
            [03:37.00]形容被掠夺一空的爱情
            """),
    SongModel(
        id: '2',
        title: '稻香',
        artist: '周杰伦',
        duration: const Duration(minutes: 3, seconds: 21),
        albumArtUrl:
            'https://links.jianshu.com/go?to=https%3A%2F%2Fupload-images.jianshu.io%2Fupload_images%2F5809200-48dd99da471ffa3f.jpg%3FimageMogr2%2Fauto-orient%2Fstrip%257CimageView2%2F2%2Fw%2F1240',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        lyrics: """
          [00:20.10]对这个世界如果你有太多的抱怨
          [00:24.50]跌倒了就不敢继续往前走
          [00:28.00]为什么人要这么的脆弱 堕落
          [00:35.50]请你打开电视看看
          [00:39.00]多少人为生命在努力勇敢的走下去
          [00:43.00]我们是不是该知足
          [00:46.50]珍惜一切 就算没有拥有
          """),
    SongModel(
        id: '3',
        title: '青花瓷',
        artist: '周杰伦',
        duration: const Duration(minutes: 3, seconds: 58),
        albumArtUrl:
            'https://links.jianshu.com/go?to=https%3A%2F%2Fupload-images.jianshu.io%2Fupload_images%2F5809200-03bbbd715c24750e.jpg%3FimageMogr2%2Fauto-orient%2Fstrip%257CimageView2%2F2%2Fw%2F1240',
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
          """),
  ];

  // ApiProvider 的构造函数，在这里初始化 Dio
  ApiProvider() {
    BaseOptions options = BaseOptions(
      baseUrl: _baseUrl, // 设置基础 URL
      connectTimeout: const Duration(seconds: 10), // 连接超时时间 (10秒)
      receiveTimeout: const Duration(seconds: 10), // 接收超时时间 (10秒)
      // headers: { // 可以设置全局请求头
      //   'Content-Type': 'application/json',
      // },
    );
    _dio = Dio(options); // 创建 Dio 实例

    // 添加拦截器用于日志打印 (类似于 GetConnect 的 addRequestModifier 和 addResponseModifier)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('发起 Dio 请求: ${options.method} ${options.uri}'); // 打印请求信息
        if (options.data != null) {
          print('Dio 请求体: ${options.data}');
        }
        // 示例：如果本地存储了 token，可以添加到请求头
        // final token = GetStorage().read('authToken');
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        return handler.next(options); // 继续请求
      },
      onResponse: (response, handler) {
        print('收到 Dio 响应: ${response.statusCode} for ${response.requestOptions.uri}'); // 打印响应状态码
        // print('Dio 响应体: ${response.data}'); // 调试时小心数据量过大
        return handler.next(response); // 继续响应流程
      },
      onError: (DioException e, handler) {
        print('Dio 请求错误: ${e.requestOptions.uri}'); // 打印错误相关的请求信息
        print('Dio 错误类型: ${e.type}');
        print('Dio 错误信息: ${e.message}');
        if (e.response != null) {
          print('Dio 错误响应码: ${e.response?.statusCode}');
          print('Dio 错误响应体: ${e.response?.data}');
        }
        // 示例：处理常见的 HTTP 错误状态码
        // if (e.response?.statusCode == 401) { // 未授权
        //   // Get.offAllNamed(Routes.LOGIN);
        // }
        // Get.snackbar('API 错误', e.message ?? '未知Dio错误');
        return handler.next(e); // 继续错误流程
      },
    ));
  }

  // --- 登录相关 API ---

  // 模拟登录请求
  // 参数: username (用户名), password (密码)
  // 返回: Future<UserModel?>，成功则为 UserModel，失败则为 null 或抛出异常
  Future<UserModel?> login(String username, String password) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // 实际使用 Dio 的 API 请求示例 (已注释):
    // try {
    //   final response = await _dio.post(
    //     '/auth/login', // 登录接口的路径
    //     data: {'username': username, 'password': password}, // 请求体
    //   );
    //   if (response.statusCode == 200 && response.data != null) {
    //     // 假设响应体是包含用户数据和 token 的 JSON
    //     return UserModel.fromJson(response.data as Map<String, dynamic>);
    //   } else {
    //     // 处理非200状态码或其他错误情况
    //     Get.snackbar('登录失败', response.data?['message'] ?? response.statusMessage ?? '用户名或密码错误');
    //     return null;
    //   }
    // } on DioException catch (e) {
    //   // Dio 异常处理 (例如网络错误, 超时等)
    //   print('Dio login error: $e');
    //   Get.snackbar('登录异常', e.message ?? '网络请求失败');
    //   return null;
    // } catch (e) {
    //   // 其他未知异常
    //   print('Unknown login error: $e');
    //   Get.snackbar('登录异常', '发生未知错误');
    //   return null;
    // }

    // --- 以下为模拟逻辑 (保持不变) ---
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
    } else {
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
    // 实际使用 Dio 的 API 请求示例 (已注释):
    // try {
    //   final response = await _dio.get('/todos');
    //   if (response.statusCode == 200 && response.data != null) {
    //     return (response.data as List).map((json) => TodoModel.fromJson(json as Map<String, dynamic>)).toList();
    //   }
    //   return null;
    // } on DioException catch (e) {
    //   print('Dio getTodos error: $e');
    //   Get.snackbar('获取TODO异常', e.message ?? '网络请求失败');
    //   return null;
    // } catch (e) {
    //   print('Unknown getTodos error: $e');
    //   Get.snackbar('获取TODO异常', '发生未知错误');
    //   return null;
    // }

    // --- 以下为模拟逻辑 (保持不变) ---
    print('API 模拟: 获取了 ${_simulatedTodoList.length} 条 TODO 事项。');
    return List<TodoModel>.from(_simulatedTodoList); // 返回模拟列表的副本
  }

  // 模拟添加新的 TODO 事项
  Future<TodoModel?> addTodo(String taskContent) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
    // --- 以下为模拟逻辑 (部分修改以演示前置检查) ---
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

    // 实际使用 Dio 的 API 请求示例 (已注释):
    // try {
    //   final response = await _dio.post('/todos', data: newTodo.toJson());
    //   if (response.statusCode == 201 && response.data != null) { // 通常创建成功是 201
    //     return TodoModel.fromJson(response.data as Map<String, dynamic>);
    //   }
    //   return null;
    // } on DioException catch (e) {
    //   print('Dio addTodo error: $e');
    //   Get.snackbar('添加TODO异常', e.message ?? '网络请求失败');
    //   return null;
    // } catch (e) {
    //   print('Unknown addTodo error: $e');
    //   Get.snackbar('添加TODO异常', '发生未知错误');
    //   return null;
    // }

    // --- 以下为模拟逻辑 (核心部分保持不变) ---
    _simulatedTodoList.add(newTodo);
    print('API 模拟: 添加了新的 TODO: ${newTodo.task}');
    return newTodo;
  }

  // 模拟更新 TODO 事项 (例如切换完成状态)
  Future<TodoModel?> updateTodo(TodoModel todoToUpdate) async {
    await Future.delayed(const Duration(milliseconds: 300)); // 模拟网络延迟
    // 实际使用 Dio 的 API 请求示例 (已注释):
    // try {
    //   final response = await _dio.put('/todos/${todoToUpdate.id}', data: todoToUpdate.toJson());
    //   if (response.statusCode == 200 && response.data != null) {
    //     return TodoModel.fromJson(response.data as Map<String, dynamic>);
    //   }
    //   return null;
    // } on DioException catch (e) {
    //   print('Dio updateTodo error: $e');
    //   Get.snackbar('更新TODO异常', e.message ?? '网络请求失败');
    //   return null;
    // } catch (e) {
    //   print('Unknown updateTodo error: $e');
    //   Get.snackbar('更新TODO异常', '发生未知错误');
    //   return null;
    // }

    // --- 以下为模拟逻辑 (核心部分保持不变) ---
    final index = _simulatedTodoList.indexWhere((todo) => todo.id == todoToUpdate.id);
    if (index != -1) {
      _simulatedTodoList[index] = todoToUpdate.copyWith(updatedAt: DateTime.now());
      print('API 模拟: 更新了 TODO: ${todoToUpdate.task}, isDone: ${todoToUpdate.isDone}');
      return _simulatedTodoList[index];
    }
    Get.snackbar('错误', '未找到要更新的 TODO 项', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    return null;
  }

  // 模拟删除 TODO 事项
  Future<bool> deleteTodo(String todoId) async {
    await Future.delayed(const Duration(milliseconds: 400)); // 模拟网络延迟
    // 实际使用 Dio 的 API 请求示例 (已注释):
    // try {
    //   final response = await _dio.delete('/todos/$todoId');
    //   return response.statusCode == 200 || response.statusCode == 204; // 删除成功通常是 200 或 204
    // } on DioException catch (e) {
    //   print('Dio deleteTodo error: $e');
    //   Get.snackbar('删除TODO异常', e.message ?? '网络请求失败');
    //   return false;
    // } catch (e) {
    //   print('Unknown deleteTodo error: $e');
    //   Get.snackbar('删除TODO异常', '发生未知错误');
    //   return false;
    // }

    // --- 以下为模拟逻辑 (核心部分保持不变) ---
    final initialLength = _simulatedTodoList.length;
    _simulatedTodoList.removeWhere((todo) => todo.id == todoId);
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

    // 实际使用 Dio 的 API 请求示例 (已注释):
    // try {
    //   // 假设 token 已通过拦截器添加到 header，或者在这里直接添加
    //   // final response = await _dio.get('/users/profile'); // 如果是获取当前登录用户的profile
    //   final response = await _dio.get('/users/$userIdOrToken'); // 如果是根据ID获取特定用户
    //   if (response.statusCode == 200 && response.data != null) {
    //     return UserModel.fromJson(response.data as Map<String, dynamic>);
    //   }
    //   return null;
    // } on DioException catch (e) {
    //   print('Dio getUserProfile error: $e');
    //   Get.snackbar('获取用户信息异常', e.message ?? '网络请求失败');
    //   return null;
    // } catch (e) {
    //   print('Unknown getUserProfile error: $e');
    //   Get.snackbar('获取用户信息异常', '发生未知错误');
    //   return null;
    // }

    // --- 模拟逻辑 (保持不变) ---
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

    // 实际使用 Dio 的 API 请求示例 (已注释):
    // try {
    //   // final response = await _dio.put('/users/profile', data: userToUpdate.toJson()); // 更新当前登录用户
    //   final response = await _dio.put('/users/${userToUpdate.id}', data: userToUpdate.toJson()); // 根据ID更新特定用户
    //   if (response.statusCode == 200 && response.data != null) {
    //     return UserModel.fromJson(response.data as Map<String, dynamic>);
    //   }
    //   return null;
    // } on DioException catch (e) {
    //   print('Dio updateUserProfile error: $e');
    //   Get.snackbar('更新用户信息异常', e.message ?? '网络请求失败');
    //   return null;
    // } catch (e) {
    //   print('Unknown updateUserProfile error: $e');
    //   Get.snackbar('更新用户信息异常', '发生未知错误');
    //   return null;
    // }

    // --- 模拟逻辑 (核心部分保持不变) ---
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

  // --- 播放器相关 API ---

  // 模拟获取播放列表
  Future<List<SongModel>?> getPlaylist() async {
    await Future.delayed(const Duration(milliseconds: 400)); // 模拟网络延迟
    print('API 模拟: 获取了 ${_simulatedPlaylist.length} 条播放列表歌曲。');
    return List<SongModel>.from(_simulatedPlaylist);
  }
}
