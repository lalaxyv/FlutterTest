// lib/app/data/models/lyric_model.dart
// 该文件定义了歌词数据模型。

// LyricLine 类代表一行带有时间戳的歌词。
class LyricLine {
  final Duration timestamp; // 这行歌词开始显示的时间点
  final String text; // 歌词文本内容

  // LyricLine 的构造函数
  LyricLine({
    required this.timestamp,
    required this.text,
  });

  // (可选) 重写 toString 方法，方便调试
  @override
  String toString() {
    return 'LyricLine(timestamp: $timestamp, text: "$text")';
  }
}
