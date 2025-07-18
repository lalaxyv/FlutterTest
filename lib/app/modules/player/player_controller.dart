// lib/app/modules/player/player_controller.dart
// 这是播放器模块的控制器 (Controller)。
// 它将负责管理播放器的所有状态和业务逻辑，
// 例如播放/暂停、切换歌曲、管理播放列表、更新进度条等。

import 'package:flutter/animation.dart';
import 'package:get/get.dart'; // 导入 GetX 包
import 'package:just_audio/just_audio.dart'; // 导入 just_audio 包
import '../../data/models/song_model.dart'; // 导入歌曲模型
import '../../data/providers/api_provider.dart'; // 导入 API Provider

// 定义播放模式的枚举
enum PlayMode { single, loop, shuffle }

// PlayerController 类继承自 GetxController，并混入 GetSingleTickerProviderStateMixin 以提供 Ticker
class PlayerController extends GetxController with GetSingleTickerProviderStateMixin {
  // --- 依赖注入 ---
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // --- 响应式状态变量 ---

  // 播放器是否正在播放
  var isPlaying = false.obs;
  // 当前播放的歌曲，可能为空
  var currentSong = Rx<SongModel?>(null);
  // 播放列表
  var playlist = <SongModel>[].obs;
  // 播放进度
  var progress = Duration.zero.obs;
  // 歌曲总时长
  var totalDuration = Duration.zero.obs;
  // 音量大小 (0.0 到 1.0)
  var volume = 1.0.obs;
  // 播放模式
  var playMode = PlayMode.loop.obs;

  // just_audio 播放器实例
  final _audioPlayer = AudioPlayer();

  // 专辑封面旋转动画的控制器
  late final AnimationController albumArtAnimationController;

  // onInit 是 GetxController 的生命周期方法，在控制器初始化时调用。
  @override
  void onInit() {
    super.onInit(); // 调用父类的 onInit 方法

    // 初始化动画控制器
    albumArtAnimationController = AnimationController(
      vsync: this, // 使用 GetSingleTickerProviderStateMixin 提供的 Ticker
      duration: const Duration(seconds: 20), // 旋转一周的时间
    );

    _loadPlaylist(); // 从 ApiProvider 加载播放列表
    _listenToPlayerState(); // 监听播放器状态变化
    _listenToAnimation(); // 监听播放状态以控制动画
  }

  // onClose 是 GetxController 的生命周期方法，在控制器销毁前调用。
  @override
  void onClose() {
    albumArtAnimationController.dispose(); // 销毁动画控制器
    _audioPlayer.dispose(); // 释放音频播放器资源
    super.onClose(); // 调用父类的 onClose 方法
  }

  // --- 逻辑方法 ---

  // 从 ApiProvider 加载播放列表数据
  Future<void> _loadPlaylist() async {
    final List<SongModel>? fetchedPlaylist = await _apiProvider.getPlaylist();
    if (fetchedPlaylist != null && fetchedPlaylist.isNotEmpty) {
      playlist.assignAll(fetchedPlaylist);
      // 默认加载第一首歌，但不自动播放
      selectSong(playlist.first, autoPlay: false);
    }
  }

  // 监听播放状态以控制封面旋转动画
  void _listenToAnimation() {
    isPlaying.listen((playing) {
      if (playing) {
        albumArtAnimationController.repeat(); // 如果在播放，则重复动画
      } else {
        albumArtAnimationController.stop(); // 如果暂停，则停止动画
      }
    });
  }

  // 监听播放器状态
  void _listenToPlayerState() {
    // 监听播放状态 (playing, paused, completed)
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        // 播放完成后，根据播放模式决定下一首
        nextSong();
      }
    });

    // 监听播放进度
    _audioPlayer.positionStream.listen((p) {
      progress.value = p;
    });

    // 监听歌曲总时长
    _audioPlayer.durationStream.listen((d) {
      totalDuration.value = d ?? Duration.zero;
    });
  }

  // 播放/暂停
  void playPause() {
    if (isPlaying.value) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  // 切换到下一首
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
        nextIndex = currentIndex; // 单曲循环，保持当前索引
        break;
    }
    selectSong(playlist[nextIndex]);
  }

  // 切换到上一首
  void previousSong() {
    if (playlist.isEmpty || currentSong.value == null) return;
    int currentIndex = playlist.indexWhere((s) => s.id == currentSong.value!.id);
    if (currentIndex == -1) return;

    int prevIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    selectSong(playlist[prevIndex]);
  }

  // 从播放列表选择一首歌
  Future<void> selectSong(SongModel song, {bool autoPlay = true}) async {
    currentSong.value = song;
    albumArtAnimationController.reset(); // 切换歌曲时重置动画
    try {
      // 从 URL 设置音频源
      await _audioPlayer.setUrl(song.audioUrl);
      if (autoPlay) {
        _audioPlayer.play();
      }
    } catch (e) {
      print("Error setting audio source: $e");
      Get.snackbar('播放错误', '无法加载该歌曲');
    }
  }

  // 拖动进度条
  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  // 改变音量
  void changeVolume(double newVolume) {
    volume.value = newVolume;
    _audioPlayer.setVolume(newVolume);
  }

  // 切换播放模式
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
import 'dart.math';
class SecureRandom implements Random {
  final Random _secureRandom = Random.secure();
  @override
  bool nextBool() => _secureRandom.nextBool();
  @override
  double nextDouble() => _secureRandom.nextDouble();
  @override
  int nextInt(int max) => _secureRandom.nextInt(max);
}
