// To parse this JSON data, do
//
//     final zoneMenusBean = zoneMenusBeanFromJson(jsonString);

import 'dart:convert';

ZoneMenusBean zoneMenusBeanFromJson(String str) =>
    ZoneMenusBean.fromJson(json.decode(str));

String zoneMenusBeanToJson(ZoneMenusBean data) => json.encode(data.toJson());

class ZoneMenusBean {
  int id;
  String title;
  String iconUrl;
  String? bgUrl;
  String? key;

  ZoneMenusBean({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.bgUrl,
    required this.key,
  });

  factory ZoneMenusBean.fromJson(Map<String, dynamic> json) => ZoneMenusBean(
      id: json["id"],
      title: json["title"],
      iconUrl: json["icon_url"],
      bgUrl: json["bg_url"],
      key: json["key"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "icon_url": iconUrl,
        "bg_url": bgUrl,
        "key": key,
      };
}
