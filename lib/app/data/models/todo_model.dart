// lib/app/data/models/todo_model.dart
// 该文件定义了 TODO 事项的数据模型 (TodoModel)。

// TodoModel 类定义了单个 TODO 事项的属性
class TodoModel {
  final String id; // TODO 事项的唯一标识符
  String task; // TODO 事项的具体内容/任务描述
  bool isDone; // 标记该 TODO 事项是否已完成
  final DateTime createdAt; // TODO 事项的创建时间 (可选，但推荐)
  DateTime? updatedAt; // TODO 事项的最后更新时间 (可选)

  // TodoModel 的构造函数
  TodoModel({
    required this.id, // id 是必需的
    required this.task, // task 是必需的
    this.isDone = false, // isDone 默认为 false (未完成)
    required this.createdAt, // createdAt 是必需的
    this.updatedAt, // updatedAt 是可选的
  });

  // 工厂构造函数：从 JSON 对象 (Map<String, dynamic>) 创建 TodoModel 实例
  // 用于从 API 响应中解析 TODO 数据。
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String, // 从 JSON 中获取 id
      task: json['task'] as String, // 从 JSON 中获取 task
      isDone: json['isDone'] as bool? ?? false, // 从 JSON 中获取 isDone，如果不存在则默认为 false
      // 将 ISO 8601 格式的日期时间字符串转换为 DateTime 对象
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // 方法：将 TodoModel 实例转换为 JSON 对象 (Map<String, dynamic>)
  // 用于向 API 发送 TODO 数据（例如创建或更新 TODO）。
  Map<String, dynamic> toJson() {
    return {
      'id': id, // TODO id
      'task': task, // 任务内容
      'isDone': isDone, // 完成状态
      'createdAt': createdAt.toIso8601String(), // 将 DateTime 对象转换为 ISO 8601 格式的字符串
      'updatedAt': updatedAt?.toIso8601String(), // 如果 updatedAt 不为 null，则转换
    };
  }

  // (可选) copyWith 方法，用于创建 TodoModel 的副本，但可以修改某些属性。
  TodoModel copyWith({
    String? id,
    String? task,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false, // 特殊标志，用于明确清除 updatedAt
  }) {
    return TodoModel(
      id: id ?? this.id,
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  // (可选) 重写 toString 方法，方便调试时打印 TodoModel 对象信息
  @override
  String toString() {
    return 'TodoModel(id: $id, task: "$task", isDone: $isDone, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
