/*
 * @Author: cold-x
 * @Date: 2025-06-11 15:49:14
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-14 14:28:48
 * @FilePath: /fastcreationmaster/lib/home/tool/bean/tool_bean.dart
 * @Description: 
 */



class ToolBean {
  int? id; ///id
  String? title; ///标题
  String? content; ///内容
  int? word; //总字数
  int? submitWordsNum; ///预设的提交字数
  String? createTime; ///创建时间
  String? createDate; ///创建日期
  int? status; ///状态 1=已提交 2=生成中 3=成功 4=失败
  int? canStream; ///是否允许流式输出
  List<String>? tag; ///标签

  ToolBean({
    this.id,
    this.title,
    this.content,
    this.word,
    this.submitWordsNum,
    this.createTime,
    this.status,
    this.canStream,
    this.tag,
    this.createDate
  });

  factory ToolBean.fromJson(Map<String, dynamic> json) {
    return ToolBean(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      word: json['word'],
      submitWordsNum: json['sub_work_num'],
      createTime: json['created_at'],
      createDate: json['date'],
      status: json['stage'],
      canStream: json['is_allow_stream'],
      tag: json["tag"] == null
            ? []
            : List<String>.from(json["tag"]!.map((x) => x)),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'word': word,
      'date': createDate,
      'sub_work_num': submitWordsNum,
      'created_at': createTime,
      'stage': status,
      'is_allow_stream': canStream,
      "tag": tag == null ? [] : List<dynamic>.from(tag!.map((x) => x)),
    };
  }


  ///骨架测试数据
  factory ToolBean.initSkeletonizer() {
    return ToolBean(
      id: 0,
      title: '标题测试数据',
      content: '测试数据内容',
      word: 111,
      submitWordsNum: 222,
      createTime: '',
      status: 1,
      createDate: '',
      canStream: 2,
      tag: ['测试','通用','测试2'],
    );
  }

}