
class NotPayOrderModel {
  final int status;
  final String message;
  final NotPayOrderData data;

  NotPayOrderModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotPayOrderModel.fromJson(Map<String, dynamic> json) {
    return NotPayOrderModel(
      status: json['status'] as int,
      message: json['message'] as String,
      data: NotPayOrderData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class NotPayOrderData {
  final int status;
  final NotPayOrderParams params;

  NotPayOrderData({
    required this.status,
    required this.params,
  });

  factory NotPayOrderData.fromJson(Map<String, dynamic> json) {
    return NotPayOrderData(
      status: json['status'] as int,
      params: NotPayOrderParams.fromJson(json['params'] as Map<String, dynamic>),
    );
  }
}

class NotPayOrderParams {
  final int orderId;
  final int createdAt;
  final int expireTime;

  NotPayOrderParams({
    required this.orderId,
    required this.createdAt,
    required this.expireTime,
  });

  factory NotPayOrderParams.fromJson(Map<String, dynamic> json) {
    return NotPayOrderParams(
      orderId: json['order_id'] as int,
      createdAt: json['created_at'] as int,
      expireTime: json['expire_time'] as int,
    );
  }
}