class NovelCoverResponse {
  final int? status;
  final String? message;
  final NovelCoverData? data;

  NovelCoverResponse({
    this.status,
    this.message,
    this.data,
  });

  factory NovelCoverResponse.fromJson(Map<String, dynamic> json) {
    return NovelCoverResponse(
      status: json['status'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null ? NovelCoverData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class NovelCoverData {
  final int? maxNum;
  final List<NovelCoverItem>? list;

  NovelCoverData({
    this.maxNum,
    this.list,
  });

  factory NovelCoverData.fromJson(Map<String, dynamic> json) {
    var listData = json['list'] as List?;
    List<NovelCoverItem> items = [];
    if (listData != null) {
      items = listData.map((i) => NovelCoverItem.fromJson(i)).toList();
    }

    return NovelCoverData(
      maxNum: json['max_num'] as int?,
      list: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_num': maxNum,
      'list': list?.map((item) => item.toJson()).toList(),
    };
  }
}

class NovelCoverItem {
  final int? id;
  final int? type;
  final int? audit;
  final int? status;
  final String? coverUrl;
  final bool? selected;

  NovelCoverItem({
    this.id,
    this.type,
    this.audit,
    this.status,
    this.coverUrl,
    this.selected,
  });

  factory NovelCoverItem.fromJson(Map<String, dynamic> json) {
    return NovelCoverItem(
      id: json['id'] as int?,
      type: json['type'] as int?,
      audit: json['audit'] as int?,
      status: json['status'] as int?,
      coverUrl: json['cover_url'] as String?,
      selected: json['selected'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'audit': audit,
      'status': status,
      'cover_url': coverUrl,
      'selected': selected,
    };
  }
}
