/// 小说通知响应模型
class NovelNotifyResponse {
  final int status;
  final String message;
  final List<NovelNotifyItem>? data;

  NovelNotifyResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory NovelNotifyResponse.fromJson(Map<String, dynamic> json) {
    return NovelNotifyResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => NovelNotifyItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

/// 小说通知项模型
class NovelNotifyItem {
  final String complete;
  final List<TextPattern> pattern;

  NovelNotifyItem({
    required this.complete,
    required this.pattern,
  });

  factory NovelNotifyItem.fromJson(Map<String, dynamic> json) {
    return NovelNotifyItem(
      complete: json['complete'] ?? '',
      pattern: json['pattern'] != null
          ? (json['pattern'] as List)
              .map((item) => TextPattern.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'complete': complete,
      'pattern': pattern.map((item) => item.toJson()).toList(),
    };
  }
}

/// 文本模式模型
class TextPattern {
  final String text;
  final TextStyle style;

  TextPattern({
    required this.text,
    required this.style,
  });

  factory TextPattern.fromJson(Map<String, dynamic> json) {
    return TextPattern(
      text: json['text'] ?? '',
      style: TextStyle.fromJson(json['style'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'style': style.toJson(),
    };
  }
}

/// 文本样式模型
class TextStyle {
  final String color;
  final bool isBold;

  TextStyle({
    required this.color,
    required this.isBold,
  });

  factory TextStyle.fromJson(Map<String, dynamic> json) {
    return TextStyle(
      color: json['color'] ?? '#000000',
      isBold: json['is_bold'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'is_bold': isBold,
    };
  }
}
