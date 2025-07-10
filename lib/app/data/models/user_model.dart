// lib/app/data/models/user_model.dart
// 该文件定义了用户数据模型 (UserModel)。
// 模型类用于封装和组织从 API 获取或发送到 API 的数据结构。

// UserModel 类定义了用户的基本属性
class UserModel {
  final String id; // 用户唯一标识符
  final String username; // 用户名
  final String email; // 用户邮箱
  final String? token; // 用户登录后的访问令牌 (可选)
  final String? bio; // 用户简介 (可选)

  // UserModel 的构造函数
  UserModel({
    required this.id, // id 是必需的
    required this.username, // username 是必需的
    required this.email, // email 是必需的
    this.token, // token 是可选的
    this.bio, // bio 是可选的
  });

  // 工厂构造函数：从 JSON 对象 (Map<String, dynamic>) 创建 UserModel 实例
  // 这在从 API 响应中解析用户数据时非常有用。
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String, // 从 JSON 中获取 id，并断言为 String 类型
      username: json['username'] as String, // 从 JSON 中获取 username
      email: json['email'] as String, // 从 JSON 中获取 email
      token: json['token'] as String?, // 从 JSON 中获取 token (可能为 null)
      bio: json['bio'] as String?, // 从 JSON 中获取 bio (可能为 null)
    );
  }

  // 方法：将 UserModel 实例转换为 JSON 对象 (Map<String, dynamic>)
  // 这在向 API 发送用户数据时（例如更新用户信息）非常有用。
  Map<String, dynamic> toJson() {
    return {
      'id': id, // 用户 id
      'username': username, // 用户名
      'email': email, // 用户邮箱
      'token': token, // 用户令牌
      'bio': bio, // 用户简介
    };
  }

  // (可选) copyWith 方法，用于创建 UserModel 的副本，但可以修改某些属性。
  // 这对于状态管理中不可变对象的更新很有帮助。
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? token,
    String? bio,
    bool clearToken = false, // 特殊标志，用于明确清除 token
    bool clearBio = false,   // 特殊标志，用于明确清除 bio
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      token: clearToken ? null : (token ?? this.token), // 如果 clearToken 为 true，则 token 为 null
      bio: clearBio ? null : (bio ?? this.bio),       // 如果 clearBio 为 true，则 bio 为 null
    );
  }

  // (可选) 重写 toString 方法，方便调试时打印 UserModel 对象信息
  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, token: $token, bio: $bio)';
  }
}
