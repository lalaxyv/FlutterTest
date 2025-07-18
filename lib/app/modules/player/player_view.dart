// lib/app/modules/player/player_view.dart
// 这是播放器模块的视图 (View)。
// 它负责展示播放器的 UI 界面，并将用户的交互事件传递给控制器。

import 'dart:ui'; // 导入 dart:ui 以使用 ImageFilter
import 'package:flutter/material.dart'; // 导入 Flutter 的 Material UI 包
import 'package:get/get.dart'; // 导入 GetX 包

import './player_controller.dart'; // 导入当前模块的控制器
import '../../data/models/song_model.dart'; // 导入歌曲模型

// PlayerView 类继承自 GetView<PlayerController>，方便访问控制器。
class PlayerView extends GetView<PlayerController> {
  const PlayerView({Key? key}) : super(key: key);

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

          // 2. 主内容层
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Column(
                children: [
                  _buildPlayerHeader(),
                  const SizedBox(height: 20),
                  _buildAlbumArt(),
                  const SizedBox(height: 30),
                  _buildSongInfo(),
                  const SizedBox(height: 20),
                  // 歌词视图
                  _buildLyricsView(),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // 3. 底部控制面板
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControlsPanel(),
          ),
        ],
      ),
    );
  }

  // --- 辅助构建方法 ---

  // 构建背景
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // 构建播放器的头部
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

  // 构建专辑封面
  Widget _buildAlbumArt() {
    return RotationTransition(
      turns: controller.albumArtAnimationController,
      child: Container(
        width: 220, // 缩小封面尺寸为歌词留出空间
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
        child: Obx(() => ClipOval(
          child: Image.network(
            controller.currentSong.value?.albumArtUrl ?? '',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
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
                    style: TextStyle(fontSize: 100, color: Colors.white.withOpacity(0.6)),
                  ),
                ),
              );
            },
          ),
        )),
      ),
    );
  }

  // 构建歌曲信息部分
  Widget _buildSongInfo() {
    return Obx(() => Column(
      children: [
        Text(
          controller.currentSong.value?.title ?? '未知歌曲',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          controller.currentSong.value?.artist ?? '未知艺术家',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15),
        ),
      ],
    ));
  }

  // 构建歌词视图
  Widget _buildLyricsView() {
    // 创建一个 ScrollController 用于控制歌词滚动
    final ScrollController scrollController = ScrollController();

    // 监听当前歌词行索引的变化，并滚动列表
    ever(controller.currentLyricIndex, (index) {
      if (index >= 0 && scrollController.hasClients) {
        final itemHeight = 50.0; // 假设每行歌词的高度约为50
        final position = index * itemHeight - (Get.height * 0.1); // 滚动到屏幕偏上的位置
        scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    return Expanded(
      child: Obx(() {
        if (controller.lyrics.isEmpty) {
          return Center(
            child: Text('暂无歌词', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          );
        }
        return ListView.builder(
          controller: scrollController,
          itemCount: controller.lyrics.length,
          itemBuilder: (context, index) {
            final line = controller.lyrics[index];
            final bool isCurrentLine = index == controller.currentLyricIndex.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                line.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isCurrentLine ? Colors.white : Colors.white.withOpacity(0.5),
                  fontSize: isCurrentLine ? 18 : 16,
                  fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // 构建底部的整个控制面板
  Widget _buildBottomControlsPanel() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProgressBar(),
              const SizedBox(height: 10),
              _buildControls(),
              const SizedBox(height: 10),
              _buildExtraControls(),
            ],
          ),
        ),
      ),
    );
  }

  // 构建进度条
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
              max: total.inSeconds.toDouble() + 0.1,
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

  // 构建主控制按钮
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 32),
          onPressed: controller.previousSong,
        ),
        Obx(() => Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.9),
              ),
              child: IconButton(
                icon: Icon(
                  controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: const Color(0xFF6A61A2),
                  size: 40,
                ),
                onPressed: controller.playPause,
              ),
            )),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
          onPressed: controller.nextSong,
        ),
      ],
    );
  }

  // 构建额外的控制按钮 (播放模式和列表)
  Widget _buildExtraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.favorite_border_rounded, color: Colors.white70, size: 22),
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
            icon: Icon(modeIcon, color: Colors.white, size: 22),
            onPressed: controller.togglePlayMode,
          );
        }),
        IconButton(
          icon: const Icon(Icons.queue_music_rounded, color: Colors.white70, size: 22),
          onPressed: () {
            Get.bottomSheet(
              _buildPlaylistSheet(),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            );
          },
        ),
      ],
    );
  }

  // 构建从底部弹出的播放列表
  Widget _buildPlaylistSheet() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  shrinkWrap: true,
                  itemCount: controller.playlist.length,
                  itemBuilder: (context, index) {
                    final song = controller.playlist[index];
                    final bool isActive = controller.currentSong.value?.id == song.id;
                    return ListTile(
                      title: Text(song.title, style: TextStyle(color: isActive ? Colors.amberAccent : Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal), maxLines: 1),
                      subtitle: Text(song.artist, style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      trailing: Text(song.formattedDuration, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      onTap: () {
                        controller.selectSong(song);
                        Get.back();
                      },
                      selected: isActive,
                      selectedTileColor: Colors.white.withOpacity(0.15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          )),
        ),
      ),
    );
  }
}
