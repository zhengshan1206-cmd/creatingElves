import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/home/tool/bean/item_type_bean.dart';
import 'package:fast_creation_master/home/tool/controller/tool_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/controller/base_record_controller.dart';
import '../../../core/widget/view/bottom_view.dart';
import '../../../core/widget/view/create_novel_view.dart';
import '../../../global/ui/colors.dart';

///工具模块创建通用组件
///包括写小说名，写推广文案，写笔名
class ToolCreateView extends StatefulWidget {
  const ToolCreateView({
    super.key,
    required this.type,
  });

  final CreationType type;

  @override
  State<ToolCreateView> createState() => _ToolCreateViewState();
}

class _ToolCreateViewState extends State<ToolCreateView> {
  final ToolCreateController controller = Get.find<ToolCreateController>();

  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        ///短故事才有随机生成
        if (controller.type == CreationType.folkNovel)
        SizedBox(
          height: 12.h,
        ),
        if (controller.type == CreationType.folkNovel)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              height: 44.w,
              constraints: const BoxConstraints(maxWidth: double.infinity),
              decoration: BoxDecoration(
                  color: ByColorUtil.colorBg2,
                  borderRadius: BorderRadius.circular(10.w),
                  border:
                      Border.all(color: ByColorUtil.color2E3038, width: 1.w)),
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
                        textColor: Colors.white,
                        fontSize: 14,
                        text: '没有想法，试试~'),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        ///随机生成
                        userController.checkPreLogin(source: 'folk_story', actionCallback: () {
                          controller.autoGenerante();
                        });
                      },
                      child: Row(
                        children: [
                          ByWidgetsUtil.commonText(
                              textColor: ByColorUtil.colorC1,
                              fontSize: 14,
                              text: '随机生成'),
                          SizedBox(
                            width: 4.w,
                          ),
                          Image.asset(
                            'assets/home/folkstory/btn_folkstory_try.png',
                            width: 8.w,
                            height: 8.w,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        if (controller.type == CreationType.folkNovel)
          SizedBox(
            height: 12.h,
          ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Container(
                decoration: BoxDecoration(
                    color: ByColorUtil.colorBg2,
                    borderRadius: BorderRadius.circular(10.w)),
                child: Padding(
                  padding: EdgeInsets.only(top: 12.w, left: 12.w, right: 12.w),

                  ///列表页
                  child: Obx(() => ListView.builder(
                      itemCount: controller.getItemCount(),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        ///如果是笔名或者小说名，在item最后一列添加选择生成数量的item
                        if (controller.isNameType() &&
                            index == controller.getItemCount() - 1) {
                          Item item = controller.initGenerateNumItem();
                          return NovelTagChooseView(
                              item: item,
                              selectStrings: (value) {
                                controller
                                    .updateGenerateNum(int.parse(value[0]));
                              });
                        } else {
                          Item item = controller.typeItems.value!.items[index];
                          controller.itemTitles[item.id] = item.title;
                          switch (item.type) {
                            ///文本和数字输入框
                            case ItemType.text:
                            case ItemType.number:
                              return NovelTextInputView(
                                item: item,
                                inputValueChanged: (p0) {
                                  controller.updateContent(item.id, p0);
                                },
                              );
                            ///列表框
                            case ItemType.items:
                              return NovelTagChooseView(
                                item: item,
                                isPro: controller.isProfessionalMode.value,
                                selectStrings: (value) {
                                  controller.updateContent(item.id, value);
                                },
                              );
                            default:
                              return NovelTextInputView(item: item);
                          }
                        }
                      })),
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: BottomView(
                padding: 0,
                showWords: ![CreationType.novelName,CreationType.penName,CreationType.novelPromotion].contains(widget.type),
                mode: controller.getBottomType(),
                ///切换模式
                toggleMode: () {
                  controller.toggleMode();
                },
                ///下一步
                nextStep: (){
                  controller.nextStep(isRandom: controller.getBottomType() == 0 ? 2 : 1);
              },),
        ),
      ],
    );
  }
}
