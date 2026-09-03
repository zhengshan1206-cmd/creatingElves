


import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/other/illegal_words/bean/illegal_words_bean.dart';
import 'package:fast_creation_master/global/other/illegal_words/controller/illegal_words_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../ui/colors.dart';

// ignore: must_be_immutable
class IllegalWordsPage extends BasePage {
  IllegalWordsPage({
    super.key,});


  @override
  String get title => '违禁词';

  @override
  IllegalWordsController get controller => Get.find<IllegalWordsController>();

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() => MultiStatusView(
      currentStatus: controller.statusType.value,
      emptyText: '当前小说已无违禁词',
      action: () {
        controller.checkNovelList();
      },
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ByWidgetsUtil.commonRichText(
              texts: [
                const TextSpan(
                  text: "违禁词",
                ),
                TextSpan(
                  text: "${controller.totolNum.value}个",
                  style: const TextStyle(
                    color: ByColorUtil.colorG4,
                  ),
                ),
              ],
              fontSize: 12.sp,
              textColor: ByColorUtil.colorF2,
              fontWeight: FontWeight.normal,
            ),
            SizedBox(
              height: 12.w,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: controller.itemList.length,
                  itemBuilder: (context, index) {
                    NovelIllegalWordsBean bean = controller.itemList[index];
                    return GestureDetector(
                      onTap: () {
                        ///违禁词检测
                        controller.fetchNovelInfo(bean);
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.only(top: index == 0 ? 0 : 6.w, bottom: 6.w),
                        child: Container(
                          height: 48.w,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: ByColorUtil.colorBg2,
                            borderRadius: BorderRadius.circular(15.w),
                          ),
                          child: Row(
                            children: [
                              ByWidgetsUtil.commonText(
                                  textColor: ByColorUtil.colorF1,
                                  fontWeight: FontWeight.w600,
                                  text: bean.cnCode ?? ''),
                              const Spacer(),
                              ByWidgetsUtil.commonText(
                                  textColor: ByColorUtil.colorG4,
                                  fontWeight: FontWeight.w600,
                                  text: '${bean.wordsCount}个'),
                              SizedBox(
                                width: 4.0.w,
                              ),
                              Image.asset(
                                'assets/home/novel/btn_novel_home_outline.png',
                                width: 8.w,
                                height: 8.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    ));
  }
}