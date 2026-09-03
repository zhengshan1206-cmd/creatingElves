// To parse this JSON data, do
//
//     final userMenusBean = userMenusBeanFromJson(jsonString);

import 'dart:convert';

UserMenusBean userMenusBeanFromJson(String str) =>
    UserMenusBean.fromJson(json.decode(str));

String userMenusBeanToJson(UserMenusBean data) => json.encode(data.toJson());

class UserMenusBean {
  String title;
  String url;

  UserMenusBean({
    required this.title,
    required this.url,
  });

  factory UserMenusBean.fromJson(Map<String, dynamic> json) => UserMenusBean(
        title: json["title"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "url": url,
      };
}
