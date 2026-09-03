/*
 * @Author: cold-x
 * @Date: 2025-06-12 18:56:04
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-24 18:52:34
 * @FilePath: /fastcreationmaster/lib/home/long_novel/controller/novel_home_controller.dart
 * @Description: 
 */

import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_controller.dart';
import 'package:fast_creation_master/core/widget/view/diolog_view.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/global/other/novel_words/controller/words_controller.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_bean.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_manager_controller.dart';
import 'package:fast_creation_master/home/long_novel/request/chapter_request.dart';
import 'package:fast_creation_master/home/long_novel/view/cover_redraw_view.dart';
import 'package:fast_creation_master/profile/profile_controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/cache/global_controller.dart';
import '../../../core/controller/user_controller.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/service/data_service.dart';
import '../../../core/widget/view/muti_status_view.dart';
import '../../../global/launch/controller/launch_controller.dart';
import '../../../global/login/controller/onekey_manager.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/routes/routes_utils.dart';
import '../../first_create/fake_chapter_list_view.dart';
import '../bean/novel_chapter_bean.dart';
import '../page/novel_brief_page.dart';
import '../page/novel_detail_page.dart';
import 'brief_detail_provider.dart';
import 'novel_detail_provider.dart';
import 'package:fast_creation_master/core/widget/view/provider_page_tracker.dart';

///小说详情页来源
enum NovelHomeSourceType {
  ///默认模式，用户小说详情页
  normal,

  ///广场页
  square,

  ///引导页
  guide,
}

class NovelHomeController extends BaseController {
  ///是否能创建小说
  ///否：即是从启动页或者创作同款进入浏览同款小说
  NovelHomeSourceType? source;

  ///启动页进入选择的小说类型
  int? selectNovelType;
  //用户个人进入时为小说id， 其他用户启动页或者浏览同款小说时为广场ID
  int novelID;

  NovelHomeController({
    this.source = NovelHomeSourceType.normal,
    this.selectNovelType,
    required this.novelID,
  });

  ///取小说数据
  var novelBean = Rx<NovelBean?>(null);

  var guideNovelBean = Rx<GuideNovelBean?>(null);

  ///小说正文列表
  RxList<ChapterBean> itemList = <ChapterBean>[].obs;

  ///当前小说的状态（生成中或者生成失败）
  ChapterBean? currentBean;

  ///是否正序倒序显示章节
  Rx<bool> reverse = false.obs;

  ///banner
  RxList<BannerBean> bannerList = <BannerBean>[].obs;

  ///字数
  WordsController? words;

  ///用户
  ProfileController? user;

  ///启动接口状态
  // Rx<MultiStatusType> launchStatus = MultiStatusType.statusLoading.obs;

  ///小说管理
  final NovelManagerController manager = Get.find<NovelManagerController>();

  String module = "1";

  late StreamSubscription<SaveCoverEvent> streamSubscription;

  /// 保存原始路由参数，用于重新加载时使用
  Map<String, dynamic>? _originalArguments;

  late StreamSubscription<RefreshFakeChapter> refreshFakeChapterSub;


  @override
  void onInit() {
    super.onInit();
    // 保存原始路由参数
    _originalArguments = Get.arguments as Map<String, dynamic>?;

    streamSubscription = eventBus.on<SaveCoverEvent>().listen((e) {
      // 如果需要加载整个页面，使用保存的参数重新加载
      if (source == NovelHomeSourceType.normal) {
        fetchNovelDetail();
      }
    });
    refreshFakeChapterSub = eventBus.on<RefreshFakeChapter>().listen((e){
       Get.log("===支付成功刷新小说详情数据===");
       if(novelBean.value!=null){
         if(novelBean.value!.isTryOut==1){
           HttpUtils.get(
             NovelApis.novelInfo,
             {'id': novelID},
             success: (data) {
               refreshSuccess(true, true);
               if (data['status'] == 200) {
                 novelBean.value = NovelBean.fromJson(data['data']);

                 ///管理页
                 manager.bean = novelBean.value;
                 manager.title.value = novelBean.value!.title!;
                 update();
               }
             },
             fail: (code, msg) {
               BotToast.showText(text: msg);
             },
           );
         }
       }
    });

    initData();
    fetchLaunchData();

    if(source != NovelHomeSourceType.normal) {
      EventTracking.reportDataPoint(
          pageTag: source == NovelHomeSourceType.guide ? 'accept_same_page' : 'home_book_detail_page',
          operateType: 'view',
          funcDetailImg: '',
          funcDetailTag: novelID.toString(),
          extra: {'source': source == NovelHomeSourceType.guide ? 2 : 1}
        );
    }
    else {
      final String type = _originalArguments?['module'] ?? '';
      if(type.isNotEmpty) {
        EventTracking.reportDataPoint(
          pageTag: 'myworks_detail_${type == '1' ? 'long_novel' : 'short_sales'}_works',
          operateType: 'view',
          funcDetailImg: '',
          funcDetailTag: novelID.toString(),
        );
      }
    }
  }

  ///加载启动数据
  void fetchLaunchData() {
    LaunchController launchController = Get.find<LaunchController>();

    ///是否有启动接口
    if (launchController.isLaunched) {
      statusType.value = MultiStatusType.statusContent;
      loadPageData();
      Get.find<UserController>().reloadUserInfo(reloadUse: false);
    } else {
      statusType.value = MultiStatusType.statusLoading;
      launchController.appLaunch(
        onSuccess: (p0) {
          statusType.value = MultiStatusType.statusContent;
          loadPageData();
        },
        onFail: () {
          statusType.value = MultiStatusType.statusNoNetWork;
        },
      );
    }
  }

  ///加载小说管理页面数据
  void loadPageData() {
    ///统计数据
    if (source == NovelHomeSourceType.guide) {
      ///闪验预取号
      OneKeyManager.init(checkLogin: false);
      DataService.onEvent(
        'guide_novel_home',
        {
          'type': selectNovelType ?? 100,
          'launch': Get.find<LaunchController>().isLaunched
        },
      );

      ///初始化付费页数据
      GlobalController.instance.pay.getPayStyle();
      bool register = Get.isRegistered<WordsController>();
      if (!register) {
        Get.put(WordsController(), permanent: true);
      }
    } else {
      words = Get.find<WordsController>();
      user = Get.find<ProfileController>();
      DataService.onEvent('novel_home', {
        'novelID': novelID,
        'type': source != NovelHomeSourceType.normal ? 'square' : 'normal'
      });
    }
    loadData(isFirstLoad: true);
    loadBanners(postion: 101);
  }

  ///加载小说数据
  void loadData({bool? isFirstLoad = false}) {
    pageHelper.resetPage();

    ///个人创作的小说
    if (source == NovelHomeSourceType.normal) {
      fetchNovelDetail(isFirstLoad: isFirstLoad!);
      fetchGeneratingChapter();
    }

    ///查看他人的小说
    else if (source == NovelHomeSourceType.square) {
      fetchSquareNovelDetail(isFirstLoad: isFirstLoad!);
    } else {
      if (isFirstLoad!) {
        guideNovel(isFirstLoad: isFirstLoad);
      }
    }
  }

  ///进入小说正文页
  void gotoNovelInfoPage(int chapterID,
      {bool isSquare = false, bool isGuide = false, int? stage}) {
    final provider = NovelDetailProvider();
    provider.novelID = novelID;
    provider.contentID = chapterID;
    provider.isSquare = isSquare;
    provider.isGuide = isGuide;
    provider.stage = stage;
    ByNavRouterUtils.push(
      Get.context!,
      trackProviderPage(
        pageId: '/novel_detail_page',
        widget: ChangeNotifierProvider(
          create: (context) => provider,
          child: const NovelDetailPage(),
        ),
      ),
    ).then((_) {
      if (source == NovelHomeSourceType.normal) {
        loadData();
      }
    });
  }

  ///跳转页面
  void gotoPage() {
    ///进入灵感生成页
    if (novelBean.value!.stage! <= 4) {
      final provider = BriefDetailProvider();
      ByNavRouterUtils.pushReplacement(
        Get.context!,
        trackProviderPage(
          pageId: '/novel_brief_page',
          widget: ChangeNotifierProvider(
            create: (context) => provider,
            child: NovelBriefPage(
              novelID: novelBean.value!.id!,
            ),
          ),
        ),
      ).then((_) {
        if (source == NovelHomeSourceType.normal) {
          loadData();
        }
      });
    } else if (novelBean.value!.stage! <= 8) {
      Get.toNamed(Routes.novelCreateOutline,
          arguments: {'novelID': novelBean.value!.id!})?.then((_) {
        if (source == NovelHomeSourceType.normal) {
          loadData();
        }
      });
    }
  }

  ///是否能继续生成小说
  bool canContinueGenerateNovel() {
    if (user!.userInfo!.wordsPack! - novelBean.value!.continueWords! > 0) {
      return true;
    }
    return false;
  }

  ///小说是否断更
  bool isPaused() {
    ///暂停中或者暂停都算断更
    if (source == NovelHomeSourceType.normal &&
        (novelBean.value!.pauseStatus! == 1 ||
            novelBean.value!.pauseStatus! == 3) &&
        novelBean.value!.stage != 10) {
      return true;
    }
    return false;
  }

  ///检查是否有生成失败的细纲和正文
  void checkNovelStatus() {
    if (currentBean?.stage == 7 || currentBean?.stage == 8) {
      Get.dialog(NovelDialog(
        showCancelBtn: false,
        confirmText: '重新生成',
        content: currentBean?.stage == 8
            ? '字数不够，章节正文生成失败，需要重新生成'
            : '章节正文生成失败，需要重新生成，\n生成失败不会消耗字数',
        onConfirm: () {
          ChapterRequest.retryChapter(novelID, currentBean!.id!);
        },
      ));
    }
  }

  ///灵感是否生成失败
  void briefGenerateFailed() {
    if (novelBean.value!.stage! == 3) {
      Get.dialog(NovelDialog(
        confirmText: '重新生成',
        content: '网络错误，灵感需要重新生成，\n生成失败不会消耗字数',
        onConfirm: () {
          retryBrief(novelBean.value!.id!);
        },
      ));
    }
  }

  ///写同款跳转
  void goWriteSame() {
    ///广场页写同款跳转至创作页
    EventTracking.reportDataPoint(
          pageTag: 'home_book_detail_same_btn',
          operateType: 'click',
          funcDetailImg: '',
          funcDetailTag: novelID.toString(),
          extra: {'source': source == NovelHomeSourceType.guide ? 2 : 1}
        );
    if (source == NovelHomeSourceType.square) {
      Get.toNamed(Routes.novelCreate, arguments: {
        'params': novelBean.value?.params,
        'func': novelBean.value?.func,
        'type': source,
        'id': novelID
      });
    } else if (source == NovelHomeSourceType.guide) {
      int novelID = 0;
      final provider = BriefDetailProvider();
      provider.source = source;
      provider.guideBriefContent = guideNovelBean.value?.briefContent ?? '';
      provider.guideBriefTitle = guideNovelBean.value?.briefTitle ?? '';
      ByNavRouterUtils.push(
        Get.context!,
        trackProviderPage(
          pageId: '/novel_brief_page',
          widget: ChangeNotifierProvider(
            create: (context) => provider,
            child: NovelBriefPage(
              novelID: novelID,
            ),
          ),
        ),
      );
    }
  }

  ///小说封面重新生成
  void redrawNovelCover() {
    Get.log("===novelBean=== ${novelBean.value!.toJson()}");
    Get.toNamed(
      Routes.novelCoverRedraw,
      arguments: {
        'cover': novelBean.value!.cover!,
        'id': novelBean.value!.id!,
        'module': module,
      },
    );
  }

  ///用户作品
  ///获取小说详情
  void fetchNovelDetail({
    bool isFirstLoad = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    if (isFirstLoad) {
      statusType.value = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      NovelApis.novelInfo,
      {'id': novelID},
      success: (data) {
        refreshSuccess(true, true);
        if (data['status'] == 200) {
          novelBean.value = NovelBean.fromJson(data['data']);

          ///管理页
          manager.bean = novelBean.value;
          manager.title.value = novelBean.value!.title!;

          update();

          ///小说完成时进行违禁词检测
          if (novelBean.value?.stage == 10) {
            manager.checkNovel();
          }
          briefGenerateFailed();
          statusType.value = MultiStatusType.statusContent;
          onSuccess?.call();
          fetchNovelInfoList();
        } else {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取章节细纲列表页
  void fetchNovelInfoList({
    bool? isReverse = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      NovelApis.novelDetailList,
      {
        'id': novelID,
        'page': pageHelper.page,
        'page_size': pageHelper.row,
        'order_type': isReverse! ? 'desc' : 'asc'
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]['data'] ?? [];
          List<ChapterBean> beans = List<ChapterBean>.from(items.map(
            (ele) => ChapterBean.fromJson(ele),
          ));
          if (pageHelper.page == 1) {
            itemList.value = beans;
            if (currentBean?.id != null &&
                currentBean!.id != itemList.first.id) {
              if (itemList.first.stage == 5) {
                itemList.removeAt(0);
              }
              itemList.insert(0, currentBean!);
            }
          } else {
            itemList.addAll(beans);
          }
          reverse.value = isReverse;
          pageHelper.addPage();
          final hasMore = beans.length < pageHelper.row ? false : true;
          refreshSuccess(false, hasMore);
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///非用户作品
  ///获取小说详情
  void fetchSquareNovelDetail({
    bool isFirstLoad = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    if (isFirstLoad) {
      statusType.value = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      NovelApis.novelSquareInfo,
      {'id': novelID},
      success: (data) {
        refreshSuccess(true, true);
        if (data['status'] == 200) {
          novelBean.value = NovelBean.fromSquareJson(data['data']);
          manager.title.value = novelBean.value!.title!;
          statusType.value = MultiStatusType.statusContent;
          fetchSquareNovelInfoList();
          onSuccess?.call();
        } else {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取章节细纲列表页
  void fetchSquareNovelInfoList({
    bool? isReverse = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      source == NovelHomeSourceType.guide
          ? NovelApis.novelGuideDetailList
          : NovelApis.novelSquareDetailList,
      {
        'id': novelID,
        'page': pageHelper.page,
        'page_size': pageHelper.row,
        'order_type': isReverse! ? 'desc' : 'asc'
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]['data'] ?? [];
          List<ChapterBean> beans = List<ChapterBean>.from(items.map(
            (ele) => ChapterBean.fromJson(ele),
          ));
          if (pageHelper.page == 1) {
            itemList.value = beans;
          } else {
            itemList.addAll(beans);
          }
          reverse.value = isReverse;
          pageHelper.addPage();
          final hasMore = beans.length < pageHelper.row ? false : true;
          refreshSuccess(false, hasMore);
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///暂停小说
  void pauseNovel({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    Get.dialog(NovelDialog(
      showCancelBtn: false,
      content: '断更当前生成的小说，预扣字数返还至账户余额，可随时重新开启创作~',
      cancelText: '确定断更',
      cancelTextColor: ByColorUtil.colorF1,
      confirmBgColor: ByColorUtil.colorBg4,
      confirmText: '取消',
      confirmTextColor: ByColorUtil.colorF1,
      cancelColor: ByColorUtil.colorG4,
      onCancel: () {
        LoadingDialog().show(message: '断更小说中...');
        HttpUtils.post(
          NovelApis.pauseNovel,
          {'id': novelID},
          success: (data) {
            LoadingDialog().dismiss();
            if (data['status'] == 200) {
              BotToast.showText(text: '小说已断更');
              fetchNovelDetail();
              onSuccess?.call();
            }
          },
          fail: (code, msg) {
            LoadingDialog().dismiss();
            BotToast.showText(text: msg);
          },
        );
      },
    ));
  }

  ///继续生成暂停小说
  void continuePausedNovel({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    LoadingDialog().show(message: '取消断更小说...');
    HttpUtils.post(
      NovelApis.continuePausedNovel,
      {'id': novelID},
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          fetchNovelDetail();
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取当前正在生成的章节数id
  void fetchGeneratingChapter({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      NovelApis.generatingChapter,
      {
        'id': novelID,
      },
      success: (data) {
        if (data['status'] == 200) {
          currentBean = ChapterBean.fromJson(data['data']);
          if (currentBean?.id != null) {
            if (itemList.isEmpty || itemList.first.id != currentBean?.id) {
              if (currentBean!.index! > 1) {
                ///如果当前生成的章节不是第一章，则将其插入到第一章之前
                itemList.insert(0, currentBean!);
              }

              ///检查小说状态
              checkNovelStatus();
            }
          }
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///引导页随机生成的小说
  void guideNovel({
    bool isFirstLoad = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    if (isFirstLoad) {
      statusType.value = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      NovelApis.guideNovel,
      {'novel_type': selectNovelType},
      success: (data) {
        if (data['status'] == 200) {
          novelBean.value =
              NovelBean.fromSquareJson(data['data']['novel_info']);
          manager.title.value = novelBean.value!.title!;
          statusType.value = MultiStatusType.statusContent;
          guideNovelBean.value =
              GuideNovelBean.fromJson(data['data']['guide_info']);
          novelID = guideNovelBean.value!.id!;
          fetchSquareNovelInfoList();
        } else {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///重新生成灵感
  void retryBrief(
    int novelID, {
    void Function()? success,
  }) {
    LoadingDialog().show(message: '灵感生成中...');
    HttpUtils.post(
      NovelApis.retryBrief,
      {'id': novelID},
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          success?.call();
        } else {
          BotToast.showText(text: '灵感生成失败');
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        if (code == 1003 && source != NovelHomeSourceType.guide) {
          ///如果是字数不够
          Get.back();
          Get.find<UserController>().jumpToPayPage(
            source: 'novel_home_brief_retry',
          );
        }
        BotToast.showText(text: msg);
      },
    );
  }

  /// [postion] banner所处的位置
  loadBanners({
    required int postion,
  }) {
    HttpUtils.get(
      APIs.homeBanner,
      {
        "postion": postion,
      },
      showMsgWhenFailed: false,
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        // byDebugPrint(data["item"], tag: "banner所处的位置");
        List<BannerBean> beans =
            bannerData.map((e) => BannerBean.fromJson(e)).toList();
        if (beans.isNotEmpty) {
          bannerList.value = [beans.first];
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///初始化数据
  void initData() {
    dynamic arguments = Get.arguments;
    if (arguments != null) {
      if (arguments["module"] != null) {
        module = arguments["module"];
      }
      Get.log("===module===  $module");
    }
  }

  /// 重新加载整个页面（使用保存的路由参数）
  void reloadEntirePage() {
    if (_originalArguments != null) {
      // 使用保存的参数重新初始化控制器属性
      final args = _originalArguments!;
      final id = args['id'];

      // 更新控制器属性
      if (id != null) {
        novelID = id;
      }
      if (args["module"] != null) {
        module = args["module"];
      }

      // 重新初始化数据
      initData();

      // 重新加载启动数据
      fetchLaunchData();
    } else {
      // 如果没有保存的参数，只刷新小说详情
      fetchNovelDetail();
    }
  }
}
