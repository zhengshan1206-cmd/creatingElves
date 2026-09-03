
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/widget/view/bottom_view.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/other/novel_words/controller/words_controller.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_create_bean.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_home_controller.dart';
import 'package:fast_creation_master/home/long_novel/page/novel_base_page.dart';
import 'package:fast_creation_master/home/long_novel/view/long_novel_create_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';
import '../controller/novel_create_controller.dart';

// ignore: must_be_immutable
class NovelCreatePage extends NovelCreateBasePage {
  NovelCreatePage({super.key});

  @override
  NovelCreateController get controller => Get.find<NovelCreateController>();

  @override
  String get title => controller.type!.title;

  @override
  Widget buildActions(BuildContext context) {
    return controller.source == NovelHomeSourceType.normal ? GestureDetector(
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: ByWidgetsUtil.commonText(
          bgColor: Colors.transparent,
          textColor: ByColorUtil.colorC1,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          text: '创作记录',
        ),
      ),
      onTap: () {
        if(controller.type == CreationType.shortStory) {
          Get.toNamed(Routes.record, arguments: {'type': controller.type});
        }
        else {
          Get.toNamed(Routes.novelRecord, arguments: {'type': controller.type});
        }
      },
    ) : Container();
  }

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() => MultiStatusView(
      currentStatus: controller.statusType.value,
      action: () {
        controller.fetchNovelConfig();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            if(controller.type != CreationType.shortStory)
            buildStepView(),
            if(controller.type != CreationType.shortStory)
            SizedBox(
              height: 12.w,
            ),
            _buildItemsView(),
            if(controller.source != NovelHomeSourceType.guide)
            Obx(() => BottomView(
              type: controller.type,
              padding: 0,
              words: controller.words.getWords(WordsType.total, controller.chapterNum.value, novelType: controller.type!),
              mode: controller.type == CreationType.shortStory ? 0 : controller.isProfessionalMode.value ? 2 : 1,
              nextBtnText: controller.type == CreationType.shortStory ? '开始创作' : '下一步',
              ///切换模式
              toggleMode: () {
                controller.toggleMode();
              },
              ///下一步
              nextStep: (){
                controller.createNovel();
            },)),
            if(controller.source == NovelHomeSourceType.guide)
            BottomView(
              padding: 0,
              showWords: false,
              nextBtnText: '开始生成小说',
              nextStep: () {
                controller.createNovel();
              },
            )
          ],
        ),
      ),
    ));
  }

  ///随机生成
  Widget autoGenerateView() {
    return Container(
      height: 44.w,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      decoration: BoxDecoration(
          color: ByColorUtil.colorBg2,
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(color: ByColorUtil.color2E3038, width: 1.w)),
      child: Padding(
        padding: EdgeInsets.all(12.0.w),
        child: Row(
          children: [
            Image.asset(
              'assets/home/folkstory/icon_folkstory_try_random.png',
              width: 20.w,
              height: 20.w,
            ),
            SizedBox(
              width: 4.0.w,
            ),
            ByWidgetsUtil.commonText(
                textColor: Colors.white, fontSize: 14, text: '没有想法，试试~'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                ///随机生成
                controller.randomGenerate();
              },
              child: Row(
                children: [
                  ByWidgetsUtil.commonText(
                      textColor: controller.isProfessionalMode.value ? ByColorUtil.colorPro : ByColorUtil.colorC1,
                      fontSize: 14,
                      text: '随机生成'),
                  SizedBox(
                    width: 4.w,
                  ),
                  Image.asset(
                    'assets/home/main/icon_home_banner_detail_${controller.isProfessionalMode.value ? 'purple' :'green'}.png',
                    width: 8.w,
                    height: 8.w,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  ///创建元素
  Widget _buildItemsView() {
    return Expanded(
      child: CustomScrollView(
        controller: controller.scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: autoGenerateView(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 12.w,
          ),
        ),
        ///结果展示页
        const SliverToBoxAdapter(
          child: CreateResultView(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 12.w,
          ),
        ),
        // 列表项
        Obx(() => SliverToBoxAdapter(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.itemList.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                NovelCreateBean item = controller.itemList[index];
                  return Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 0 : 6.w, bottom: 6.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w,),
                      decoration: BoxDecoration(
                        color: ByColorUtil.colorBg2,
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      child: _buildCell(index, item)),
                  );
              },
            ),
        )),
      ],
    ));
  }


  ///创建cell，当内嵌cell时需要传入父级的Key来更新选择数据
  Widget _buildCell(int index, NovelCreateBean item, {NovelCreateBean? parentBean}) {
    switch (item.style) {
      ///文本和数字输入框
      case 1:
      case 11:
      case 21:
        return NovelTextInputCell(
          key: controller.getItemKey(item.name!),
          title: item.name,
          max: item.max,
          min: item.min,
          normalValue: item.selectedValue,
          hintText: item.placeholder,
          type: item.style == 1
              ? InputType.text
              : item.style == 21
                  ? InputType.number
                  : InputType.longText,
          inputValueChanged: (p0) {
            controller.updateChooseData(null, p0, item);
          },
          createAction: () {
            controller.gotoAIWrite(item);
          },
        );
      ///数量选择
      case 22:
        return ChapterNumChooseCell(
          key: controller.getItemKey(item.name!),
          title: item.name,
          min: item.min,
          max: item.max,
          isPro: controller.isProfessionalMode.value,
          selectedValue: item.selectedValue,
          numChanged: (p0) {
            controller.updateChooseData(null, p0, item);
          },
        );

      ///标签选择框
      case 32:
      case 42:
        final tags = item.items?.values.map((e) => e.toString()).toList();
        final selectedTags = controller.getMultipleTags(item, parentBean: parentBean);
        return TagsCreateCell(
          title: item.name,
          key: controller.getItemKey(item.name!),
          tags: tags,
          isPro: controller.isProfessionalMode.value,
          selectedItems: selectedTags,
          expanded: index != 0 || parentBean?.style == 51,
          selectStrings: (value) {
            controller.updateChooseData(parentBean, value.mapValues(item.items!), item);
          },
        );
      ///内嵌选择
      case 51:
        List<NovelCreateBean>? itemList2 = item.modules;
        return ListView.builder(
            key: controller.getItemKey(item.name!),
            shrinkWrap: true,
            itemCount: itemList2!.length + 1,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.w,),
                    ByWidgetsUtil.commonText(
                      textColor: ByColorUtil.colorF1, fontSize: 16, fontWeight: FontWeight.w500, text: item.name!),
                  ],
                );
              }
              NovelCreateBean bean = itemList2[index - 1];
              return Obx(() =>_buildCell(index - 1, bean, parentBean: item));
            });
      ///角色类型选择
      case 61:
        return RoleCreateCell(
          key: controller.getItemKey(item.name!),
          count: controller.roleCount.value,
          title: item.name,
          selectedValue: item.selectedValue,
          changed: (p0) {
            controller.updateChooseData(null, p0, item);
          },);
      default:
        return Container();
    }
  }
}
