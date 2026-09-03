// To parse this JSON data, do
//
//     final strategyListBean = strategyListBeanFromJson(jsonString);

import 'dart:convert';

StrategyListBean strategyListBeanFromJson(String str) =>
    StrategyListBean.fromJson(json.decode(str));

String strategyListBeanToJson(StrategyListBean data) =>
    json.encode(data.toJson());

class StrategyListBean {
  int id;
  String name;
  int isFree;
  String describe;
  String iconUrl;
  String authorName;
  int showNumber;
  String createdAt;

  String wechat;
  String authorAvatar;
  StrategyListBean({
    required this.id,
    required this.name,
    required this.isFree,
    required this.describe,
    required this.iconUrl,
    required this.authorName,
    required this.showNumber,
    required this.wechat,
    required this.authorAvatar,
    required this.createdAt,
  });

  factory StrategyListBean.fromJson(Map<String, dynamic> json) =>
      StrategyListBean(
        id: json["id"],
        name: json["name"],
        isFree: json["is_free"],
        describe: json["describe"],
        iconUrl: json["icon_url"],
        authorName: json["author_name"],
        showNumber: json["show_number"],
        wechat: json["wechat"],
        authorAvatar: json["author_avatar"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "is_free": isFree,
        "describe": describe,
        "icon_url": iconUrl,
        "author_name": authorName,
        "show_number": showNumber,
        "wechat": wechat,
        "authorAvatar": authorAvatar,
        "created_at": createdAt,
      };
}
