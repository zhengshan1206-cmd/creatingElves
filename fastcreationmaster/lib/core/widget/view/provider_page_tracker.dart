import 'package:flutter/material.dart';
import '../../service/page_route_service.dart';

/// Provider 页面跟踪器
/// 用于包装 Provider 页面，自动处理埋点
class ProviderPageTracker extends StatefulWidget {
  final String pageId;
  final Widget child;

  const ProviderPageTracker({
    super.key,
    required this.pageId,
    required this.child,
  });

  @override
  State<ProviderPageTracker> createState() => _ProviderPageTrackerState();
}

class _ProviderPageTrackerState extends State<ProviderPageTracker> {
  @override
  void initState() {
    super.initState();
    PageRouteService.setCurrentProviderPageId(widget.pageId);
    print('Provider 页面跟踪器初始化: ${widget.pageId}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PageRouteService.getCurrentProviderPageId() != widget.pageId) {
      PageRouteService.setCurrentProviderPageId(widget.pageId);
    }
  }

  @override
  void dispose() {
    // 清除当前 Provider 页面标识
    PageRouteService.clearCurrentProviderPageId();
    print('Provider 页面跟踪器销毁: ${widget.pageId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 便捷方法：为 Provider 页面添加埋点支持
/// [pageId] 页面标识
/// [widget] 页面 Widget
Widget trackProviderPage({
  required String pageId,
  required Widget widget,
}) {
  return ProviderPageTracker(
    pageId: pageId,
    child: widget,
  );
}
