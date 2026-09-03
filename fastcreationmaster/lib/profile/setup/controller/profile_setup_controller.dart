import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/network/novel_apis.dart';
import 'package:fast_creation_master/global/launch/bean/launch_info_bean.dart';
import 'package:fast_creation_master/global/launch/controller/launch_controller.dart';
import 'package:fast_creation_master/profile/member/beans/user_info_bean.dart';
import 'package:fast_creation_master/profile/member/beans/user_menus_bean.dart';
import 'package:fast_creation_master/profile/member/dialog/confirm_dialog.dart';
import 'package:get/get.dart';

import '../../../global/login/controller/onekey_manager.dart';

class ProfileSetupController extends GetxController {
  ///用户信息
  final UserController _userController = Get.find<UserController>();

  // 将 userInfo 转换为响应式数据
  final Rx<UserInfoBean?> _userInfo = Rx<UserInfoBean?>(null);
  UserInfoBean? get userInfo => _userInfo.value;

  ///协议列表
  RxList<UserMenusBean> protocolList = <UserMenusBean>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化时获取用户信息
    _updateUserInfo();
    getProtocolList();
    // 监听 UserController 中的 userInfoBean 变化
    ever(_userController.userInfoBean, _updateUserInfo);
  }

  // 更新用户信息
  void _updateUserInfo([UserInfoBean? info]) {
    _userInfo.value = info ?? _userController.userInfoBean.value;
  }

  ///加载用户信息
  void _loadUserInfo() {
    _userController.getUserInfo(
      onSuccess: (userInfo) {
        _userInfo.value = userInfo;
      },
    );
  }

  ///退出登录
  void logout() {
    ///一键登录初始化预取号
    OneKeyManager.init(checkLogin: false);
    HttpUtils.post(
      APIs.logout,
      {},
      success: (data) async {
        if (data["status"] == 200) {
          ///重新调用启动接口并更新用户信息-到登录页
          Get.find<LaunchController>().appLaunch(
            onSuccess: (LaunchInfoBean bean) {
              _userController.clearUserInfo();
              _userController.reloadUserInfo(goBack: () {
                Get.back();
                OneKeyManager.onekeyLogin(source: 'profile_setup');
              });
            },
          );
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///注销账号
  void deleteAccount() {
    ///一键登录初始化预取号
    OneKeyManager.init(checkLogin: false);
    HttpUtils.post(
      APIs.accountCancellations,
      {},
      showLoading: true,
      success: (data) {
        BotToast.showText(text: "注销成功");
        ///重新调用启动接口并更新用户信息-到登录页
        Get.find<LaunchController>().appLaunch(
          onSuccess: (LaunchInfoBean bean) {
            _userController.clearUserInfo();
            _userController.reloadUserInfo(goBack: () {
              Get.back();
                OneKeyManager.onekeyLogin(source: 'profile_setup');
            });
          },
        );
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///退出登录弹窗确认
  void showLogoutConfirm() {
    Get.dialog(
      ConfirmDialog(
        title: '退出登录',
        content: '确定退出登录吗？',
        confirmText: '确定',
        onConfirm: () {
          logout();
        },
        onCancel: () {},
      ),
    );
  }

  ///注销账号弹窗确认
  void showDeleteAccountConfirm() {
    Get.dialog(
      ConfirmDialog(
        title: '注销账号',
        height: 370,
        content:
            '1、账户一旦注销，该账户下的信息、数据、记录将全部删除，且无法恢复。\n2、注销后，账户下的全部权益均被清除:且无法恢复。\n3、注销后，该账户绑定的第三方账户将被解除绑定，您可重新使用并注册成为新用户。\n4、提交注销后将在三个工作日内完成数据清除',
        confirmText: '继续注销',
        onConfirm: () {
          deleteAccount();
        },
        onCancel: () {},
      ),
    );
  }

  ///获取协议列表
  void getProtocolList() {
    HttpUtils.get(
      NovelApis.novelAppMenus,
      {},
      success: (data) {
        // byDebugPrint(data, tag: "协议列表");
        if (data != null && data['data'] != null) {
          List<dynamic> list = data['data'];
          protocolList.value =
              list.map((e) => UserMenusBean.fromJson(e)).toList();
          update();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///根据标题匹配跳转协议
  getProtocolByTitle(String title) {
    try {
      UserMenusBean? bean =
          protocolList.firstWhereOrNull((element) => element.title == title);
      if (bean != null && bean.url.isNotEmpty) {
        ByNavRouterUtils.jumpWebViewPage(Get.context!, title, bean.url);
      }
    } catch (e) {}
  }
}
