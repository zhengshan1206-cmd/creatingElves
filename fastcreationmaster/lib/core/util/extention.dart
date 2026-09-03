/*
 * @Author: cold-x
 * @Date: 2025-06-11 13:34:55
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-05 17:01:53
 * @FilePath: /fastcreationmaster/lib/core/util/extention.dart
 * @Description: 
 */
import 'dart:convert';

extension MapExtension on Map<String, dynamic> {
  void setIfNotNull({required dynamic value, required String key}) {
    if (value != null) {
      this[key] = value;
    }
  }

  Map<String, String> convertMap(){
    return Map.fromEntries(
        entries
            .where((entry) => entry.value != null)
            .map((entry) => MapEntry(entry.key, entry.value is String ? entry.value : jsonEncode(entry.value)))
    );
  }
}

extension OptionalEmptyExpression on String? {
  bool isEmptyString() {
    return isEmpty(this);
  }

  bool isNotEmptyString() {
    return isNotEmpty(this);
  }

  static bool isEmpty(String? text) {
    if (text == null) {
      return true;
    }
    return text.isEmpty;
  }

  static bool isNotEmpty(String? text) {
    if (text == null) {
      return false;
    }
    return text.isNotEmpty;
  }
}
