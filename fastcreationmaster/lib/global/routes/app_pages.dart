/*
 * @Author: cold-x
 * @Date: 2025-06-04 20:33:30
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-28 10:30:27
 * @FilePath: /fastcreationmaster/lib/global/routes/app_pages.dart
 * @Description: 
 */

import 'package:fast_creation_master/core/widget/page/base_record_page.dart';
import 'package:fast_creation_master/global/launch/binding/guide_binding.dart';
import 'package:fast_creation_master/global/launch/page/launch_error_page.dart';
import 'package:fast_creation_master/global/launch/page/launch_page.dart';
import 'package:fast_creation_master/global/login/binbing/login_binding.dart';
import 'package:fast_creation_master/global/login/controller/login_controller.dart';
import 'package:fast_creation_master/global/login/page/login_page.dart';
import 'package:fast_creation_master/global/other/illegal_words/binding/illegal_words_binding.dart';
import 'package:fast_creation_master/home/long_novel/binding/novel_create_binding.dart';
import 'package:fast_creation_master/home/long_novel/binding/novel_record_binding.dart';
import 'package:fast_creation_master/home/long_novel/binding/novel_chapter_binding.dart';
import 'package:fast_creation_master/home/long_novel/binding/novel_outline_binding.dart';
import 'package:fast_creation_master/home/long_novel/binding/novel_home_binding.dart';
import 'package:fast_creation_master/home/long_novel/page/novel_chapter_page.dart';
import 'package:fast_creation_master/home/long_novel/page/novel_outline_page.dart';
import 'package:fast_creation_master/home/long_novel/page/novel_home_page.dart';
import 'package:fast_creation_master/home/long_novel/page/novel_record_page.dart';
import 'package:fast_creation_master/home/long_novel/view/cover_redraw_view.dart';
import 'package:fast_creation_master/home/share_sales/binding/reward_sharing_binding.dart';
import 'package:fast_creation_master/home/share_sales/page/reward_sharing_page.dart';
import 'package:fast_creation_master/home/share_sales/reward/reward_page.dart';
import 'package:fast_creation_master/home/share_sales/share_sales_binding.dart';
import 'package:fast_creation_master/home/share_sales/share_sales_page.dart';
import 'package:fast_creation_master/home/tool/binding/name_finish_binding.dart';
import 'package:fast_creation_master/home/tool/binding/tool_create_binding.dart';
import 'package:fast_creation_master/home/tool/page/name_finish_page.dart';
import 'package:fast_creation_master/home/tool/page/tool_create_page.dart';
import 'package:fast_creation_master/profile/aboutUs/bindings/abount_us_binding.dart';
import 'package:fast_creation_master/profile/aboutUs/pages/about_us_page.dart';
import 'package:fast_creation_master/profile/member/binding/member_center_binding.dart';
import 'package:fast_creation_master/profile/member/binding/member_pay_success_binding.dart';
import 'package:fast_creation_master/profile/member/page/member_center_page.dart';
import 'package:fast_creation_master/profile/member/page/member_center_vertical_page.dart';
import 'package:fast_creation_master/profile/binding/profile_binding.dart';
import 'package:fast_creation_master/profile/member/page/member_pay_success_page_ex.dart';
import 'package:fast_creation_master/profile/member/page/member_words_package_page.dart';
import 'package:fast_creation_master/profile/member/page/pay_center_page_one_ex.dart';
import 'package:fast_creation_master/profile/profile.dart';
import 'package:fast_creation_master/profile/message/profile_message_page.dart';
import 'package:fast_creation_master/profile/setup/binding/profile_setup_binding.dart';
import 'package:fast_creation_master/profile/setup/profile_setup_page.dart';
import 'package:fast_creation_master/square/binding/square_binding.dart';
import 'package:fast_creation_master/square/binding/square_details_binding.dart';
import 'package:fast_creation_master/square/binding/square_zone_binding.dart';
import 'package:fast_creation_master/square/square.dart';
import 'package:fast_creation_master/square/zone/square_details_page.dart';
import 'package:fast_creation_master/square/zone/square_zone_page.dart';
import 'package:get/get.dart';

import '../../home/long_novel/page/novel_create_page.dart';
import '../../home/share_sales/friend_invite_code_page/friend_invite_code_binding.dart';
import '../../home/share_sales/friend_invite_code_page/friend_invite_code_page.dart';
import '../../home/share_sales/profit_list_view/profit_list_binding.dart';
import '../../home/share_sales/profit_list_view/profit_list_view.dart';
import '../../home/share_sales/reward/reward_binding.dart';
import '../../home/tool/binding/record_binding.dart';
import '../launch/page/guide_novel_choose_page.dart';
import '../main/main_page.dart';
import '../other/illegal_words/page/illegal_words_page.dart';
import '../../home/main_page/page/home.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    /*
    全局路由
    */

    ///启动页
    GetPage(
      name: Routes.launch,
      page: () => const LaunchPage(),
    ),

    ///启动失败页
    GetPage(
      name: Routes.launchFail,
      page: () => const LaunchErrorPage(),
    ),

    ///首页
    GetPage(
        name: Routes.main,
        page: () => MainPage(),
        transition: Transition.noTransition),

    ///首页独立路由
    GetPage(
        name: Routes.home,
        page: () => HomePage(),
        transition: Transition.noTransition),

    ///广场独立路由
    GetPage(
        name: Routes.square,
        page: () => SquarePage(),
        binding: SquareBinding(),
        transition: Transition.noTransition),

    ///我的独立路由
    GetPage(
        name: Routes.profile,
        page: () => ProfilePage(),
        binding: ProfileBinding(),
        transition: Transition.noTransition),

    ///登录页
    GetPage(
      name: Routes.login,
      page: () => LoginPage(
        type: LoginType.wx,
      ),
      binding: LoginBinding(),
    ),

    ///登录手机页
    GetPage(
      name: Routes.loginPhone,
      page: () => LoginPage(
        type: LoginType.phone,
      ),
      binding: LoginBinding(),
    ),

    ///引导页
    GetPage(
      name: Routes.guide,
      page: () => const GuideNovelChoosePage(),
      binding: GuideBinding(),
    ),

    ///违禁词页
    GetPage(
      name: Routes.illegalWords,
      page: () => IllegalWordsPage(),
      binding: IllegalWordsBinding(),
    ),

    /*
      首页广场页路由
    */
    ///广场
    GetPage(
      name: Routes.square,
      page: () => SquarePage(),
      binding: SquareBinding(),
    ),

    ///广场专区
    GetPage(
      name: Routes.squareZone,
      page: () => SquareZonePage(
        id: Get.arguments["id"],
        menutitle: Get.arguments["menutitle"],
      ),
      binding: SquareZoneBinding(),
    ),

    /*
      小说主页路由
    */
    ///小说主页
    GetPage(
      name: Routes.novelHome,
      page: () => NovelHomePage(),
      binding: NovelHomeBinding(),
    ),

    ///小说列表记录页
    GetPage(
      name: Routes.novelRecord,
      page: () => NovelRecordPage(),
      binding: NovelRecordBinding(),
    ),

    ///小说创作页
    GetPage(
      name: Routes.novelCreate,
      page: () => NovelCreatePage(),
      binding: NovelCreateBinding(),
    ),

    ///小说创作页/大纲页
    GetPage(
      name: Routes.novelCreateOutline,
      page: () => NovelOutlinePage(),
      binding: NovelOutlineBinding(),
    ),

    ///小说创作页/细纲页
    GetPage(
      name: Routes.novelCreateChapter,
      page: () => NovelChapterPage(),
      binding: NovelChapterBinding(),
    ),

    ///小说封面重绘页
    GetPage(
      name: Routes.novelCoverRedraw,
      page: () => CoverRedrawView(
        cover: Get.arguments['cover'] ?? '',
        id: Get.arguments['id'] ?? 0,
        module: Get.arguments['module'] ?? '1',
      ),
    ),

    ///短故事、文案等创作页(短故事、推广文案、短视频脚本等)
    GetPage(
      name: Routes.toolCreation,
      page: () => ToolCreatePage(),
      binding: ToolCreateBinding(),
    ),

    ///写小说名完成页
    GetPage(
      name: Routes.writeNameFinish,
      page: () => NameFinishPage(),
      binding: NameFinishBinding(),
    ),

    ///创作记录页
    GetPage(
      name: Routes.record,
      page: () => BaseRecordPage(),
      binding: RecordBinding(),
    ),

    ///个人中心
    GetPage(
      name: Routes.userProfile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),

    ///设置
    GetPage(
      name: Routes.setting,
      page: () => ProfileSetupPage(),
      binding: ProfileSetupBinding(),
    ),

    ///消息
    GetPage(
      name: Routes.message,
      page: () => ProfileMessagePage(),
    ),

    ///关于我们
    GetPage(
      name: Routes.aboutUs,
      page: () => AboutUsPage(),
      binding: AboutUsBinding(),
    ),

    ///横版会员中心
    GetPage(
      name: Routes.memberCenter,
      page: () => MemberCenterPage(),
      binding: MemberCenterBinding(),
    ),

    ///竖版会员中心
    GetPage(
      name: Routes.memberCenterVertical,
      page: () => MemberCenterVerticalPage(),
      binding: MemberCenterBinding(),
    ),

    ///新版付费页(9.0.5版本添加)
    GetPage(
      name: Routes.payCenterPage,
      page: () => PayCenterPageOneEx(),
      binding: MemberCenterBinding(),
    ),

    ///新版付费页(9.0.7版本添加)
    // GetPage(
    //   name: Routes.payCenterPage,
    //   page: () => PayCenterPageOneEx(),
    //   binding: MemberCenterBinding(),
    // ),

    ///会员中心字数包
    GetPage(
      name: Routes.memberWordsPackage,
      page: () => MemberWordsPackagePage(),
      binding: MemberCenterBinding(),
    ),

    ///支付成功
    GetPage(
      name: Routes.memberPaySuccess,
      // page: () => MemberPaySuccessPage(),
      page: () => MemberPaySuccessPageEx(),
      binding: MemberPaySuccessBinding(),
    ),

    ///攻略详情
    GetPage(
      name: Routes.squareDetails,
      page: () => SquareDetailsPage(),
      binding: SquareDetailsBinding(),
    ),

    ///分享赚钱
    GetPage(
      name: Routes.shareSales,
      page: () => const ShareSalesPage(),
      binding: ShareSalesBinding(),
    ),

    ///收益明细
    GetPage(
      name: Routes.profitPage,
      page: () => const ProfitListView(),
      binding: ProfitListBinding(),
    ),

    ///奖励页面
    GetPage(
      name: Routes.rewardPage,
      page: () => const RewardPage(),
      binding: RewardBinding(),
    ),

    ///邀请码填写页面
    GetPage(
      name: Routes.inviteFriendCodePage,
      page: () => const FriendInviteCodePage(),
      binding: FriendInviteCodeBinding(),
    ),

    ///我的奖励
    GetPage(
      name: Routes.rewardSharingPage,
      page: () => RewardSharingPage(),
      binding: RewardSharingBinding(),
    ),
  ];
}

class RouterUtil {
  static String initialRoute() => nextRoute();

  static String nextRoute() {
    return Routes.launch;
  }
}
