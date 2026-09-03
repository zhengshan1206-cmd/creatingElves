import 'dart:async';

import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../../core/controller/user_controller.dart';
import '../../global/routes/app_pages.dart';
import '../../global/ui/colors.dart';
import '../long_novel/controller/brief_detail_provider.dart';

class OpenFakeProgressViewEvent {
  const OpenFakeProgressViewEvent();
}

///假的进度页面
class FakeProgressView extends StatefulWidget {
  const FakeProgressView({super.key});

  @override
  State<FakeProgressView> createState() => _FakeProgressViewState();
}

class _FakeProgressViewState extends State<FakeProgressView> {
  ///当前步骤
  int progress = 1;
  int count = 10;
  Timer? _timer;

  bool openFakeProgress = false;
  late StreamSubscription<OpenFakeProgressViewEvent>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        eventBus.on<OpenFakeProgressViewEvent>().listen((event) {
      if (openFakeProgress) {
        return;
      }
      openFakeProgress = true;
      if (openFakeProgress) {
        Future.delayed(const Duration(seconds: 1), () {
          count--;
          if(mounted){
            setState(() {

            });
          }
          _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
            if (count < 3) {
              ///倒计时结束，取消计时器
              _timer?.cancel();
            } else {
              ///减少时间
              count--;
            }
            if (mounted) {
              setState(() {});
            }
          });
        });
      }
    });
  }

  ///初始化提示
  Widget _firstHintTextView() {
    return Padding(
      padding: EdgeInsets.only(top: 147.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "正在为你设计小说大纲",
            style: TextStyle(
              color: const Color(0XFFFFFFFF),
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(
            width: 12.w,
          ),
          const CupertinoActivityIndicator(
            color: ByColorUtil.colorC1,
            radius: 10,
          ),
        ],
      ),
    );
  }

  ///开始假流程提示
  Widget _runFakeProgressView() {
    return Padding(
      padding: EdgeInsets.only(top: 135.w),
      child: Column(
        children: [
          if (count <= 7)
            Row(
              children: [
                SizedBox(
                  width: 84.w,
                ),
                Text(
                  "小说大纲设计完成",
                  style: TextStyle(
                    color: const Color(0XFFFFFFFF),
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
                Image.asset(
                  "assets/global/common/fake_finished_icon.png",
                  width: 20.w,
                  height: 20.w,
                )
              ],
            ),
          SizedBox(
            height: 15.w,
          ),
          Row(
            children: [
              SizedBox(
                width: 84.w,
              ),
              Text(
                "·故事主线",
                style: TextStyle(
                  color: const Color(0XFFFFFFFF),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              count <= 6
                  ? Image.asset(
                      "assets/global/common/fake_finished_icon.png",
                      width: 20.w,
                      height: 20.w,
                    )
                  : const CupertinoActivityIndicator(
                      color: ByColorUtil.colorC1,
                      radius: 10,
                    ),
            ],
          ),
          SizedBox(
            height: 12.w,
          ),
          Row(
            children: [
              SizedBox(
                width: 84.w,
              ),
              Text(
                "·世界观构建",
                style: TextStyle(
                  color: const Color(0XFFFFFFFF),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              count <= 5
                  ? Image.asset(
                      "assets/global/common/fake_finished_icon.png",
                      width: 20.w,
                      height: 20.w,
                    )
                  : const CupertinoActivityIndicator(
                      color: ByColorUtil.colorC1,
                      radius: 10,
                    ),
            ],
          ),
          SizedBox(
            height: 12.w,
          ),
          Row(
            children: [
              SizedBox(
                width: 84.w,
              ),
              Text(
                "·主角人设",
                style: TextStyle(
                  color: const Color(0XFFFFFFFF),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              count <= 4
                  ? Image.asset(
                      "assets/global/common/fake_finished_icon.png",
                      width: 20.w,
                      height: 20.w,
                    )
                  : const CupertinoActivityIndicator(
                      color: ByColorUtil.colorC1,
                      radius: 10,
                    ),
            ],
          ),
          SizedBox(
            height: 16.w,
          ),
          if (count <= 3)
            Row(
              children: [
                SizedBox(
                  width: 84.w,
                ),
                Text(
                  "小说全流程搞定！",
                  style: TextStyle(
                    color: const Color(0XFFFFFFFF),
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BriefDetailProvider>();
    return Column(
      children: [
        Container(
          margin: EdgeInsets.zero,
          width: 1.sw,
          height: 457.w,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Color(0xFF121212),
                Color.fromRGBO(18, 18, 18, 0.2),
                Color.fromRGBO(18, 18, 18, 1),
                Color(0xFF121212),
              ],
              // stops: [0.0, 0.8, 1.0],
            ),
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
          // color: Colors.blue,
          child: Column(
            children: [
              if (count==9||count==8) _firstHintTextView(),
              if (count <=7) _runFakeProgressView(),
              const Spacer(),
              InkResponse(
                  onTap: () {
                    if(count<=7){
                      final UserController userController =
                      Get.find<UserController>();
                      userController.checkPreLogin(
                          source: 'guide_novel_brief',
                          actionCallback: () {
                            userController.jumpToPayPage(
                              isBackHome: true,
                              source: 'guide_novel_brief',
                              back: () {
                                ///引导页进入首页
                                provider.isBackToMain = true;
                                Get.offAllNamed(Routes.main);
                              },
                            );
                          });
                    }
                  },
                  child: Opacity(
                    opacity: count<=7?1:0.3,
                    child: Container(
                      width: 1.sw,
                      height: 48.w,
                      margin: EdgeInsets.only(
                        left: 12.w,
                        right: 12.w,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0.38, 1.0],
                          colors: [
                            Color(0xFF98FC4A), // #98FC4A
                            Color(0xFFD7F97D), // #D7F97D
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "解锁Ai小说",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )),
              SizedBox(
                height: 38.w,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
