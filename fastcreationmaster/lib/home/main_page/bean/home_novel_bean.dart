/*
 * @Author: cold-x
 * @Date: 2025-06-26 14:24:31
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-11 17:34:10
 * @FilePath: /fastcreationmaster/lib/home/main_page/bean/home_novel_bean.dart
 * @Description: 
 */



class HomeNovelBean {
  int? id; ///小说id
  String? title; ///小说标题
  int? novelID; ///小说ID
  String? cover; ///封面图
  String? createTime; ///创建时间
  int? viewNum; ///阅读数
  int? writeNum; ///写同款数
  List<dynamic>? tags; ///小说标签列表  1=普通 2=热门 3=最新
  dynamic progress; ///生成进度

  HomeNovelBean({
    this.id,
    this.title,
    this.viewNum,
    this.writeNum,
    this.novelID,
    this.createTime,
    this.cover,
    this.tags,
    this.progress,
  });

  factory HomeNovelBean.fromJson(Map<String, dynamic> json) {
    return HomeNovelBean(
      id: json['id'],
      title: json['title'] ?? '',
      viewNum: json['all_read_num'],
      writeNum: json['all_writes_num'],
      novelID: json['ai_novel_id'],
      createTime: json['created_at'],
      cover: json['cover'],
      tags: json["tag"] ?? ['1'],
      progress: json['progress'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'all_read_num': viewNum,
      'ai_novel_id': novelID,
      'created_at': createTime,
      'all_writes_num': writeNum,
      'cover': cover,
      "tags": tags,
      'progress': progress,
    };
  }

  ///骨架测试数据
  factory HomeNovelBean.initSkeletonizer() {
    return HomeNovelBean(
      id: 0,
      title: '标题测试数据',
      createTime: '',
      viewNum: 2000,
      writeNum: 1000,
      novelID: 1,
      cover: 'http://gamecdn.beiyinapp.com/inchat/wujie/2023-07-07/487f3788dc4245c5f072f7a893d29c4b.webp',
      tags: ['1'],
    );
  }
}