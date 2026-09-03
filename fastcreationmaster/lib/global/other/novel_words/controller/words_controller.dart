/*
 * @Author: cold-x
 * @Date: 2025-07-01 14:25:26
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-25 11:16:35
 * @FilePath: /fastcreationmaster/lib/global/other/novel_words/controller/words_controller.dart
 * @Description: 
 */

import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/words.dart';
import 'package:fast_creation_master/global/other/novel_words/bean/words_bean.dart';
import 'package:fast_creation_master/profile/profile_controller.dart';
import 'package:get/get.dart';

import '../../../../core/network/novel_apis.dart';

enum WordsType {
  total,

  ///总字数

  brief,

  ///灵感页

  outline,

  ///大纲页

  chapter,

  ///章节页
}

///用于字数显示和计算
class WordsController extends GetxController {
  WordsBean? words; ///小说字数配置
  WordsBean? shortStoryWords; ///短故事小数配置

  final userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    getWordsConfig();
    getShortStoryWordsConfig();
  }

  ///用户字数是否足够
  bool isWordsEnable(WordsType type, int chapterNum,
      {bool showPayPage = false, CreationType novelType = CreationType.novel}) {
    ProfileController user = Get.find<ProfileController>();
    int word = _getWords(type, chapterNum, novelType: novelType);
    int? userWords;
    try {
      userWords = int.parse(user.getUserWords(needDetail: true));
    } catch (e) {
      userWords = 0;
    }

    ///字数不够,进入付费页
    if (userWords <= word) {
      if (user.userInfo?.isVip == 0) {
        // Get.toNamed(Routes.memberCenter);
        if(showPayPage) {
          userController.jumpToPayPage(source: 'words_unable');
        }
        return false;
      }
      return false;
    }
    return true;
  }

  ///获取消耗字数的显示
  String getWords(WordsType type, int chapterNum, {CreationType novelType = CreationType.novel}) {
    int word = _getWords(type, chapterNum, novelType: novelType);
    return WordsService.wordsDisplay('$word');
  }

  ///获取消耗字数的显示
  int _getWords(WordsType type, int chapterNum, {CreationType novelType = CreationType.novel}) {
    if (novelType != CreationType.shortStory && (words == null || chapterNum <= 0)) {
      return 0;
    }
    if ((shortStoryWords == null && novelType == CreationType.shortStory)) {
      return 0;
    }
    int word = 0;
    switch (type) {
      case WordsType.total:
        word = getNovelTotalWords(chapterNum, novelType: novelType);
        break;
      case WordsType.brief:
        word = getBriefWords(chapterNum, novelType: novelType);
        break;
      case WordsType.outline:
        word = getOutlineWords(chapterNum);
        break;
      case WordsType.chapter:
        word = getChapterWords(chapterNum);
        break;
    }
    return word;
  }

  ///获取小说预估总字数展示
  int getNovelTotalWords(int chapterNum, {CreationType novelType = CreationType.novel}) {
    ///短故事
    if(novelType == CreationType.shortStory) {
      ///charpterNum == 0时关闭深度思考， -1开启深度思考
      return shortStoryWords!.brief! + shortStoryWords!.introduce! + (chapterNum == 0 ? 0 : shortStoryWords!.briefThinking!);
    }
    ///总字数 = 灵感字数 + 简介字数 + 大纲总字数 + 细纲总字数 + 正文总字数
    ///大纲总字数 = 大纲数量 * 每一个大纲字数
    ///大纲数量 = 章节数量 / 36   向上取整
    ///细纲总字数 = 章节数量 * 每一个细纲字数
    ///正文总字数 = 章节数量 * 每一个正文字数
    final int outlineNum = (chapterNum / 36).ceil();
    final int wordsTotal = words!.brief! +
        words!.introduce! +
        words!.outline! * outlineNum +
        words!.chapter! * chapterNum +
        words!.novel! * chapterNum;
    return wordsTotal;
  }

  ///获取灵感后续预估总字数展示
  int getBriefWords(int chapterNum, {CreationType novelType = CreationType.novel}) {
    ///短故事
    if(novelType == CreationType.shortStory) {
      return shortStoryWords!.novel! * chapterNum;
    }
    ///总字数 = 简介字数 + 大纲总字数 + 细纲总字数 + 正文总字数
    ///大纲总字数 = 大纲数量 * 每一个大纲字数
    ///大纲数量 = 章节数量 / 36   向上取整
    ///细纲总字数 = 章节数量 * 每一个细纲字数
    ///正文总字数 = 章节数量 * 每一个正文字数
    final int outlineNum = (chapterNum / 36).ceil();
    final int wordsTotal = words!.introduce! +
        words!.outline! * outlineNum +
        words!.chapter! * chapterNum +
        words!.novel! * chapterNum;
    return wordsTotal;
  }

  ///获取大纲后续预估总字数展示
  int getOutlineWords(int chapterNum) {
    ///总字数 = 细纲总字数 + 正文总字数
    ///细纲总字数 = 章节数量 * 每一个细纲字数
    ///正文总字数 = 章节数量 * 每一个正文字数
    final int wordsTotal =
        words!.chapter! * chapterNum + words!.novel! * chapterNum;
    return wordsTotal;
  }

  ///获取选取的正文后续预估总字数展示
  int getChapterWords(int chapterNum) {
    ///总字数 = 正文总字数
    final int wordsTotal = words!.novel! * chapterNum;
    return wordsTotal;
  }

  ///获取字数配置
  void getWordsConfig({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.post(
      NovelApis.novelWords,
      {
        'chapter_count': 100,
      },
      success: (data) {
        if (data['status'] == 200) {
          onSuccess?.call();
          words = WordsBean.fromJson(data['data']);
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
      },
    );
  }

  ///获取短故事小说字数配置
  void getShortStoryWordsConfig({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.post(
      NovelApis.shortStoryWords,
      {},
      success: (data) {
        if (data['status'] == 200) {
          onSuccess?.call();
          shortStoryWords = WordsBean.fromJson(data['data']);
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
      },
    );
  }
}
