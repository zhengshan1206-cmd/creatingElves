import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


// 自定义弹性曲线（调整 factor 控制回弹强度，值越大回弹越明显）
class CustomSpringCurve extends Curve {
  
  final double factor;
  const CustomSpringCurve({this.factor = 0.4});

  @override
  double transform(double t) {
    // 处理边界条件：确保t=0时返回0，t=1时返回1
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    return 1 - pow(2, -10 * t) * cos((t - factor / 4) * (2 * pi) / factor);
  }
}

// 3. 核心：iOS 风格动画弹窗组件（StatefulWidget 管理动画）
class IOSAnimatedDialog extends StatefulWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;

  const IOSAnimatedDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
  });

  @override
  State<IOSAnimatedDialog> createState() => _IOSAnimatedDialogState();
}

class _IOSAnimatedDialogState extends State<IOSAnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // 动画控制器
  late Animation<double> _scaleAnimation; // 缩放动画
  late Animation<double> _opacityAnimation; //透明度动画

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器：时长 300ms（iOS 弹窗动画约 250-300ms）
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 配置弹性缩放动画：初始缩放 0.8 → 弹性回弹至 1.0
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      // curve: const CustomSpringCurve(factor: 0.3), // 关键：弹性曲线（自带回弹）
      reverseCurve: Curves.easeOut,
    ).drive(Tween<double>(begin: 0.0, end: 1.0)); // 初始0.8（小）→ 目标1.0（正常）

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      // curve: const CustomSpringCurve(factor: 0.3), // 关键：弹性曲线（自带回弹）
      reverseCurve: Curves.easeOut,
    ).drive(Tween<double>(begin: 0.0, end: 1.0)); // 初始0.8（小）→ 目标1.0（正常）

    // 启动动画
    // 仅在首次初始化时启动动画
    if (mounted) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放动画控制器（避免内存泄漏）
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 用 AnimatedBuilder 监听动画值，实时更新缩放
    return AnimatedBuilder(
      // animation: _scaleAnimation,
      animation: Listenable.merge([_opacityAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value, // 动画值控制缩放比例
          // origin: Offset.zero, // 以弹窗左上角为缩放原点（避免偏移）
          child: _buildDialogContent(), // 弹窗核心内容（iOS 风格外观）
        );
      },
    );
  }

  // 4. 构建 iOS 风格的弹窗内容（圆角、阴影、白色背景）
  Widget _buildDialogContent() {
    return Center(
      child: Container(
          width: 300,
          // height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // iOS 弹窗圆角约 12px
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 自适应内容高度
            children: [
              // 标题区域
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // 内容区域
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  widget.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // 分割线（iOS 按钮区域上方的细线）
              const Divider(height: 1, color: Colors.black12),
              // 按钮区域（iOS 通常是“取消+确定”横向排列）
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    // 取消按钮（左）
                    Expanded(
                      child: TextButton(
                        onPressed: () => _onCancel(), // 关闭弹窗
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
                          ),
                        ),
                        child: Text(
                          widget.cancelText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF007AFF), // iOS 按钮蓝色
                          ),
                        ),
                      ),
                    ),
                    // 分割线（按钮之间的竖线）
                    const VerticalDivider(width: 1, color: Colors.black12),
                    // 确定按钮（右）
                    Expanded(
                      child: TextButton(
                        onPressed: () => _onConfirm(), // 关闭弹窗（可自定义逻辑）
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
                          ),
                        ),
                        child: Text(
                          widget.confirmText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF007AFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  // 优化取消/确定按钮的点击逻辑
  void _onCancel() {
    Get.back(); // 先反向动画，再关闭弹窗
  }

  void _onConfirm() {
    _controller.reverse().then((_) => Get.back());
  }
}