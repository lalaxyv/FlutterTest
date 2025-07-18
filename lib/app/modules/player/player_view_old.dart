// lib/app/modules/player/player_view.dart
// 这是播放器模块的视图 (View)。
// 它负责展示播放器的 UI 界面，并将用户的交互事件传递给控制器。

import 'dart:ui'; // 导入 dart:ui 以使用 ImageFilter
import 'package:flutter/material.dart'; // 导入 Flutter 的 Material UI 包
import 'package:get/get.dart'; // 导入 GetX 包

import './player_controller.dart'; // 导入当前模块的控制器
import '../../data/models/song_model.dart'; // 导入歌曲模型

// PlayerView 类继承自 GetView<PlayerController>，方便访问控制器。
class PlayerOldView extends GetView<PlayerController> {
  const PlayerOldView({Key? key}) : super(key: key);

  // build 方法描述了如何构建这个 Widget 的 UI
  @override
  Widget build(BuildContext context) {
    // 使用 Scaffold 作为页面的基本骨架
    return Scaffold(
      // 使用 Stack 布局来叠加背景和播放器内容
      body: Stack(
        children: [
          // 1. 背景层: 一个覆盖整个屏幕的线性渐变
          _buildBackground(),

          // 2. 内容层: 播放器的所有 UI 元素
          SafeArea(
            // 使用 SafeArea 避免内容与系统 UI (如状态栏) 重叠
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Column(
                children: [
                  // 自定义 AppBar/Header
                  _buildPlayerHeader(),
                  const SizedBox(height: 30),

                  // 专辑封面
                  _buildAlbumArt(),
                  const SizedBox(height: 40),

                  // 歌曲信息
                  _buildSongInfo(),
                  const SizedBox(height: 20),

                  // 进度条
                  _buildProgressBar(),
                  const SizedBox(height: 20),

                  // 控制按钮
                  _buildControls(),
                  const SizedBox(height: 20),

                  // 音量控制和模式切换
                  _buildExtraControls(),
                  const SizedBox(height: 20),

                  // 播放列表切换按钮
                  _buildPlaylistToggle(),

                  // 播放列表
                  _buildPlaylist(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 私有辅助方法，用于构建背景
  Widget _buildBackground() {
    return Container(
      // 设置 decoration 来实现渐变背景
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)], // 对应 HTML 中的颜色
          begin: Alignment.topLeft, // 渐变开始于左上角
          end: Alignment.bottomRight, // 渐变结束于右下角
        ),
      ),
    );
  }

  // 私有辅助方法，用于构建播放器的头部
  Widget _buildPlayerHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
        const Text(
          '正在播放',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: Colors.white70),
          onPressed: () {},
        ),
      ],
    );
  }

  // 私有辅助方法，用于构建专辑封面
  Widget _buildAlbumArt() {
    // TODO: 将来用 RotationTransition 和 AnimationController 实现旋转动画
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: ClipOval(
        // TODO: 使用 Obx 监听 controller.currentSong.value?.albumArtUrl 并显示 NetworkImage
        child: Container(
          // 临时的占位符
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              '♪',
              style: TextStyle(fontSize: 80, color: Colors.white.withOpacity(0.6)),
            ),
          ),
        ),
      ),
    );
  }

  // 私有辅助方法，用于构建歌曲信息部分
  Widget _buildSongInfo() {
    return Obx(() => Column(
          children: [
            Text(
              controller.currentSong.value?.title ?? '未知歌曲',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              controller.currentSong.value?.artist ?? '未知艺术家',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
            ),
          ],
        ));
  }

  // 私有辅助方法，用于构建进度条部分
  Widget _buildProgressBar() {
    return Obx(() {
      final position = controller.progress.value;
      final total = controller.totalDuration.value;

      String formatDuration(Duration d) {
        if (d.inHours > 0) return d.toString().split('.').first.padLeft(8, "0");
        return d.toString().split('.').first.substring(2).padLeft(5, "0");
      }

      return Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              trackHeight: 4.0,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
              thumbColor: Colors.white,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              min: 0.0,
              max: total.inSeconds.toDouble() + 0.1, // +0.1 避免 max <= min 的错误
              value: position.inSeconds.toDouble().clamp(0.0, total.inSeconds.toDouble()),
              onChanged: (value) {
                controller.seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatDuration(position), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                Text(formatDuration(total), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),
        ],
      );
    });
  }

  // 私有辅助方法，用于构建控制按钮
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 35),
          onPressed: controller.previousSong,
        ),
        Obx(() => Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.9),
              ),
              child: IconButton(
                icon: Icon(
                  controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: const Color(0xFF6A61A2),
                  size: 45,
                ),
                onPressed: controller.playPause,
              ),
            )),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 35),
          onPressed: controller.nextSong,
        ),
      ],
    );
  }

  // 私有辅助方法，用于构建音量和模式控制
  Widget _buildExtraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.favorite_border_rounded, color: Colors.white70),
          onPressed: () {},
        ),
        Obx(() {
          IconData modeIcon;
          switch (controller.playMode.value) {
            case PlayMode.loop:
              modeIcon = Icons.repeat_rounded;
              break;
            case PlayMode.single:
              modeIcon = Icons.repeat_one_rounded;
              break;
            case PlayMode.shuffle:
              modeIcon = Icons.shuffle_rounded;
              break;
          }
          return IconButton(
            icon: Icon(modeIcon, color: Colors.white),
            onPressed: controller.togglePlayMode,
          );
        }),
      ],
    );
  }

  // 私有辅助方法，用于构建播放列表切换按钮
  Widget _buildPlaylistToggle() {
    return TextButton.icon(
      icon: const Icon(Icons.queue_music_rounded, color: Colors.white70),
      label: const Text("播放列表", style: TextStyle(color: Colors.white70)),
      onPressed: controller.togglePlaylistVisibility,
    );
  }

  // 私有辅助方法，用于构建播放列表
  Widget _buildPlaylist() {
    return Obx(() => AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: controller.isPlaylistVisible.value
              ? Container(
                  height: 200, // 给一个固定高度
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Obx(() => ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: controller.playlist.length,
                        itemBuilder: (context, index) {
                          final song = controller.playlist[index];
                          final bool isActive = controller.currentSong.value?.id == song.id;
                          return ListTile(
                            title: Text(song.title,
                                style:
                                    TextStyle(color: isActive ? Colors.amberAccent : Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                                maxLines: 1),
                            subtitle: Text(song.artist, style: TextStyle(color: Colors.white.withOpacity(0.7))),
                            trailing: Text(song.formattedDuration, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                            onTap: () => controller.selectSong(song),
                            selected: isActive,
                            selectedTileColor: Colors.white.withOpacity(0.15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          );
                        },
                      )),
                )
              : const SizedBox.shrink(),
        ));
  }
}
