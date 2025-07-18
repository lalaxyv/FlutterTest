// lib/app/shared/utils/lyric_parser.dart
// 该文件包含一个用于解析 LRC 格式歌词的工具类。

import '../../data/models/lyric_model.dart'; // 导入歌词行模型

// LyricParser 类提供静态方法来处理歌词字符串。
class LyricParser {
  // 一个正则表达式，用于匹配 LRC 歌词中的时间戳，例如 [00:15.00] 或 [00:18.50]
  static final RegExp _timeRegex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]');

  // parse 方法接收一个 LRC 格式的字符串，并将其转换为 LyricLine 对象的列表。
  static List<LyricLine> parse(String lrcString) {
    final List<LyricLine> lyrics = []; // 初始化一个空列表来存储解析后的歌词行

    // 按行分割歌词字符串
    final lines = lrcString.split('\n');

    // 遍历每一行
    for (final line in lines) {
      // 使用正则表达式查找所有匹配的时间戳
      final matches = _timeRegex.allMatches(line);
      if (matches.isNotEmpty) {
        // 获取该行中最后一个时间戳之后的部分作为歌词文本
        final text = line.substring(matches.last.end).trim();
        // 如果文本不为空
        if (text.isNotEmpty) {
          // 遍历该行所有的匹配项（因为一行可能对应多个时间戳，如 [00:01.00][00:02.00]Some Text）
          for (final match in matches) {
            // 从匹配项中提取分钟、秒和毫秒
            final minutes = int.parse(match.group(1)!);
            final seconds = int.parse(match.group(2)!);
            final millisecondsStr = match.group(3)!;
            // 处理两位或三位的毫秒数
            final milliseconds = millisecondsStr.length == 2
                ? int.parse(millisecondsStr) * 10
                : int.parse(millisecondsStr);

            // 将提取的时间转换为 Duration 对象
            final timestamp = Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            );

            // 创建一个 LyricLine 对象并添加到列表中
            lyrics.add(LyricLine(timestamp: timestamp, text: text));
          }
        }
      }
    }

    // 按时间戳对整个列表进行排序，确保歌词按时间顺序排列
    lyrics.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 返回解析并排序后的歌词列表
    return lyrics;
  }
}
