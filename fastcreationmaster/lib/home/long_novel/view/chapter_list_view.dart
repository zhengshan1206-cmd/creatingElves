import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/home/long_novel/request/chapter_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/widget/view/by_button.dart';
import '../../../global/ui/colors.dart';
import '../bean/novel_chapter_bean.dart';
import 'novel_home_view.dart';

class ChapterListView extends StatelessWidget {
  ChapterListView(
      {super.key,
      this.action,
      this.length = 0,
      this.reverse = false,
      this.showReverse = true,
      this.reverseAction,
      this.retry,
      this.itemList});

  ///小说正文
  final List<ChapterBean>? itemList;

  ///事件action,当前章节数据与点击的序列号
  final Function(ChapterBean, int)? action;

  ///长度
  final int? length;

  ///正序与倒序
  final bool? reverse;

  ///是否显示正序倒序
  final bool? showReverse;

  ///正倒序action
  final Function(bool)? reverseAction;

  ///重新生成
  final Function()? retry;

  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return _buildChapterView();
  }

  ///生成章节目录
  Widget _buildChapterView() {
    return Container(
      decoration: BoxDecoration(
        color: ByColorUtil.colorBg2,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: SizedBox(
        height: showReverse! ? length! * 66.w + 45.w : length! * 66.w,
        child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: length! + 1,
            itemBuilder: (context, index) {
              ///目录header
              if (index == 0) {
                return showReverse! ? Container(
                    padding: EdgeInsets.only(left: 12.w),
                    height: 45.w,
                    child: Row(
                      children: [
                        ByWidgetsUtil.commonText(
                          text: '目录',
                          textColor: Colors.white,
                          fontSize: 15,
                        ),
                        const Spacer(),
                        ByButton.gradientImageBtn(
                              title: reverse! ? '正序' : '倒序',
                              bgColor: Colors.transparent,
                              textColor: ByColorUtil.colorC1,
                              fontSize: 13,
                              image:
                                  'assets/global/common/icon_switch_column.png',
                              onClick: () {
                                reverseAction?.call(!reverse!);
                              }),
                          
                      ],
                    )) : Container();
              }
              return ChapterListCell(
                bean: itemList![index - 1],
                action: () {
                  final int row = index - 1;
                  action?.call(itemList![row], row);
                },);
            },
            separatorBuilder: (context, index) {
              return index == 0
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Container(
                        height: 1,
                        decoration: const BoxDecoration(
                          color: Color(0xFF26272E),
                        ),
                      ),
                    );
            }),
      ),
    );
  }

  
}

class ChapterListCell extends StatefulWidget {
  const ChapterListCell({
    super.key,
    required this.bean,
    this.action});

  final ChapterBean bean;
  final Function()? action;

  @override
  State<ChapterListCell> createState() => _ChapterListCellState();
}

class _ChapterListCellState extends State<ChapterListCell> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildChapterCell();
  }

  ///章节cell
  Widget _buildChapterCell() {
    ChapterBean bean = widget.bean;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: 65.w,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.bean.stage == 7)
                    Image.asset(
                      'assets/global/common/icon_novel_warning.png',
                      width: 16.w,
                      height: 16.w,
                    ),
                  if (widget.bean.stage == 7)
                    SizedBox(
                      width: 4.w,
                    ),
                  ByWidgetsUtil.commonText(
                    text: '第${bean.index}章 ${bean.title}',
                    textColor: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ],
              ),
              SizedBox(
                height: 4.w,
              ),
              Row(
                children: [
                  ByWidgetsUtil.commonText(
                    text: '${bean.words ?? 0}字',
                    textColor: ByColorUtil.colorF2,
                    fontSize: 12,
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Container(
                    width: 1,
                    height: 12.w,
                    color: const Color(0x664D4E56),
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  ByWidgetsUtil.commonText(
                    text: bean.createTime ?? '',
                    textColor: ByColorUtil.colorF2,
                    fontSize: 12,
                  ),
                ],
              )
            ],
          ),
          const Spacer(),
          _chooseNovelInfoStatus(bean),
        ],
      ),
    );
  }

  _chooseNovelInfoStatus(ChapterBean bean) {
    switch (bean.stage) {
      ///生成失败
      case 7:
      case 8:
        return SizedBox(
          width: 72.w,
          height: 24.w,
          child: ByButton.gradientBtn(
              textColor: Colors.black,
              borderRadius: 12.w,
              padding: const EdgeInsets.all(0),
              title: '重新生成',
              fontSize: 12,
              onClick: () {
                ChapterRequest.retryChapter(
                  bean.novelID!, bean.id!,
                  onSuccess: () {
                    setState(() {
                      bean.stage = 5;
                    });
                  },
                );
              }),
        );

      ///生成中
      case 5:
        return GestureDetector(
            onTap: () => widget.action?.call(),
            child: const GenerateProgressView(
              progress: -1,
            ));

      ///等待生成
      case 1:
      case 2:
      case 3:
        return Container();
      case 4:
        return ByWidgetsUtil.commonText(
            textColor: ByColorUtil.colorF2, text: '等待生成中~');

      ///正常完成状态
      case 6:
        return SizedBox(
          width: 72.w,
          height: 24.w,
          child: ByButton.gradientBtn(
              bgColor: ByColorUtil.color2E3038,
              textColor: ByColorUtil.colorC1,
              borderRadius: 12.w,
              padding: const EdgeInsets.all(0),
              title: '立即查看',
              fontSize: 12,
              onClick: () {
                // userController.checkPreLogin(actionCallback: () {
                //   action?.call(bean, index);
                // });
                widget.action?.call();
              }),
        );
    }
  }
}
