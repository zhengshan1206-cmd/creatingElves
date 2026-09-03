
class NovelContinueWriteModel {
  final int? status;
  final String? message;
  final NovelContinueWriteData? data;

  NovelContinueWriteModel({
    this.status,
    this.message,
    this.data,
  });

  factory NovelContinueWriteModel.fromJson(Map<String, dynamic> json) {
    return NovelContinueWriteModel(
      status: json['status'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null ? NovelContinueWriteData.fromJson(json['data'] as Map<String, dynamic>) : null,
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

class NovelContinueWriteData {
  final int? giftWordPack;
  final List<LongNovelContinue>? longNovelContinue;

  NovelContinueWriteData({
    this.giftWordPack,
    this.longNovelContinue,
  });

  factory NovelContinueWriteData.fromJson(Map<String, dynamic> json) {
    var longNovelContinueList = json['long_novel_continue'] as List?;
    List<LongNovelContinue>? items;

    if (longNovelContinueList != null) {
      items = longNovelContinueList
          .map((i) => LongNovelContinue.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return NovelContinueWriteData(
      giftWordPack: json['gift_word_pack'] as int?,
      longNovelContinue: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gift_word_pack': giftWordPack,
      'long_novel_continue': longNovelContinue?.map((e) => e.toJson()).toList(),
    };
  }
}

class LongNovelContinue {
  final String? value;
  final String? key;

  LongNovelContinue({
    this.value,
    this.key,
  });

  factory LongNovelContinue.fromJson(Map<String, dynamic> json) {
    return LongNovelContinue(
      value: json['value'] as String?,
      key: json['key'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'key': key,
    };
  }
}
