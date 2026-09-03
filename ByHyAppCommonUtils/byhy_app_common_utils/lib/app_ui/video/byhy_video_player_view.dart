import 'dart:async';
import 'dart:io';
import 'package:byhy_app_common_utils/app_common/consts/assets_data.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_audio/byhy_audio_player.dart';
import '../../app_common/by_common_utils.dart';
import '../../app_common/byhy_download_util.dart';
import '../../app_common/event/common_event.dart';

///视频播放组件
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final String? coverUrl;
  final bool autoPlay;
  final int? offset;
  final bool userInteractive;
  final bool mute;
  final double? aspectRatio;
  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.offset,
    this.userInteractive = true,
    this.coverUrl,
    this.mute = false,
    this.aspectRatio,
  });

  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  CachedVideoPlayerPlusController? _cachedVideoPlayerPlusController;
  VideoPlayerController? _localController;
  late bool isPlaying = widget.autoPlay;

  changeMuteStatus(bool status) {
    _cachedVideoPlayerPlusController?.setVolume(status ? 0.0 : 1.0);
  }

  stopPlay() {
    _localController?.pause();
    _cachedVideoPlayerPlusController?.pause();
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  resumePlay() {
    _localController?.play();
    _cachedVideoPlayerPlusController?.play();
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  late StreamSubscription<PauseVideoEvent> streamSubscription;

  @override
  void initState() {
    super.initState();
    byDebugPrint("--------VideoPlayerWidgetState initState", tag: "播放的url:");

    /// 初始化远程视频控制器
    if (widget.url.startsWith("http")) {
      _cachedVideoPlayerPlusController =
          CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(widget.url),
      )..initialize().then(
              (_) async {
                _cachedVideoPlayerPlusController
                    ?.setVolume(widget.mute ? 0.0 : 1);

                await _cachedVideoPlayerPlusController!
                    .seekTo(Duration(seconds: widget.offset ?? 0));
                byDebugPrint(
                    "${_cachedVideoPlayerPlusController?.value.isInitialized}",
                    tag: "播放器初始化状态 in initState seekTo");
                _cachedVideoPlayerPlusController!.setLooping(true).then((_) {
                  byDebugPrint(
                      "${_cachedVideoPlayerPlusController?.value.isInitialized}",
                      tag: "播放器初始化状态 in initState setLooping");
                  setState(() {});
                  if (mounted) {
                    // 自动播放
                    widget.autoPlay
                        ? _cachedVideoPlayerPlusController?.play()
                        : _cachedVideoPlayerPlusController?.pause();
                  }
                });
              },
            );
    } else {
      // 初始化视频控制器
      _localController = VideoPlayerController.file(File(widget.url))
        ..initialize().then(
          (_) {
            _localController!
                // ..seekTo(Duration(seconds: widget.offset ?? 0))
                .setLooping(true)
                .then((_) async {
              if (mounted) {
                setState(() {});
                await _localController!
                    .seekTo(Duration(seconds: widget.offset ?? 0));
                // 自动播放
                // _localController?.pause();
                widget.autoPlay
                    ? _localController?.play()
                    : _localController?.pause();
              }
            });
          },
        );
    }

    streamSubscription = eventBus.on<PauseVideoEvent>().listen((event) {
      if (_cachedVideoPlayerPlusController != null) {
        _cachedVideoPlayerPlusController!.pause();
      }

      if (_localController != null) {
        _localController!.pause();
      }

      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    byDebugPrint("--------VideoPlayerWidgetState dispose", tag: "播放的url:");
    _cachedVideoPlayerPlusController?.dispose();
    _localController?.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    byDebugPrint("${_cachedVideoPlayerPlusController?.value.isInitialized}",
        tag: "播放器初始化状态 in build：");
    if (widget.url.startsWith("http")) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.userInteractive == false) return;

          if (ByAudioPlayer.sharedInstance.isPlaying) {
            ByAudioPlayer.sharedInstance.pause();
          }

          if (isPlaying) {
            _cachedVideoPlayerPlusController?.pause();
          } else {
            _cachedVideoPlayerPlusController?.play();
          }
          setState(() {
            isPlaying = !isPlaying;
          });
        },
        child: Stack(
          children: [
            Container(
              child: (_cachedVideoPlayerPlusController?.value.isInitialized ??
                      false)
                  ? AspectRatio(
                      aspectRatio: widget.aspectRatio ??
                          _cachedVideoPlayerPlusController!.value.aspectRatio,
                      // aspectRatio: 3/4,
                      child: CachedVideoPlayerPlus(
                        _cachedVideoPlayerPlusController!,
                      ),
                    )
                  : widget.coverUrl != null
                      ? CachedNetworkImage(imageUrl: widget.coverUrl!)
                      : ByWidgetsUtil.activityIndicator(),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: isPlaying,
                child: Center(
                  child: Image.asset(
                    AssetsData.iconVideoPlay,
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isPlaying) {
          _localController?.pause();
        } else {
          _localController?.play();
        }
        setState(() {
          isPlaying = !isPlaying;
        });
      },
      child: Stack(
        children: [
          Container(
            child: (_localController?.value.isInitialized ?? false)
                ? AspectRatio(
                    aspectRatio: _localController!.value.aspectRatio,
                    child: VideoPlayer(_localController!),
                  )
                : ByDownloadUtil.videoCover(widget.url),
          ),
          Positioned.fill(
            child: Offstage(
              offstage:
                  isPlaying || (_localController?.value.isInitialized == false),
              child: Center(
                child: Image.asset(
                  AssetsData.iconAudioPlay,
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
