
class NotPayOrderInfoResponse {
  final int status;
  final String message;
  final NotPayOrderInfoData data;

  NotPayOrderInfoResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotPayOrderInfoResponse.fromJson(Map<String, dynamic> json) {
    return NotPayOrderInfoResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: NotPayOrderInfoData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class NotPayOrderInfoData {
  final int id;
  final int configId;
  final String pay;
  final int vipConfigVersionId;
  final String appleVipId;
  final int payPageId;

  NotPayOrderInfoData({
    required this.id,
    required this.configId,
    required this.pay,
    required this.vipConfigVersionId,
    required this.appleVipId,
    required this.payPageId,
  });

  factory NotPayOrderInfoData.fromJson(Map<String, dynamic> json) {
    return NotPayOrderInfoData(
      id: json['id'] as int,
      configId: json['config_id'] as int,
      pay: json['pay'] as String,
      vipConfigVersionId: json["vip_config_version_id"] as int,
      appleVipId: json["apple_vip_id"]??"",
      payPageId: json["pay_page_id"]??0,
    );
  }
}
