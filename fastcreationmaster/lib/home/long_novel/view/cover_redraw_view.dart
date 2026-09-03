/*
 * @Author: cold-x
 * @Date: 2025-09-08 17:41:47
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-09 18:10:46
 * @FilePath: /fastcreationmaster/lib/home/long_novel/view/cover_redraw_view.dart
 * @Description: 
 */

import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/network/novel_apis.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../../core/widget/view/by_button.dart';
import '../../../core/widget/view/loading_dialog.dart';
import '../../../global/ui/colors.dart';
import '../bean/novel_cover_model.dart';

class CoverRedrawView extends StatefulWidget {
  CoverRedrawView({
    super.key,
    required this.cover,
    this.redrawAction,
    this.saveAction,
    required this.id,
    required this.module,
  });
  final String cover;

  ///封面图
  final void Function()? redrawAction;

  ///重绘
  final void Function()? saveAction;

  ///使用保存

  final int id;

  ///小说id
  final String module;

  final userController = Get.find<UserController>();

  ///功能模块

  @override
  State<CoverRedrawView> createState() => _CoverRedrawViewState();
}

class _CoverRedrawViewState extends State<CoverRedrawView> {
  ///是否正在生成中
  bool isRedrawing = false;

  ///封面列表集合
  List<NovelCoverItem> dataList = [];

  ///封面列表的视图集合
  List<Widget> dataListView = [];

  ///当前选中的封面索引
  int currentIndex = 1;

  int initialPage = 0;

  ///重绘次数
  int redrawCount = 0;

  /// 定时器对象
  Timer? _timer;

  /// 轮播组件的key，用于强制重建
  GlobalKey _carouselKey = GlobalKey();

  /// 是否正在显示新添加的生成中项
  bool _isShowingNewGeneratingItem = false;

  // "audit": 1, //审核状态 0.审核中, 1.通过 2.未过
// "status": 1, //生成状态 0.生成中, 1.成功 2.失败

  /// 根据状态获取对应的状态信息
  Map<String, dynamic> getStatusInfo(NovelCoverItem item) {
    // 优先判断生成状态
    if (item.status == 0) {
      return {
        'isGenerating': true,
        'showLoading': true,
        'text': '封面生成中，请稍等',
        'canSave': false,
      };
    } else if (item.status == 2) {
      return {
        'isGenerating': false,
        'showLoading': false,
        'text': '封面生成失败，请重新生成',
        'canSave': false,
      };
    } else if (item.status == 1) {
      // 生成成功，再判断审核状态
      if (item.audit == 0) {
        return {
          'isGenerating': false,
          'showLoading': false,
          'text': '封面审核中',
          'canSave': false,
        };
      } else if (item.audit == 2) {
        return {
          'isGenerating': false,
          'showLoading': false,
          'text': '封面审核未通过，请重新生成',
          'canSave': false,
        };
      } else if (item.audit == 1) {
        return {
          'isGenerating': false,
          'showLoading': false,
          'text': '封面已生成',
          'canSave': true,
        };
      }
    }

    // 默认状态
    return {
      'isGenerating': false,
      'showLoading': false,
      'text': '封面状态未知',
      'canSave': false,
    };
  }

  ///封面集合
  getCoverList() {
    HttpUtils.get(
      NovelApis.getCoverList,
      {
        "module": widget.module,
        "id": widget.id,
      },
      success: (data) {
        try {
          // 安全地处理 max_num 的类型转换
          var maxNum = data['data']?['max_num'];
          if (maxNum is String) {
            redrawCount = int.tryParse(maxNum) ?? 0;
          } else if (maxNum is int) {
            redrawCount = maxNum;
          } else {
            redrawCount = 0;
          }

          NovelCoverResponse novelCoverResponse =
              NovelCoverResponse.fromJson(data);
          if (novelCoverResponse.data?.list != null) {
            dataList.addAll(novelCoverResponse.data!.list!);
          }
          Get.log("获取封面集合 novel/novel/getCoverList=====>$data");
        } catch (e) {
          Get.log("获取封面集合失败: $e");
          redrawCount = 0;
        }

        // 检查是否有生成中的封面（status == 0）
        bool hasGenerating = false;
        if (dataList.isNotEmpty) {
          for (var e in dataList) {
            if (e.status == 0) {
              hasGenerating = true;
              break;
            }
          }
        }

        // 根据是否有生成中的封面来设置isRedrawing状态
        isRedrawing = hasGenerating;

        if (dataList.isNotEmpty) {
          for (var e in dataList) {
            var statusInfo = getStatusInfo(e);
            dataListView.add(
              Stack(
                children: [
                  // 检查URL是否有效，如果无效则显示占位图
                  (e.coverUrl != null && e.coverUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          fit: BoxFit.fitHeight,
                          width: double.infinity,
                          imageUrl: e.coverUrl!,
                          height: 500,
                          placeholder: (context, url) => Container(
                            height: 500,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/home/novel/icon_novel_redraw_cover_bg.png')),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : Container(
                          height: 500,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                                image: AssetImage(
                                    'assets/home/novel/icon_novel_redraw_cover_bg.png')),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: statusInfo['showLoading'] ||
                                  statusInfo['text'] != '封面已生成'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (statusInfo['showLoading']) ...[
                                      const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CupertinoActivityIndicator(
                                          color: ByColorUtil.colorC1,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    ByWidgetsUtil.commonText(
                                        text: statusInfo['text'],
                                        textColor: ByColorUtil.colorF1)
                                  ],
                                )
                              : null,
                        ),
                  Positioned(
                      left: 12,
                      bottom: 12,
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/global/common/icon_novel_warning_gray.png',
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          ByWidgetsUtil.commonText(
                              textColor: ByColorUtil.colorF1.withOpacity(0.6),
                              text: '内容由AI生成'),
                        ],
                      ))
                ],
              ),
            );
          }

          // 如果有生成中的封面，定位到最后一个（生成中的那一个）
          if (hasGenerating) {
            initialPage = dataList.length - 1;
            currentIndex = dataList.length;
          } else {
            // 如果没有生成中的封面，定位到选中的封面
            for (var e in dataList) {
              if (e.selected == true) {
                initialPage = dataList.indexOf(e);
                currentIndex = initialPage + 1;
                break;
              }
            }
          }
        }
        if (mounted) {
          setState(() {});
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getCoverList();
    startTimer();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  ///重新绘图
  void redraw() {
    if (isRedrawing) {
      BotToast.showText(text: "封面生成中，请稍等～");
      return;
    }
    HttpUtils.post(
      NovelApis.generateCover,
      {
        "module": widget.module,
        "id": widget.id,
      },
      success: (data) {
        Get.log("重新绘图 novel/novel/generateCover=====>$data");
        if (mounted) {
          setState(() {});
          isRedrawing = true;

          // 创建一个临时的生成中封面项
          var generatingItem = NovelCoverItem(
            id: 0, // 临时ID
            type: 1,
            audit: 0,
            status: 0, // 生成中
            coverUrl: "",
            selected: false,
          );

          // 添加到数据列表
          dataList.add(generatingItem);

          // 重新构建视图列表
          dataListView = [];
          for (var e in dataList) {
            var statusInfo = getStatusInfo(e);
            dataListView.add(
              Stack(
                children: [
                  // 检查URL是否有效，如果无效则显示占位图
                  (e.coverUrl != null && e.coverUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          fit: BoxFit.fitHeight,
                          width: double.infinity,
                          imageUrl: e.coverUrl!,
                          height: 500,
                          placeholder: (context, url) => Container(
                            height: 500,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/home/novel/icon_novel_redraw_cover_bg.png')),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : Container(
                          height: 500,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                                image: AssetImage(
                                    'assets/home/novel/icon_novel_redraw_cover_bg.png')),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: statusInfo['showLoading'] ||
                                  statusInfo['text'] != '封面已生成'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (statusInfo['showLoading']) ...[
                                      const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CupertinoActivityIndicator(
                                          color: ByColorUtil.colorC1,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    ByWidgetsUtil.commonText(
                                        text: statusInfo['text'],
                                        textColor: ByColorUtil.colorF1)
                                  ],
                                )
                              : null,
                        ),
                  Positioned(
                      left: 12,
                      bottom: 12,
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/global/common/icon_novel_warning_gray.png',
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          ByWidgetsUtil.commonText(
                              textColor: ByColorUtil.colorF1.withOpacity(0.6),
                              text: '内容由AI生成'),
                        ],
                      ))
                ],
              ),
            );
          }

          // 定位到生成中状态的那一项（最后一项）
          initialPage = dataListView.length - 1;
          currentIndex = dataListView.length;
          _isShowingNewGeneratingItem = true;

          // 立即更新UI，然后延迟重建轮播组件
          setState(() {});

          // 延迟更新轮播组件，确保数据完全更新后再重建
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              _carouselKey = GlobalKey();
              setState(() {});
            }
          });
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///滚动列表区域
  Widget _buildListView() {
    if (dataListView.isNotEmpty) {
      return CarouselSlider(
          key: _carouselKey,
          items: dataListView,
          options: CarouselOptions(
            height: 500,
            enlargeCenterPage: false,
            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
            enlargeFactor: 0.3,
            initialPage: _isShowingNewGeneratingItem
                ? dataListView.length - 1
                : initialPage,
            viewportFraction: 1.0,
            enableInfiniteScroll:
                !_isShowingNewGeneratingItem, // 在显示新生成项时禁用无限滚动
            reverse: false,
            autoPlay: false,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              Get.log("移动===$index  ");
              if (mounted) {
                setState(() {
                  currentIndex = index + 1;
                  // 如果用户手动滑动，取消显示新生成项的状态
                  if (_isShowingNewGeneratingItem &&
                      reason == CarouselPageChangedReason.manual) {
                    _isShowingNewGeneratingItem = false;
                  }
                });
              }
            },
            scrollDirection: Axis.horizontal,
          ));
    }
    return SizedBox();
  }

  ///重命名小说
  void saveCover(
    String cover,
    String id,
  ) {
    LoadingDialog().show(message: '保存图片中...');
    HttpUtils.post(
      NovelApis.editNovelInfo,
      {
        'id': id,
        'cover': cover,
      },
      success: (data) {
        Get.log("保存封面成功的数据===> $data");
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          BotToast.showText(text: '保存成功');
          eventBus.fire(const SaveCoverEvent());
          Get.back();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (isRedrawing) {
        queryCoverList();
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  queryCoverList() {
    HttpUtils.get(
      NovelApis.getCoverList,
      {
        "module": widget.module,
        "id": widget.id,
      },
      success: (data) {
        Get.log("查询封面集合 novel/novel/getCoverList=====>$data");
        List<NovelCoverItem> newDataList = [];
        NovelCoverResponse novelCoverResponse =
            NovelCoverResponse.fromJson(data);
        if (novelCoverResponse.data?.list != null) {
          newDataList.addAll(novelCoverResponse.data!.list!);
        }

        // 检查是否有生成中的封面（status == 0）
        bool hasGenerating = false;
        if (newDataList.isNotEmpty) {
          for (var e in newDataList) {
            if (e.status == 0) {
              hasGenerating = true;
              break;
            }
          }
        }

        // 根据是否有生成中的封面来设置isRedrawing状态
        isRedrawing = hasGenerating;

        if (newDataList.isNotEmpty) {
          // 更新数据列表，确保数据同步
          Get.log(
              "轮询更新数据 - 更新前dataList长度: ${dataList.length}, 新数据长度: ${newDataList.length}, 当前currentIndex: $currentIndex");
          dataList = newDataList;
          dataListView = [];
          for (var e in newDataList) {
            var statusInfo = getStatusInfo(e);
            dataListView.add(
              Stack(
                children: [
                  // 检查URL是否有效，如果无效则显示占位图
                  (e.coverUrl != null && e.coverUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          fit: BoxFit.fitHeight,
                          width: double.infinity,
                          imageUrl: e.coverUrl!,
                          height: 500,
                          placeholder: (context, url) => Container(
                            height: 500,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/home/novel/icon_novel_redraw_cover_bg.png')),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : Container(
                          height: 500,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                                image: AssetImage(
                                    'assets/home/novel/icon_novel_redraw_cover_bg.png')),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: statusInfo['showLoading'] ||
                                  statusInfo['text'] != '封面已生成'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (statusInfo['showLoading']) ...[
                                      const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CupertinoActivityIndicator(
                                          color: ByColorUtil.colorC1,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    ByWidgetsUtil.commonText(
                                        text: statusInfo['text'],
                                        textColor: ByColorUtil.colorF1)
                                  ],
                                )
                              : null,
                        ),
                  Positioned(
                      left: 12,
                      bottom: 12,
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/global/common/icon_novel_warning_gray.png',
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          ByWidgetsUtil.commonText(
                              textColor: ByColorUtil.colorF1.withOpacity(0.6),
                              text: '内容由AI生成'),
                        ],
                      ))
                ],
              ),
            );
          }

          // 如果有生成中的封面，定位到最后一个（生成中的那一个）
          if (hasGenerating) {
            initialPage = newDataList.length - 1;
            currentIndex = newDataList.length;
            _isShowingNewGeneratingItem = true;
            Get.log(
                "检测到生成中的封面，定位到: initialPage=$initialPage, currentIndex=$currentIndex");
          } else {
            _isShowingNewGeneratingItem = false;
            // 如果没有生成中的封面，需要判断是否应该保持用户选择
            // 如果用户当前选择的是失败状态的封面，保持用户选择
            // 否则定位到选中的封面
            bool shouldKeepUserSelection = false;
            if (currentIndex > 0 && currentIndex <= newDataList.length) {
              var currentItem = newDataList[currentIndex - 1];
              var statusInfo = getStatusInfo(currentItem);
              // 如果当前项不能保存（失败、审核中等），保持用户选择
              shouldKeepUserSelection = !statusInfo['canSave'];
            }

            if (shouldKeepUserSelection) {
              // 保持用户当前的选择
              initialPage = currentIndex - 1;
            } else {
              // 检查当前用户正在查看的封面是否已经生成成功
              if (currentIndex > 0 && currentIndex <= newDataList.length) {
                var currentItem = newDataList[currentIndex - 1];
                var statusInfo = getStatusInfo(currentItem);
                // 如果当前查看的封面已经生成成功且可以保存，保持用户选择
                if (statusInfo['canSave']) {
                  initialPage = currentIndex - 1;
                  // 不需要修改 currentIndex，保持用户当前的选择
                } else {
                  // 如果当前封面不能保存，则定位到选中的封面
                  for (var e in newDataList) {
                    if (e.selected == true) {
                      initialPage = newDataList.indexOf(e);
                      currentIndex = initialPage + 1;
                      break;
                    }
                  }
                }
              } else {
                // 定位到选中的封面
                for (var e in newDataList) {
                  if (e.selected == true) {
                    initialPage = newDataList.indexOf(e);
                    currentIndex = initialPage + 1;
                    break;
                  }
                }
              }
            }
          }
          Get.log(
              "轮询更新后 - currentIndex: $currentIndex, initialPage: $initialPage, 数据长度: ${newDataList.length}");
        }

        if (mounted) {
          setState(() {});
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Container(
      color: ByColorUtil.colorBg1,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildListView(),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 56,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                color: ByColorUtil.colorBg1,
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: isRedrawing ? 0.5 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: ByButton.grandiantVIPBtn(
                          // title: '重新绘图($currentIndex/${dataListView.length})',
                          title:
                              '重新绘图(${dataListView.isNotEmpty ? redrawCount - (dataListView.length - 1) : 0}/$redrawCount)',
                          onClick: () {
                            userController.checkPreLogin(
                                source: 'cover_redraw',
                                actionCallback: () {
                                  ///非vip点击跳转付费页
                                  if (userController
                                          .userInfoBean.value?.isVip ==
                                      0) {
                                    userController.jumpToPayPage(
                                        source: 'cover_redraw');
                                    return;
                                  }

                                  ///次数不足，文案提示
                                  if (dataListView.length - 1 >= redrawCount) {
                                    BotToast.showText(text: "重绘次数已用完！");
                                    return;
                                  }
                                  redraw();
                                });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: (isRedrawing &&
                                currentIndex == (dataListView.length))
                            ? 0.5
                            : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          height: 48,
                          child: ByButton.gradientBtn(
                              padding: EdgeInsets.zero,
                              title: '保存',
                              textColor: ByColorUtil.colorF8,
                              onClick: () {
                                if (currentIndex > 0 &&
                                    currentIndex <= dataList.length) {
                                  var currentItem = dataList[currentIndex - 1];
                                  var statusInfo = getStatusInfo(currentItem);

                                  // 确保当前项的状态信息是最新的
                                  print(
                                      "保存按钮点击 -id: ${currentItem.id}, currentIndex: $currentIndex, 当前项状态: ${currentItem.status}, 审核状态: ${currentItem.audit}");

                                  if (statusInfo['canSave']) {
                                    saveCover(currentItem.coverUrl ?? "",
                                        widget.id.toString());
                                  } else {
                                    BotToast.showText(text: statusInfo['text']);
                                  }
                                } else {
                                  BotToast.showText(text: "请选择有效的封面");
                                }
                              }),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          //关闭按钮
          Positioned(
            left: 12,
            top: ByScreenUtils.topSafeHeight,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ByColorUtil.colorF8.withOpacity(0.3)),
                child: Image.asset(
                  "assets/global/common/btn_close.png",
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SaveCoverEvent {
  const SaveCoverEvent();
}
