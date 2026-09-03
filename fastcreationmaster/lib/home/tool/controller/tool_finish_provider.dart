import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/aes/byhy_aes_storage_utils.dart';
import 'package:byhy_app_common_utils/app_common/aes/byhy_encrypt_utils.dart';
import 'package:byhy_app_common_utils/app_common/consts/const_keys.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:byhy_app_common_utils/app_http/intercept.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fast_creation_master/core/util/extention.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/home/tool/bean/tool_bean.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

import '../../../core/controller/base_record_controller.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/network/result.dart';
import '../../../core/service/app_review_service.dart';
import '../../../global/routes/routes_utils.dart';

// 扩展方法,寻找《》中的标题
extension StringExtension on String {
  String? getFirstContentInBrackets() {
    RegExp regExp = RegExp(r'《([^》]*)》');
    Match? match = regExp.firstMatch(this);
    return match?.group(1);
  }
}

///小说，文案完成页
class ToolFinishProvider extends ChangeNotifier {
  ///创建ID
  int? creationID;

  ///创建类型
  CreationType? type;

  ///是否是生成页面流式输出
  bool? isStreaming;

  ///当前流式输出内容
  String content = '';

  ///生成标题
  String title = '';

  ///是否正在生成
  bool isGenerating = false;

  ///生成进度
  double progress = 0.0;

  ///流式消息订阅
  StreamSubscription<String>? messageSubscription;

  ///滚动控制器
  ScrollController scrollController = ScrollController();

  ///创建生成的内容数据
  ToolBean? bean;

  ///轮循接口间隔时间
  int second = 5;

  ///页面状态
  MultiStatusType statusType = MultiStatusType.statusContent;

  ///网络连接状态监听
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void dispose() {
    messageSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  // 初始化监听
  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });
  }

  // 处理网络变化
  void _handleConnectivityChange(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      if(isGenerating) {
        BotToast.showText(text: '网络连接已断开，流式输出已暂停');
      }
    } else {
      // 恢复在线功能
    }
  }

  ///更新生成进度
  void updateProgress() {
    if (bean?.submitWordsNum != null) {
      if (bean!.submitWordsNum! > 0) {
        double t = content.length / bean!.submitWordsNum!;

        ///进度控制在99%
        if (t > 0 && t < 0.99) {
          progress = ((t * 100).round()) / 100; //进度保留两位小数
        }
      }
    }
  }

  ///更新文案与内容
  void updateContent(String newString) {
    ///短故事截取标题
    if (type == CreationType.folkNovel) {
      String tmpContnet = content + newString;
      String tmpTitle = tmpContnet.getFirstContentInBrackets() ?? '';
      if (title.isEmpty && tmpTitle.isNotEmpty) {
        title = tmpTitle;
        content = tmpContnet.replaceFirst('《$tmpTitle》', '').trim();
      } else {
        content = tmpContnet.trimLeft();
      }
    } else {
      content += newString;
    }
    notifyListeners();
  }

  ///判断流式输出条件
  void canStream() {
    if ([1, 2].contains(bean?.status)) {
      ///内容在生成中并且没有流式输出时，延迟加载数据内容
      if (bean?.canStream == 2) {
        delayLoading();
      } else {
        // 如果允许流式输出，开始获取流式内容
        statusType = MultiStatusType.statusContent;
        fetchContentGeneration(creationID!);
      }
    } else {
      ///流式输出完成时，app评分
      AppReviewService.requestReview();
      statusType = MultiStatusType.statusContent;
    }
  }

  ///延迟加载内容
  void delayLoading({int? delayed}) {
    Future.delayed(Duration(seconds: delayed ?? second), fetchContent);
  }

  ///获取AI创作内容
  void fetchContent() async {
    statusType = MultiStatusType.statusLoading;
    HttpUtils.get(
      NovelApis.textDetail,
      {
        "func": type!.name, // 使用传入的 type
        "ai_essay_id": creationID, // 使用传入的 creationID
      },
      success: (data) {
        if (data['status'] == 200) {
          bean = ToolBean.fromJson(data["data"]);
          content = bean?.content ?? '';
          title = bean?.title ?? '';
          canStream();
          notifyListeners();
        } else {
          statusType = MultiStatusType.statusNoNetWork;
          notifyListeners();
        }
      },
      fail: (code, msg) {
        statusType = MultiStatusType.statusNoNetWork;
        notifyListeners();
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取流式内容
  void fetchContentGeneration(int id) async {
    Map<String, dynamic> params = {
      "ai_essay_id": id, //id
      "func": type!.name, // 使用传入的 type
    };
    isGenerating = true;
    messageSubscription?.cancel();

    final stream = await getStream(
        // url: BuildConfig.instance.environment.domain + API.folkStoryThemeAutoGenerate.path,
        url: APIs.apiPrefix + NovelApis.toolStreaming,
        body: params);
    messageSubscription = stream.listen((data) {
      updateProgress();
      updateContent(data);
      _scrollToBottom();
    }, onDone: () {
      print('流式输出完成________=====>>>>>');
      isGenerating = false;
      notifyListeners();
      messageSubscription?.cancel();
      ///流式输出完成时，app评分
      AppReviewService.requestReview();
      Future.delayed(const Duration(milliseconds: 70), _scrollToBottom);
    }, onError: (error) {
      if (error is APIError) {
        BotToast.showText(text: error.message);
        isGenerating = false;
        notifyListeners();
        messageSubscription?.cancel();
      }
    });
  }

  void _scrollToBottom() {
    // 确保在下一帧滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<Stream<String>> getStream({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final controller = StreamController<String>();
    final uri = Uri.parse(url);

    final request = http.Request('POST', uri);
    _updateHeaders(request);

    if (body != null && body.isNotEmpty) {
      request.bodyFields = body.convertMap();
    }
    request.send().then((http.StreamedResponse response) async {
      // 处理响应
      if (response.statusCode == 200) {
        await for (String chunk in response.stream.transform(utf8.decoder)) {
          controller.add(chunk);
        }
        controller.close();
      } else {
        controller.addError(
            APIError(response.reasonPhrase ?? '', response.statusCode));
      }
    });

    return controller.stream;
  }

  void _updateHeaders(http.Request request) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    request.headers[ConstKeys.kToken] = getToken();
    request.headers[ConstKeys.kClientType] = "strong";
    request.headers[ConstKeys.kTimeStamp] = timestamp.toString();
    request.headers[ConstKeys.kAppFramework] = 'flutter';
    request.headers[ConstKeys.kAppVersion] =
        ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0";
    request.headers[ConstKeys.kSign] = _getSign(timestamp);
  }

  String _getSign(int timestamp) {
    final token = ByAESStorageUtils.getString(ConstKeys.kToken) ?? "";
    final sign = ByEncryptUtils.md5String("$timestamp$token");
    return sign;
  }

  ///继续创作 - 跳转到对应的创作页面
  void continueCreation() {
    // 使用安全方案：回到主页面，然后跳转到创作页面
    NavigateUtils.navigateToPageAfterBacktoMain(Routes.toolCreation, {
                          'novel_type': type,
                        });
  }
}
