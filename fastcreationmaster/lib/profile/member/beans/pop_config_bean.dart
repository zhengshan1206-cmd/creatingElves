/*
 * @Author: duncy
 * @Date: 2026-06-05 10:45:10
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-06-05 10:45:25
 * @FilePath: /fastcreationmaster/lib/profile/member/beans/pop_config_bean.dart
 * @Description: 
 */
import 'dart:convert';

import 'package:fast_creation_master/profile/member/beans/vip_type_bean.dart';

PopConfigBean popConfigBeanFromJson(String str) =>
    PopConfigBean.fromJson(json.decode(str));

String popConfigBeanToJson(PopConfigBean data) => json.encode(data.toJson());

class PopConfigBean {
  int id;
  String title;
  int adLinkType;
  String times;
  int popType;
  String img;
  String popBtnTitle;
  int vipId;
  String closeBtnType;
  int popUpId;
  int status;
  int orderNum;
  DateTime updatedAt;
  DateTime createdAt;
  String minTimes;
  String maxTimes;
  List<VipTypeBean> vipInfo;
  int maxShowLimit;

  PopConfigBean({
    required this.id,
    required this.title,
    required this.adLinkType,
    required this.times,
    required this.popType,
    required this.img,
    required this.popBtnTitle,
    required this.vipId,
    required this.closeBtnType,
    required this.popUpId,
    required this.status,
    required this.orderNum,
    required this.updatedAt,
    required this.createdAt,
    required this.minTimes,
    required this.maxTimes,
    required this.vipInfo,
    required this.maxShowLimit,
  });

  factory PopConfigBean.fromJson(Map<String, dynamic> json) => PopConfigBean(
        id: json["id"],
        title: json["title"],
        adLinkType: json["ad_link_type"],
        times: json["times"],
        popType: json["pop_type"],
        img: json["img"],
        popBtnTitle: json["pop_btn_title"],
        vipId: json["vip_id"],
        closeBtnType: json["close_btn_type"],
        popUpId: json["pop_up_id"],
        status: json["status"],
        orderNum: json["order_num"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        minTimes: json["min_times"],
        maxTimes: json["max_times"],
        vipInfo: List<VipTypeBean>.from(
          json["vip_info"].map((x) => VipTypeBean.fromJson(x)),
        ),
        maxShowLimit: json["max_show_limit"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "ad_link_type": adLinkType,
        "times": times,
        "pop_type": popType,
        "img": img,
        "pop_btn_title": popBtnTitle,
        "vip_id": vipId,
        "close_btn_type": closeBtnType,
        "pop_up_id": popUpId,
        "status": status,
        "order_num": orderNum,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "min_times": minTimes,
        "max_times": maxTimes,
        "vip_info": List<dynamic>.from(vipInfo.map((x) => x.toJson())),
        "max_show_limit": maxShowLimit,
      };
}
