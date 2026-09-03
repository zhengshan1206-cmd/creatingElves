/*
 * @Author: cold-x
 * @Date: 2025-06-16 10:56:47
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-27 17:39:28
 * @FilePath: /fastcreationmaster/lib/global/launch/page/guide_novel_choose_page.dart
 * @Description: 
 */


import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/global/other/event_tracking/event_tracking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../home/long_novel/controller/novel_home_controller.dart';
import '../../routes/app_pages.dart';
import '../../ui/colors.dart';

class GuideNovelChoosePage extends StatefulWidget {
  const GuideNovelChoosePage({super.key});

  @override
  State<GuideNovelChoosePage> createState() => _GuideNovelChoosePageState();
}

class _GuideNovelChoosePageState extends State<GuideNovelChoosePage> {

  List<String> titles = ['男频', '女频', '都想试着写写'];
  int _selectIndex = -1;

  @override
  void initState() {
    EventTracking.reportDataPoint(
      pageTag: 'gender_select_page', 
      operateType: 'view', 
      funcDetailTag: '', 
      funcDetailImg: '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.colorBg1,
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Image.asset(
            'assets/global/login/icon_login_bg.png',
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
            child: Padding(
          padding: EdgeInsets.all(45.w),
          child: Center(
            child: SizedBox(
              height: 350.w,
              child: Column(
                  children: [
                    ByWidgetsUtil.commonText(
                      text: '你想写哪种类型的小说？',
                      textColor: ByColorUtil.colorC1,
                      fontFamily: 'AlimamaShuHeiTi',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 20.w,),
                    SizedBox(
                      height: 178.w,
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0.w,
                          crossAxisSpacing: 15.w,
                          childAspectRatio: 135 / 178, // 宽高比
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _sexContentView(index);
                        },
                        itemCount: 2),
                    ),
                    SizedBox(height: 20.w,),
                    _buildContentView(2),
                    
                  ],
                ),
            ),
          ),
        )),
      ],
    );
  }

  ///男频女频
  Widget _sexContentView(int index) {
    return GestureDetector(
      onTap: () {
        EventTracking.reportDataPoint(
          pageTag: 'gender_select_${index == 0 ? 'male' : 'female'}_btn',
          operateType: 'click',
          funcDetailImg: '',
          funcDetailTag: '',
        );
        setState(() {
          _selectIndex = index;
          Future.delayed(const Duration(milliseconds: 100),(){
              Get.offNamed(Routes.novelHome,
                            arguments: {'type': NovelHomeSourceType.guide, 'select': _selectIndex + 1});
            });
        });
      },
      child: SizedBox(
        height: 178.w,
        width: 135.w,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 28.w,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: _selectIndex == index ? ByColorUtil.colorC1 : ByColorUtil.colorBg2,
                  image: _selectIndex == index ? const DecorationImage(image: AssetImage('assets/global/launch/icon_guide_sex_bg_selected.png')) : null,
                  borderRadius: BorderRadius.circular(20.w),
                ),
              )),
            
            if(_selectIndex == index)
            Positioned(
              left: 0,
              right: 0,
              top: 28.w,
              bottom: 0,
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.w),
                      gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xCCAAAAAA), Color(0x00AAAAAA)]))),
            ),
            ///性别背景
            Positioned(
              child: Image.asset(
                'assets/global/launch/icon_guide_sex_${index == 0 ? 'male' : 'female'}_bg.png',
                fit: BoxFit.contain,)),
            ///男频女频
            Positioned(
              child: Center(
                child: Column(
                  children: [
                    const Spacer(),
                    _selectIndex == index ? Image.asset(
                          'assets/global/launch/icon_guide_sex_${index == 0 ? 'male' : 'female'}.png',
                          width: 30.w,
                          height: 19.w,) :
                      ByWidgetsUtil.commonText(
                      text: titles[index],
                      textColor: ByColorUtil.colorF1,
                      fontSize: 14.sp,
                      fontFamily: 'AlimamaShuHeiTi'),
                    SizedBox(height: 18.w,),
                    Image.asset(
                      "assets/global/launch/btn_guide_choose_${_selectIndex == index ? 'selected' : 'normal'}.png",
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(height: 14.w,)
                  ],
                ),
              ), 
            ),
          ],
        ),
      ),
    );
  }

  ///都想写写
  Widget _buildContentView(int index) {
    return GestureDetector(
      onTap: () {
        ///点击类型
        EventTracking.reportDataPoint(
          pageTag: 'gender_select_all_btn',
          operateType: 'click',
          funcDetailImg: '',
          funcDetailTag: '',
        );
        setState(() {
            _selectIndex = index;
            Future.delayed(const Duration(milliseconds: 100),(){
              Get.offNamed(Routes.novelHome,
                            arguments: {'type': NovelHomeSourceType.guide, 'select': 0});
            });
          });
      },
      child: Container(
        height: 56.w,
        padding: EdgeInsets.all(2.w),
        decoration: _selectIndex == index ? BoxDecoration(
          gradient: LinearGradient(colors: [ByColorUtil.colorC1.withOpacity(0.2), const Color(0xFFD7F97D).withOpacity(0.2)]),
          borderRadius: BorderRadius.circular(16.w))
           : BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: ByColorUtil.colorBg2),
        child: Row(
          children: [
            SizedBox(width: 16.w,),
            Image.asset(
              "assets/global/launch/icon_guide_common_write.png",
              width: 24.w,
              height: 24.w,
            ),
            SizedBox(width: 12.w),
            ByWidgetsUtil.commonText(
              text: titles[index],
              fontSize: 15.sp,
              textColor: ByColorUtil.colorF1,
            ),
            const Spacer(),
            Image.asset(
                "assets/global/launch/btn_guide_choose_${_selectIndex == index ? 'selected' : 'normal'}.png",
                width: 20.w,
                height: 20.w,
              ),
            SizedBox(width: 20.w,),
          ],
        ),
      ),
    );
  }

}