import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_common/byhy_assets_util.dart';
import '../../app_common/byhy_download_util.dart';
import '../by_widgets_util.dart';
import '../byhy_colors.dart';
import 'byhy_video_player_view.dart';

class VideoClipPreview extends StatefulWidget {
  final String videoFilePath;
  final String? title;
  final bool backToHme;

  const VideoClipPreview(
    this.videoFilePath, {
    super.key,
    this.title,
    this.backToHme = false,
  });

  @override
  State<VideoClipPreview> createState() => _VideoClipPreviewState();
}

class _VideoClipPreviewState extends State<VideoClipPreview> {
  _VideoClipPreviewState();
  bool exists = false;

  @override
  void initState() {
    _checkExists();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: widget.title ?? "我的预览",
          onPop: () {},
        ),
        backgroundColor: ByHyColorUtil.CommonPageBgColor,
        body: Column(
          children: [
            Expanded(
                key: UniqueKey(),
                child: Center(
                    child: VideoPlayerWidget(url: widget.videoFilePath))),
            SizedBox(height: 10.h),
            _bottomSettingWidget()
          ],
        ));
  }

  Widget _bottomSettingWidget() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: ByWidgetsUtil.commonBtn(
            title: "保存本地",
            fontSize: 14.sp,
            onClick: () async {
              if (exists) {
                BotToast.showText(text: "视频已保存到相册中");
                return;
              }
              final res = await ByDownloadUtil.saveVideoToAlbum(
                widget.videoFilePath,
                isToast: true,
              );
              if (res != null) {
                exists = true;
              }
            },
          ))
        ],
      ),
    );
  }

  void _checkExists() async {
    final assetSearch =
        await ByAssetsUtil.getAssetEntityByPath(widget.videoFilePath);
    if (assetSearch != null) {
      exists = true;
      return null;
    }
  }
}
