/*
 * @Author: cold-x
 * @Date: 2025-06-18 16:53:30
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-07 15:28:54
 * @FilePath: /fastcreationmaster/lib/global/other/illegal_words/bean/illegal_words_bean.dart
 * @Description: 
 */


import 'dart:convert';

TextRiskBean textRiskBeanFromJson(String str) =>
    TextRiskBean.fromJson(json.decode(str));

String textRiskBeanToJson(TextRiskBean data) => json.encode(data.toJson());

class TextRiskBean {
  bool isRisk;
  List<String> labelName;
  String markContent;

  TextRiskBean({
    required this.isRisk,
    required this.labelName,
    required this.markContent,
  });

  factory TextRiskBean.fromJson(Map<String, dynamic> json) => TextRiskBean(
        isRisk: json["isRisk"] ?? false,
        labelName: List<String>.from((json["labelName"] ?? []).map((x) => x)),
        markContent: json["markContent"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "isRisk": isRisk,
        "labelName": List<dynamic>.from(labelName.map((x) => x)),
        "markContent": markContent,
      };
}


class NovelIllegalWordsBean {
  int? id; ///章节id
  String? title;  ///章节标题
  int? index;  ///章节序列号
  String? cnCode; ///章节序列号中文版
  int? wordsCount; ///违禁词个数
  List<String>? words; ///违禁词

  NovelIllegalWordsBean({
    this.id,
    this.title,
    this.index,
    this.cnCode,
    this.wordsCount,
    this.words
  });

  factory NovelIllegalWordsBean.fromJson(Map<String, dynamic> json) => NovelIllegalWordsBean(
        id: json["id"],
        title: json["chapter_overview_title"] ?? "",
        index: json['index'],
        cnCode: json['cn_code'],
        wordsCount: json['forbidden_num'],
        words: List<String>.from((json["check_result"] ?? []).map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "chapter_overview_title": title,
        'index': index,
        'cn_code': cnCode,
        'forbidden_num': wordsCount,
        'check_result': List<dynamic>.from(words!.map((x) => x)),
      };
}
