/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:34:40
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-12 15:09:35
 * @FilePath: /fastcreationmaster/lib/global/routes/app_routes.dart
 * @Description: 
 */
part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  /*
    全局路由定义
  */

  ///启动页
  static const launch = '/launch';

  ///启动失败页
  static const launchFail = '/launch_fail';

  ///主页
  static const main = '/main';

  ///首页
  static const home = '/home';

  ///广场
  static const square = '/square';

  ///我的
  static const profile = '/profile';

  ///登录
  static const login = '/login';
  static const loginPhone = '/login_phone';

  /*
    首页广场页路由定义
  */
  ///广场专区
  static const squareZone = '/square_zone';

  /*
    小说主页路由
  */

  ///小说主页
  static const novelHome = '/novel_home';

  ///小说列表记录页
  static const novelRecord = '/novel_record';

  ///小说创作页
  static const novelCreate = '/novel_create';

  ///小说创作页/灵感页
  static const novelCreateBrief = '/novel_create_brief';

  ///小说创作页/大纲页
  static const novelCreateOutline = '/novel_create_outline';

  ///小说创作页/大纲生成页、流式输出页
  static const novelCreateOutlineDetail = '/novel_create_outline_detail';

  ///小说创作页/细纲页
  static const novelCreateChapter = '/novel_create_chapter';

  ///小说创作页/章节细纲生成页、流式输出页
  static const novelCreateChapterDetail = '/novel_create_chapter_detail';

  ///小说封面重绘页
  static const novelCoverRedraw = '/novel_cover_redraw';

  ///小说创作页/一键成文页
  static const novelCreateNovel = '/novel_create_novel';

  ///短篇创作
  static const shortNovel = '/short_novel';

  ///短故事、文案等创作页(短故事、推广文案、短视频脚本等)
  static const toolCreation = '/tool_create';

  ///写小说名完成页
  static const writeNameFinish = '/write_name_finish';

  ///创作记录页
  static const record = '/record';

  /*
    个人中心
  */

  ///个人中心页
  static const userProfile = '/user_profile';

  ///引导页
  static const guide = '/guide';

  ///违禁词页
  static const illegalWords = '/illegal_words';

  ///设置
  static const setting = '/setting';

  ///消息
  static const message = '/message';

  ///关于我们
  static const aboutUs = '/aboutUs';

  ///横版会员中心
  static const memberCenter = '/member_center';

  ///竖版会员中心
  static const memberCenterVertical = '/member_center_vertical';

  ///新版付费页(9.0.5版本添加)
  static const payCenterPage = '/pay_center_page';

  ///会员中心字数包
  static const memberWordsPackage = '/member_words_package';

  ///支付成功
  static const memberPaySuccess = '/member_pay_success';

  ///广场列表详情
  static const squareDetails = '/strategy_details_page';

  ///分享赚钱
  static const shareSales = '/share_sales_page';

  ///收益明细页面
  static const profitPage = "/profit_page";

  ///奖励体现页面
  static const rewardPage = "/reward_page";

  ///好友邀请页面
  static const inviteFriendCodePage = "/invite_friend_code_page";

  ///我的奖励
  static const rewardSharingPage = "/reward_sharing_page";
}
