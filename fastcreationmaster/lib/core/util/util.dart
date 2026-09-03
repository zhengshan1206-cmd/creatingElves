/*
 * @Author: cold-x
 * @Date: 2025-05-30 12:16:44
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-16 13:54:30
 * @FilePath: /fastcreationmaster/lib/core/util/util.dart
 * @Description: 
 */


import 'dart:math';

class Util {

  // 生成 [min, max) 范围内的随机整数（不包含 max）
  static int randomInt(int min, int max) {
  if (min >= max) return min;
  return min + Random().nextInt(max - min);
}
}