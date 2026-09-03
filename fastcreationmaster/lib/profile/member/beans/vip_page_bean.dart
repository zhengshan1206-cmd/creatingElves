class VipPageBean {
  String kfUrl = "";
  VipPageUser user =
      VipPageUser(protocolUrl: "", subScribeProtocolUrl: "", integralRule: "", inform: '');
  String retainWindowUrl = "";

  VipPageBean({
    required this.kfUrl,
    required this.user,
    required this.retainWindowUrl,
  });

  factory VipPageBean.fromJson(Map<String, dynamic> json) => VipPageBean(
        kfUrl: json["kf_url"] ?? "",
        user: VipPageUser.fromJson(json["user"]),
        retainWindowUrl: json["retain_window_url"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "kfUrl": kfUrl,
        "user": user,
        "retainWindowUrl": retainWindowUrl,
      };
}

class VipPageUser {
  String protocolUrl = "";
  String subScribeProtocolUrl = "";
  String integralRule = "";
  String inform = "";///说明

  VipPageUser({
    required this.protocolUrl,
    required this.subScribeProtocolUrl,
    required this.integralRule,
    required this.inform,
  });

  factory VipPageUser.fromJson(Map<String, dynamic> json) => VipPageUser(
        protocolUrl: json["protocol_url"],
        subScribeProtocolUrl: json["subscribe_protocol_url"],
        integralRule: json["integral_rule"],
        inform: json['inform'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "protocolUrl": protocolUrl,
        "subscribe_protocol_url": subScribeProtocolUrl,
        "integral_rule": integralRule,
        'inform': inform
      };
}

///付费页运营位
class VipOperationBean {
  String title = ""; ///标题
  String subTitle = "";  ///副标题
  String content = "";  ///内容
  int picType = 1; ///图片显示类型
  List<String> pics = []; ///图片

  VipOperationBean({
    required this.title,
    required this.subTitle,
    required this.content,
    required this.picType,
    required this.pics,
  });

  factory VipOperationBean.fromJson(Map<String, dynamic> json) => VipOperationBean(
        title: json["title"],
        subTitle: json["sub_title"],
        content: json["content"],
        picType: json['pics_show_type'],
        pics: List<String>.from(json["pics"]?.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "sub_title": subTitle,
        "integral_rule": content,
        'pics_show_type': picType,
        'pics': List<String>.from(pics.map((x) => x)),
      };
}
