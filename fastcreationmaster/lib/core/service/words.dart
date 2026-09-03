/*
 * @Author: cold-x
 * @Date: 2025-06-14 17:36:06
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-05 17:17:46
 * @FilePath: /fastcreationmaster/lib/core/service/words.dart
 * @Description: 
 */


///字数显示服务
class WordsService {
  static String wordsDisplay (String words, {String unit = 'w', bool showIntegal = false}) {
    ///字数转化为数字
    int number = 0;
    try {
      number = int.parse(words);
    } catch (e) {
      return words;
    }
    if (number >= 10000){
      if(showIntegal) {
        final tmp = (number/10000).round();
        return '$tmp$unit';
      }
      ///保留一位小数
      final tmp = (number/1000).round()/10;
      return '$tmp$unit';
    }
    return '$number';
  }
}