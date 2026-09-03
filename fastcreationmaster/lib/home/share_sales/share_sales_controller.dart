import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_creation_master/global/permission/byhy_permission_utils.dart';
import 'package:fast_creation_master/home/share_sales/activity_notice_dialog.dart';
import 'package:fast_creation_master/home/share_sales/bean/invite_info.dart';
import 'package:fast_creation_master/home/share_sales/bean/invite_people_list.dart';
import 'package:fast_creation_master/home/share_sales/reward/reward_controller.dart';
import 'package:fast_creation_master/home/share_sales/reward/reward_share_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wechat_kit/wechat_kit.dart';

import '../../core/network/novel_apis.dart';
import 'bean/income_list_model.dart';

class ShareSalesController extends GetxController {
  ///邀请信息
  InviteInfoApiResponse? infoApiResponse;

  ///当前的分享海报初始化页面
  int initialPage = 0;

  ///分享海报的子组件
  List<Widget> itemsList = [];

  ///分享二维码地址
  String inviteUrl = "";

  ///选中的海报的坐标
  int selectedPosterIndex = 0;

  ///海报数据
  List<Poster> poster = [];

  String inviteCode = "";

  ///可提现
  String canWithdrawCash = "0.00";

  ///待提现
  String pending = "0.00";

  ///已提现
  String withdrawBalance = "0.00";

  ///累计奖励
  String cumulativeIncome = "0.00";

  ///奖励比例
  String rewardNumber = "";

  ///收益明细数据
  List<RewardItem> incomeList = [];
  int incomeListPage = 1;
  int incomeListPageSize = 10;
  bool incomeListCouldLoadMore = true;
  bool incomeListShowShimmer = true;

  ///收益明细数据controller
  EasyRefreshController _incomeListController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  ///邀请用户信息
  List<UserItem> inviteUserList = [];
  int inviteUserListPage = 1;
  int inviteUserListPageSize = 10;
  bool inviteUserListCouldLoadMore = true;
  bool inviteUserListShowShimmer = true;

  ///收益明细数据controller
  EasyRefreshController _inviteUserListController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  Widget? shareDialog;

  InviteActivityModel? descriptionUrl;

  ///获取邀请信息
  getInviteInfo() {
    HttpUtils.get(
      NovelApis.invitePeople,
      {},
      success: (data) {
        infoApiResponse = InviteInfoApiResponse.fromJson(data);
        InviteInfoData? inviteInfoData;
        poster = [];
        itemsList = [];
        if (infoApiResponse != null) {
          inviteInfoData = infoApiResponse!.data;
        }

        if (inviteInfoData != null) {
          poster = inviteInfoData.poster ?? [];
          inviteUrl = inviteInfoData.inviteUrl ?? "";
          inviteCode = inviteInfoData.inviteCode ?? '';
          descriptionUrl = inviteInfoData.description;
          if (inviteInfoData.inviteInfo != null) {
            int? rewardNumberData = inviteInfoData.inviteInfo!.rewardNumber;
            if (rewardNumberData == null) {
              rewardNumber = "";
            } else {
              rewardNumber = rewardNumberData.toString();
            }
          }
        }

        if (poster.isNotEmpty) {
          for (var e in poster) {
            itemsList.add(
              PosterItemView(
                poster: e,
                inviteUrl: inviteUrl,
                key: ValueKey(
                  e.id,
                ),
                inviteCode: inviteCode,
              ),
            );
          }

          shareDialog = RewardShareDialog(
            infoApiResponse: infoApiResponse!,
            itemsList: itemsList,
          );
        }

        Get.log("===获取邀请信息===$data");
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );

    HttpUtils.get(
      NovelApis.getInviteMoney,
      {},
      success: (data) {
        Get.log("获取提现信息=====>$data");
        canWithdrawCash = data["data"]["canWithdrawCash"];
        pending = data["data"]["pending"];
        withdrawBalance = data["data"]["withdrawBalance"];
        cumulativeIncome = data["data"]["cumulativeIncome"];
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///复制邀请码
  copyCode({
    required String code,
  }) {
    if (code.isEmpty) {
      // BotToast.showText(text: "复制邀请码成功~");
      return;
    }
    ClipboardData data = ClipboardData(text: code);
    Clipboard.setData(data);
    BotToast.showText(text: "复制邀请码成功~");
  }

  ///邀请好友弹窗
  inviteFriendDialog() {
    if (infoApiResponse != null && shareDialog != null) {
      // Get.dialog(
      //     RewardShareDialog(
      //       infoApiResponse: infoApiResponse!,
      //       itemsList: itemsList,
      //     ),
      //     barrierDismissible: false);

      // Get.put(()=>RewardController());
      // Get.find<RewardController>().pushWechatAuth = false;
      eventBus.fire(ShareDataEvent());
      Get.dialog(shareDialog!, barrierDismissible: false);
    }
  }

  ///分享选中的海报index
  updateSelectedPosterIndex({
    required int index,
  }) {
    selectedPosterIndex = index;
    update();
  }

  ///分享到微信好友
  shareWechatFriends()async {
    bool canWechat = await WechatKitPlatform.instance.isInstalled();

    Get.log("===canWechat=======$canWechat");
    if (!canWechat) {
      BotToast.showText(text: "请您先安装微信，才能分享给微信好友。");
      return;
    }

    if (poster.isNotEmpty) {
      eventBus.fire(
          SharePosterDataEvent(type: 0, id: poster[selectedPosterIndex].id!));
    }
  }

  ///分享到微信朋友圈
  shareWechatFriendsCircle()async {
    bool canWechat = await WechatKitPlatform.instance.isInstalled();

    Get.log("===canWechat=======$canWechat");
    if (!canWechat) {
      BotToast.showText(text: "请您先安装微信，才能分享到微信朋友圈。");
      return;
    }
    if (poster.isNotEmpty) {
      eventBus.fire(
          SharePosterDataEvent(type: 1, id: poster[selectedPosterIndex].id!));
    }
  }

  ///保存到相册
  saveLocal() async {
    final status = await ByPermissionUtilsEx.photos();
    if (!status) return;
    if (poster.isNotEmpty) {
      eventBus.fire(
          SharePosterDataEvent(type: 2, id: poster[selectedPosterIndex].id!));
    }
  }

  @override
  void onInit() {
    super.onInit();
    getInviteInfo();
    getIncomeList();
    getInviteList();
  }

  ///收益明细
  getIncomeList() {
    HttpUtils.get(
      NovelApis.getIncomeList,
      {
        "page": 1,
        "pageSize": 10,
      },
      success: (data) {
        RewardResponse rewardResponse = RewardResponse.fromJson(data);
        if (rewardResponse.data.data.isNotEmpty) {
          incomeList.clear();
          incomeList.addAll(rewardResponse.data.data);
        }

        Get.log("获取收益信息 api/invite/getIncomeList=====>$data");
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///邀请人明细
  getInviteList() {
    HttpUtils.get(
      NovelApis.getInviteList,
      {
        "page": 1,
        "pageSize": 10,
      },
      success: (data) {
        InviteUserResponse inviteUserResponse =
            InviteUserResponse.fromJson(data);
        if (inviteUserResponse.data.data.isNotEmpty) {
          inviteUserList.clear();
          inviteUserList.addAll(inviteUserResponse.data.data);
        }

        Get.log("获取邀请人 api/invite/getInviteList=====>$data");
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///刷新收益明细数据
  Future<void> refreshIncomeList() async {
    incomeListPage = 1;
    HttpUtils.get(
      NovelApis.getIncomeList,
      {
        "page": incomeListPage,
        "pageSize": incomeListPageSize,
        "type": 1,
      },
      success: (data) {
        if (incomeListShowShimmer == true) {
          incomeListShowShimmer = false;
        }
        RewardResponse rewardResponse = RewardResponse.fromJson(data);
        if (rewardResponse.data.data.isNotEmpty) {
          incomeList.clear();
          incomeList.addAll(rewardResponse.data.data);
        }

        Get.log("获取收益信息 api/invite/getIncomeList=====>$data");
        update();
        int lastPage = rewardResponse.data.lastPage;
        if (incomeListPage < lastPage) {
          incomeListCouldLoadMore = true;
        } else {
          incomeListCouldLoadMore = false;
        }
        Get.log(
            "====page====> ${incomeListPage}  beans==> ${incomeList.length}");
        _incomeListController.finishRefresh();
        _incomeListController.resetFooter();
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        _incomeListController.finishRefresh(IndicatorResult.fail);
        _incomeListController.resetFooter();
        update();
      },
    );
  }

  ///加载更多收益明细数据
  Future<void> loadIncomeList() async {
    if (!incomeListCouldLoadMore) {
      _incomeListController.finishLoad(IndicatorResult.noMore);
      _incomeListController.resetFooter();
      update();
      return;
    }
    incomeListPage++;
    HttpUtils.get(
      NovelApis.getIncomeList,
      {
        "page": incomeListPage,
        "pageSize": incomeListPageSize,
        "type": 1,
      },
      success: (data) {
        if (incomeListShowShimmer == true) {
          incomeListShowShimmer = false;
        }
        RewardResponse rewardResponse = RewardResponse.fromJson(data);
        if (rewardResponse.data.data.isNotEmpty) {
          incomeList.addAll(rewardResponse.data.data);
        }

        Get.log("获取收益信息 api/invite/getIncomeList=====>$data");
        update();
        int lastPage = rewardResponse.data.lastPage;
        if (incomeListPage < lastPage) {
          incomeListCouldLoadMore = true;
        } else {
          incomeListCouldLoadMore = false;
        }
        Get.log(
            "====page====> ${incomeListPage}  beans==> ${incomeList.length}");
        _incomeListController.finishLoad();
        _incomeListController.resetFooter();
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        _incomeListController.finishLoad(IndicatorResult.fail);
        _incomeListController.resetFooter();
        update();
      },
    );
  }

  ///刷新邀请人明细数据
  Future<void> refreshInviteUserList() async {
    inviteUserListPage = 1;
    HttpUtils.get(
      NovelApis.getInviteList,
      {
        "page": inviteUserListPage,
        "pageSize": inviteUserListPageSize,
        "type": 1,
      },
      success: (data) {
        if (inviteUserListShowShimmer == true) {
          inviteUserListShowShimmer = false;
        }
        InviteUserResponse inviteUserResponse =
            InviteUserResponse.fromJson(data);
        if (inviteUserResponse.data.data.isNotEmpty) {
          inviteUserList.clear();
          inviteUserList.addAll(inviteUserResponse.data.data);
        }

        Get.log("获取邀请人明细 api/invite/getInviteList=====>$data");
        update();
        int lastPage = inviteUserResponse.data.lastPage;
        if (inviteUserListPage < lastPage) {
          inviteUserListCouldLoadMore = true;
        } else {
          inviteUserListCouldLoadMore = false;
        }
        Get.log(
            "====page====> ${incomeListPage}  beans==> ${incomeList.length}");
        _inviteUserListController.finishRefresh();
        _inviteUserListController.resetFooter();
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        _inviteUserListController.finishRefresh(IndicatorResult.fail);
        _inviteUserListController.resetFooter();
        update();
      },
    );
  }

  ///加载更多邀请人明细数据
  Future<void> loadInviteUserList() async {
    if (!inviteUserListCouldLoadMore) {
      _inviteUserListController.finishLoad(IndicatorResult.noMore);
      _inviteUserListController.resetFooter();
      update();
      return;
    }
    inviteUserListPage++;
    HttpUtils.get(
      NovelApis.getInviteList,
      {
        "page": inviteUserListPage,
        "pageSize": inviteUserListPageSize,
        "type": 1,
      },
      success: (data) {
        if (inviteUserListShowShimmer == true) {
          inviteUserListShowShimmer = false;
        }
        InviteUserResponse inviteUserResponse =
            InviteUserResponse.fromJson(data);
        if (inviteUserResponse.data.data.isNotEmpty) {
          inviteUserList.addAll(inviteUserResponse.data.data);
        }
        Get.log("获取邀请人明细 api/invite/getInviteList=====>$data");

        update();
        int lastPage = inviteUserResponse.data.lastPage;
        if (inviteUserListPage < lastPage) {
          inviteUserListCouldLoadMore = true;
        } else {
          inviteUserListCouldLoadMore = false;
        }
        Get.log(
            "====page====> ${inviteUserListPage}  beans==> ${inviteUserList.length}");
        _inviteUserListController.finishLoad();
        _inviteUserListController.resetFooter();
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        _inviteUserListController.finishLoad(IndicatorResult.fail);
        _inviteUserListController.resetFooter();
        update();
      },
    );
  }

  ///活动说明弹窗
  Future<void> showActivityNoticeDialog()async{

    Get.log("===descriptionUrl=== ${descriptionUrl?.toJson()}");
    // showModalBottomSheet(
    //
    //     context: Get.context!, builder: (context){
    //   return ActivityNoticeDialog();
    // });

    if(descriptionUrl!=null){
      Get.dialog(ActivityNoticeDialog(descriptionUrl: descriptionUrl!,));
    }
  }
}

///分享海报数据事件
class SharePosterDataEvent {
  ///0-微信好友  1-朋友圈  2-保存到本地相册
  final int type;
  final int id;
  const SharePosterDataEvent({
    required this.type,
    required this.id,
  });
}
