/*
 * @Author: cold-x
 * @Date: 2025-06-10 11:44:32
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-10 18:12:57
 * @FilePath: /fastcreationmaster/lib/core/widget/view/create_novel_view.dart
 * @Description: 
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/tool/bean/item_type_bean.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///创作页输入框
class NovelTextInputView extends StatelessWidget {
  const NovelTextInputView({
    super.key,
    required this.item,
    this.inputValueChanged,
  });

  final Item item;
  final Function(String)? inputValueChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ByWidgetsUtil.commonText(
            fontSize: 12, textColor: Colors.white, text: item.title),
        SizedBox(
          height: 8.0.w,
        ),

        ///输入框高度
        buildTextView(),
        SizedBox(
          height: 16.0.w,
        ),
      ],
    );
  }

  Widget buildTextView() {
    return Container(
      height: item.type == ItemType.text ? 160.w : 44.w,
      width: double.infinity,
      decoration: BoxDecoration(
          color: ByColorUtil.color2E3038,
          borderRadius: BorderRadius.circular(10.w)),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 13, bottom: 6),
        child: TextField(
          selectionControls: MaterialTextSelectionControls(),
          maxLines:
              item.type == ItemType.text && item.itemMaxSize! > 50 ? null : 1,
          autofocus: false,
          focusNode: FocusNode(),
          scrollController: ScrollController(),
          keyboardType: item.type == ItemType.number
              ? TextInputType.number
              : TextInputType.text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            isCollapsed: true,
            border: InputBorder.none,
            hintText: item.itemDes,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.white.withOpacity(0.3),
            ),
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          onChanged: (String value) {
            ///如果是数字类型，限制输入的最大长度
            if (item.type == ItemType.number) {
              if (value.length > 10) {
                value = value.substring(0, item.itemMaxSize!);
              }
            }

            ///如果是文本类型，限制输入的最大长度
            else if (item.type == ItemType.text) {
              if (value.length > item.itemMaxSize!) {
                value = value.substring(0, item.itemMaxSize!);
              }
            }

            ///更新输入内容
            inputValueChanged?.call(value);
          },
          controller: TextEditingController(),
        ),
      ),
    );
  }
}

///标签选择
class NovelTagChooseView extends StatefulWidget {
  const NovelTagChooseView({super.key, required this.item, this.selectStrings, this.isPro = false});

  final Function(List<String>)? selectStrings;
  final Item item;
  final bool? isPro;

  @override
  State<NovelTagChooseView> createState() => _NovelTagChooseViewState();
}

class _NovelTagChooseViewState extends State<NovelTagChooseView> {
  ///选中的值
  ///如果有多个选中，则使用多个，根据item.isCheckBox判断
  List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.item.items != null && widget.item.items!.isNotEmpty) {
      // 如果有默认选中项，设置当前选中索引
      selectedItems.add(widget.item.items![0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ByWidgetsUtil.commonText(
            fontSize: 12, textColor: Colors.white, text: widget.item.title),
        SizedBox(
          height: 8.0.w,
        ),
        buildGridView(context),
        SizedBox(
          height: 16.0.w,
        ),
      ],
    );
  }

  Widget buildGridView(BuildContext context) {
    final tags = widget.item.items ?? [];
    final height = (ByScreenUtils.screenWidth - 4 * 12.w - 3 * 8.w) / 4 / 2;
    final int row = ((tags.length) / 4).ceil();
    final gridHeight = height * row + row * 10.w - 10.w;
    return SizedBox(
      height: gridHeight,
      child: GridView.count(
        crossAxisCount: 4, // 每行标签个数
        childAspectRatio: 2 / 1, // 宽高比
        crossAxisSpacing: 8.w, // 水平间距
        mainAxisSpacing: 10.w, // 垂直间距
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(tags.length, (index) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();

              ///如果是单选
              if (widget.item.isCheckBox == false) {
                if (selectedItems.contains(tags[index])) {
                  // 如果是单选，且已经选中，则不允许重复选择
                  return;
                } else {
                  // 如果是单选，替换元素
                  setState(() {
                    selectedItems[0] = tags[index];
                  });
                  widget.selectStrings?.call(selectedItems);
                }
              }

              ///多选
              else {
                if (selectedItems.contains(tags[index])) {
                  if (selectedItems.length == 1) {
                    // 如果是多选，且只剩一个元素，则不允许删除
                    BotToast.showText(text: '请至少选择一个标签');
                    return;
                  }
                  setState(() {
                    selectedItems.remove(tags[index]);
                  });
                  widget.selectStrings?.call(selectedItems);
                } else {
                  // // 如果是多选，添加元素
                  // if (selectedItems.length >= widget.item.itemMaxSize!) {
                  //   BotToast.showText(text: '最多只能选择${widget.item.itemMaxSize}个标签');
                  //   return;
                  // }
                  setState(() {
                    selectedItems.add(tags[index]);
                  });
                  widget.selectStrings?.call(selectedItems);
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: ByColorUtil.color2E3038,
                  borderRadius: BorderRadius.circular(8),
                  border: selectedItems.contains(tags[index])
                      ? Border.all(
                          color: widget.isPro! ? ByColorUtil.colorPro : ByColorUtil.colorC1,
                          width: 1,
                          style: BorderStyle.solid,
                        )
                      : null),
              child: Center(
                child: ByWidgetsUtil.commonText(
                    text: tags[index],
                    textColor: selectedItems.contains(tags[index])
                        ? widget.isPro! ? ByColorUtil.colorPro : ByColorUtil.colorC1
                        : Colors.white,
                    fontSize: 13),
              ),
            ),
          );
        }),
      ),
    );
  }
}
