import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/network/novel_apis.dart';

class FriendInviteCodeController extends GetxController {
  FocusNode focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();

  ///当前容器高度
  double height = 96.w;

  bool isPostData = false;

  ///邀请背景图
  String inviteBgUrl = "";

  ///已经绑定的邀请码
  String boundInviteCode = "";


  ///键盘拉起 刷新布局高度
  updateContainerHeight({
    bool keyboard = false,
  }) {
    if (keyboard) {
      height = 245.w;
    } else {
      height = 96.w;
    }
    update();
  }

  ///取消相关输入框的焦点
  unFocusRealNameFocusNode() {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
  }

  String inviteCode = "";

  @override
  void onInit() {
    super.onInit();
    textEditingController.addListener(() {
      inviteCode = textEditingController.text.replaceAll(' ', "");
      update();
    });

    initData();
  }

  ///确认邀请码
  confirmInviteCode() {
    if (isPostData) {
      BotToast.showText(text: "正在核对邀请码，请勿重复点击～");
      return;
    }
    isPostData = true;
    if (inviteCode.isEmpty) {
      BotToast.showText(text: "请填写邀请码");
      isPostData = false;
      return;
    }
    HttpUtils.post(
      NovelApis.confirmInviteCode,
      {
        "inviteCode": inviteCode,
      },
      success: (data) {
        Get.log("===确认的邀请码信息===$data");
        isPostData = false;
        Get.find<UserController>().reloadUserInfo(
        );
        boundInviteCode = inviteCode;
        textEditingController.text = "";
        Get.log("===绑定的邀请码===$boundInviteCode");
        BotToast.showText(text: "绑定成功~");
        update();
      },
      fail: (code, msg) {
        isPostData = false;
        BotToast.showText(text: msg);
      },
    );
  }

  initData(){
    inviteBgUrl = Get.find<UserController>().inviteBgUrl;
    final argument = Get.arguments;
    if(argument!=null){
      if(argument["boundInviteCode"]!=null){
        boundInviteCode = argument["boundInviteCode"];
      }
    }

    if(boundInviteCode.isNotEmpty){
      height=172.w;
    }

    update();
  }
}
