// lib/app/data/models/song_model.dart
// 该文件定义了歌曲的数据模型 (SongModel)。
// 这个模型将用于表示播放列表中的单个歌曲及其相关信息。

class SongModel {
  final String id; // 歌曲的唯一ID
  final String title; // 歌曲标题
  final String artist; // 艺术家/歌手名称
  final String albumArtUrl; // 专辑封面图片的URL
  final String audioUrl; // 歌曲音频文件的URL
  final Duration duration; // 歌曲的总时长
  final String? lyrics; // 歌词字符串，通常是 LRC 格式

  // SongModel 的构造函数
  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
    required this.audioUrl,
    required this.duration,
    this.lyrics, // 歌词是可选的
  });

  // (可选) 工厂构造函数：从 JSON 对象创建 SongModel 实例
  // 当从 API 获取歌曲列表时会非常有用。
  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      albumArtUrl: json['albumArtUrl'] as String,
      audioUrl: json['audioUrl'] as String,
      duration: Duration(seconds: json['durationInSeconds'] as int? ?? 0),
      lyrics: json['lyrics'] as String?,
    );
  }

  // (可选) 方法：将 SongModel 实例转换为 JSON 对象
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumArtUrl': albumArtUrl,
      'audioUrl': audioUrl,
      'durationInSeconds': duration.inSeconds,
      'lyrics': lyrics,
    };
  }

  // (可选) 格式化时长为 "mm:ss" 格式的字符串，方便UI显示
  String get formattedDuration {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // (可选) 重写 toString 方法，方便调试
  @override
  String toString() {
    return 'SongModel(id: $id, title: "$title", artist: "$artist")';
  }
}
