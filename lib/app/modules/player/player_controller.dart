// lib/app/modules/player/player_controller.dart
// 这是播放器模块的控制器 (Controller)。
// 它将负责管理播放器的所有状态和业务逻辑，
// 例如播放/暂停、切换歌曲、管理播放列表、更新进度条等。

import 'package:flutter/animation.dart';
import 'package:get/get.dart'; // 导入 GetX 包
import 'package:just_audio/just_audio.dart'; // 导入 just_audio 包
import '../../data/models/song_model.dart'; // 导入歌曲模型
import '../../data/models/lyric_model.dart'; // 导入歌词模型
import '../../data/providers/api_provider.dart'; // 导入 API Provider
import '../../shared/utils/lyric_parser.dart'; // 导入歌词解析器

// 定义播放模式的枚举
enum PlayMode { single, loop, shuffle }

// PlayerController 类继承自 GetxController，并混入 GetSingleTickerProviderStateMixin 以提供 Ticker
class PlayerController extends GetxController with GetSingleTickerProviderStateMixin {
  // --- 依赖注入 ---
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // --- 响应式状态变量 ---

  var isPlaying = false.obs;
  var currentSong = Rx<SongModel?>(null);
  var playlist = <SongModel>[].obs;
  var progress = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;
  var volume = 1.0.obs;
  var playMode = PlayMode.loop.obs;

  // 歌词相关状态
  var lyrics = <LyricLine>[].obs; // 解析后的歌词列表
  var currentLyricIndex = (-1).obs; // 当前高亮歌词的索引

  // just_audio 播放器实例
  final _audioPlayer = AudioPlayer();

  // 专辑封面旋转动画的控制器
  late final AnimationController albumArtAnimationController;

  @override
  void onInit() {
    super.onInit();
    albumArtAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _loadPlaylist();
    _listenToPlayerState();
    _listenToAnimation();
  }

  @override
  void onClose() {
    albumArtAnimationController.dispose();
    _audioPlayer.dispose();
    super.onClose();
  }

  // --- 逻辑方法 ---

  Future<void> _loadPlaylist() async {
    final fetchedPlaylist = await _apiProvider.getPlaylist();
    if (fetchedPlaylist != null && fetchedPlaylist.isNotEmpty) {
      playlist.assignAll(fetchedPlaylist);
      selectSong(playlist.first, autoPlay: false);
    }
  }

  void _listenToAnimation() {
    isPlaying.listen((playing) {
      if (playing) {
        albumArtAnimationController.repeat();
      } else {
        albumArtAnimationController.stop();
      }
    });
  }

  void _listenToPlayerState() {
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        nextSong();
      }
    });

    // 监听播放进度，并据此更新歌词
    _audioPlayer.positionStream.listen((p) {
      progress.value = p;
      _updateCurrentLyricIndex(p); // 根据新位置更新歌词索引
    });

    _audioPlayer.durationStream.listen((d) {
      totalDuration.value = d ?? Duration.zero;
    });
  }

  // 根据播放进度更新当前歌词行索引
  void _updateCurrentLyricIndex(Duration position) {
    if (lyrics.isEmpty) return;
    // 寻找第一个时间戳大于当前播放时间的歌词行
    final index = lyrics.indexWhere((line) => line.timestamp > position);
    if (index == -1) {
      // 如果没找到，说明是最后一行
      currentLyricIndex.value = lyrics.length - 1;
    } else if (index == 0) {
      // 如果是第一行之前
      currentLyricIndex.value = -1;
    } else {
      // 否则，当前行是找到行的前一行
      currentLyricIndex.value = index - 1;
    }
  }

  void playPause() {
    if (isPlaying.value) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void nextSong() {
    if (playlist.isEmpty || currentSong.value == null) return;
    int currentIndex = playlist.indexWhere((s) => s.id == currentSong.value!.id);
    if (currentIndex == -1) return;

    int nextIndex;
    switch(playMode.value) {
      case PlayMode.loop:
        nextIndex = (currentIndex + 1) % playlist.length;
        break;
      case PlayMode.shuffle:
        nextIndex = (currentIndex + 1 + Get.find<SecureRandom>().nextInt(playlist.length -1)) % playlist.length;
        if(nextIndex == currentIndex && playlist.length > 1) {
          nextIndex = (nextIndex + 1) % playlist.length;
        }
        break;
      case PlayMode.single:
        nextIndex = currentIndex;
        break;
    }
    selectSong(playlist[nextIndex]);
  }

  void previousSong() {
    if (playlist.isEmpty || currentSong.value == null) return;
    int currentIndex = playlist.indexWhere((s) => s.id == currentSong.value!.id);
    if (currentIndex == -1) return;

    int prevIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    selectSong(playlist[prevIndex]);
  }

  Future<void> selectSong(SongModel song, {bool autoPlay = true}) async {
    currentSong.value = song;
    albumArtAnimationController.reset();

    // 解析歌词
    if (song.lyrics != null && song.lyrics!.isNotEmpty) {
      lyrics.value = LyricParser.parse(song.lyrics!);
    } else {
      lyrics.clear();
    }
    currentLyricIndex.value = -1; // 重置歌词索引

    try {
      await _audioPlayer.setUrl(song.audioUrl);
      if (autoPlay) {
        _audioPlayer.play();
      }
    } catch (e) {
      print("Error setting audio source: $e");
      Get.snackbar('播放错误', '无法加载该歌曲');
    }
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void changeVolume(double newVolume) {
    volume.value = newVolume;
    _audioPlayer.setVolume(newVolume);
  }

  void togglePlayMode() {
    switch (playMode.value) {
      case PlayMode.loop:
        playMode.value = PlayMode.single;
        Get.snackbar('播放模式', '单曲循环');
        break;
      case PlayMode.single:
        playMode.value = PlayMode.shuffle;
        Get.snackbar('播放模式', '随机播放');
        break;
      case PlayMode.shuffle:
        playMode.value = PlayMode.loop;
        Get.snackbar('播放模式', '列表循环');
        break;
    }
  }
}

// 需要一个 SecureRandom 的实现来支持随机播放
import 'dart:math';
class SecureRandom implements Random {
  final Random _secureRandom = Random.secure();
  @override
  bool nextBool() => _secureRandom.nextBool();
  @override
  double nextDouble() => _secureRandom.nextDouble();
  @override
  int nextInt(int max) => _secureRandom.nextInt(max);
}
