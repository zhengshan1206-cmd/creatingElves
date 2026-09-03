import 'package:flutter/material.dart';
import '../../service/page_route_service.dart';

/// Provider 页面检测工具
class ProviderPageDetector {
  /// 检测 Widget 是否为 Provider 页面
  /// [widget] 要检测的 Widget
  /// 返回 Provider 页面标识，如果不是 Provider 页面则返回 null
  static String? detectProviderPage(Widget widget) {
    return _findProviderPageWidget(widget);
  }

  /// 递归查找 Provider 页面 Widget
  /// [widget] 要检查的 Widget
  static String? _findProviderPageWidget(Widget widget) {
    final String className = widget.runtimeType.toString();

    // 直接检查是否为 Provider 页面
    final String? providerId =
        PageRouteService.getProviderPageIdentifier(className);
    if (providerId != null) {
      return providerId;
    }

    // 检查包装器类型
    final List<String> wrapperTypes = [
      'ChangeNotifierProvider',
      'ProviderPageTracker',
      'Consumer',
      'Selector',
      'ListenableProvider',
      'ValueListenableProvider',
    ];

    for (String wrapperType in wrapperTypes) {
      if (className.contains(wrapperType)) {
        final String? result = _extractChildFromWrapper(widget, wrapperType);
        if (result != null) {
          return result;
        }
      }
    }

    return null;
  }

  /// 从包装器中提取子 Widget
  /// [widget] 包装器 Widget
  /// [wrapperType] 包装器类型
  static String? _extractChildFromWrapper(Widget widget, String wrapperType) {
    try {
      final dynamic wrapper = widget;

      // 根据包装器类型选择属性
      List<String> properties;
      if (wrapperType == 'ChangeNotifierProvider') {
        properties = ['builder'];
      } else if (wrapperType == 'ProviderPageTracker') {
        properties = ['child'];
      } else {
        properties = ['child', 'builder', 'widget'];
      }

      for (String property in properties) {
        try {
          final dynamic child = _getProperty(wrapper, property);
          if (child is Widget) {
            final String? result = _findProviderPageWidget(child);
            if (result != null) {
              return result;
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      print('从 $wrapperType 提取 child 失败: $e');
    }

    return null;
  }

  /// 安全地获取对象的属性
  static dynamic _getProperty(dynamic obj, String propertyName) {
    try {
      // 尝试直接访问属性
      switch (propertyName) {
        case 'child':
          return obj.child;
        case 'builder':
          return obj.builder;
        case 'widget':
          return obj.widget;
        case 'create':
          return obj.create;
        default:
          return null;
      }
    } catch (e) {
      print('获取属性 $propertyName 失败: $e');
      return null;
    }
  }

  /// 从路由中检测 Provider 页面
  /// [route] 路由对象
  /// [context] 上下文
  static String? detectFromRoute(Route route, BuildContext context) {
    try {
      // 检查是否为 MaterialPageRoute
      if (route is MaterialPageRoute) {
        final Widget widget = route.builder(context);
        return detectProviderPage(widget);
      }

      // 其他路由类型无法直接访问 builder
      print('不支持的路由类型: ${route.runtimeType}');
    } catch (e) {
      print('从路由检测 Provider 页面失败: $e');
    }

    return null;
  }
}
