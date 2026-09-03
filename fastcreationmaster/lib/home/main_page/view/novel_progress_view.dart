/*
 * @Author: cold-x
 * @Date: 2025-07-07 10:23:16
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-14 18:16:06
 * @FilePath: /fastcreationmaster/lib/home/main_page/view/novel_progress_view.dart
 * @Description: 
 */

import 'dart:math';

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NovelProgressView extends StatefulWidget {
  const NovelProgressView({
    super.key,
    required this.progress,
    this.title = '',
    this.check,
    this.tasksCount = 1,
    this.onClose, // 添加关闭回调
  });

  final int? tasksCount;
  final int progress;
  final String? title;
  final Function()? check;
  final Function()? onClose; // 关闭回调函数

  @override
  State<NovelProgressView> createState() => _NovelProgressViewState();
}

class _NovelProgressViewState extends State<NovelProgressView>
    with SingleTickerProviderStateMixin {
  // 动画控制器
  late AnimationController _controller;
  // 宽度动画
  late Animation<double> _widthAnimation;
  // 透明度动画
  late Animation<double> _opacityAnimation;
  // 是否展开
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // 与外部动画保持一致
    );

    // 初始化宽度动画（从收起宽度到展开宽度）
    _widthAnimation = Tween<double>(
      begin: 48,
      end: 351.w,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack, // 使用弹性曲线，让展开更有感觉
      ),
    );

    // 初始化透明度动画（收起时逐渐透明）
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInCubic, // 收起时透明度变化更快，更有感觉
      ),
    );

    // 如果有外部关闭回调，说明是气泡二，默认展开
    if (widget.onClose != null) {
      _isExpanded = true;
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(NovelProgressView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果气泡二从隐藏变为显示，确保它是展开状态
    if (widget.onClose != null && !_isExpanded) {
      // 减少延迟时间，让展开动画更快开始
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _isExpanded = true;
          });
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放资源
    super.dispose();
  }

  // 切换展开/收起状态
  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    // 控制动画播放方向
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  _buildBody() {
    return AnimatedBuilder(
      animation: Listenable.merge([_widthAnimation, _opacityAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _isExpanded ? 1.0 : _opacityAnimation.value, // 收起时逐渐透明
          child: Transform.translate(
            offset: Offset(
              _isExpanded
                  ? 0
                  : (48 - _widthAnimation.value) * 1.2, // 收起时向右偏移更多，更有感觉
              0,
            ),
            child: SizedBox(
                  width: _isExpanded ? 351.w : _widthAnimation.value, // 保持展开状态
                  height: 48,
                  child: child,
                ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          // 如果有外部关闭回调，说明是气泡二，使用内部展开/收起逻辑
          if (widget.onClose != null) {
            if (!_isExpanded) {
              _toggleExpansion();
            }
          } else {
            // 气泡一不做展开操作，直接触发check回调
            widget.check?.call();
          }
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: _isExpanded
                ? Border.all(
                    width: 1,
                    color: ByColorUtil.colorF1,
                  )
                : null,
            gradient: const LinearGradient(
                colors: [ByColorUtil.colorC1, Color(0xFFD7F97D)]),
          ),
          child: Row(
            children: [
              // 展开时显示的额外组件（使用动画控制透明度）
              Expanded(
                child: FadeTransition(
                  opacity: _widthAnimation
                      .drive(Tween<double>(begin: 0, end: 1)), // 随宽度变化显示/隐藏
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        ByWidgetsUtil.commonText(
                            text: widget.tasksCount! > 1
                                ? '共${widget.tasksCount}个任务 ${widget.progress}%'
                                : '${widget.title} ${widget.progress}%',
                            textColor: Colors.black,
                            fontSize: 17),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            widget.check?.call();
                          },
                          child: Row(
                            children: [
                              ByWidgetsUtil.commonText(
                                  text: '立即查看',
                                  textColor: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500),
                              SizedBox(
                                width: 4.w,
                              ),
                              Image.asset(
                                'assets/global/common/btn_info_black.png',
                                width: 8.w,
                                height: 8.w,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Container(
                                width: 1,
                                height: 16,
                                color: ByColorUtil.colorBg4,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (widget.onClose != null) {
                                    // 如果有外部关闭回调，直接调用，不收起动画
                                    widget.onClose!();
                                  } else {
                                    // 否则使用内部展开/收起逻辑
                                    _toggleExpansion();
                                  }
                                },
                                child: Image.asset(
                                  'assets/global/common/btn_close_black.png',
                                  width: 30.w,
                                  height: 30.w,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if (!_isExpanded)
                CircularBorderProgress(
                  progress: widget.progress / 100,
                  size: 48,
                  strokeWidth: 4,
                  backgroundColor: const Color(0xFFD7F97D),
                  progressColor: Colors.green,
                  centerChild: Center(
                    child: Container(
                      width: 40.5,
                      height: 40.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                            colors: [ByColorUtil.colorC1, Color(0xFFD7F97D)]),
                      ),
                      child: Center(
                        child: _progressTextView(widget.progress),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _progressTextView(int progress) {
    return ByWidgetsUtil.commonRichText(texts: [
      TextSpan(
          text: '$progress',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      const TextSpan(text: '%', style: TextStyle(fontSize: 12))
    ]);
  }
}

class CircularBorderProgress extends StatelessWidget {
  // 进度值（0.0 - 1.0）
  final double progress;
  // 整体大小
  final double size;
  // 边框宽度
  final double strokeWidth;
  // 未完成部分颜色
  final Color backgroundColor;
  // 已完成部分颜色
  final Color progressColor;
  // 中心组件（可选）
  final Widget? centerChild;

  const CircularBorderProgress({
    super.key,
    required this.progress,
    this.size = 100.0,
    this.strokeWidth = 8.0,
    this.backgroundColor = ByColorUtil.colorC1,
    this.progressColor = Colors.blue,
    this.centerChild,
  }) : assert(progress >= 0.0 && progress <= 1.0, "进度值必须在 0.0-1.0 之间");

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BorderProgressPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          backgroundColor: backgroundColor,
          progressColor: progressColor,
        ),
        child: centerChild ??
            Center(
              child: Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: size / 5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      ),
    );
  }
}

// 自定义画笔实现圆形边框进度
class _BorderProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _BorderProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 计算中心点和半径（减去边框宽度的一半，避免绘制超出控件范围）
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 绘制背景圆环
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke // 仅绘制边框
      ..strokeCap = StrokeCap.round; // 圆角边框

    canvas.drawCircle(center, radius, backgroundPaint);

    const gradient = LinearGradient(
      colors: [ByColorUtil.colorC1, Color(0xFF409400)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    // 背景矩形
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 绘制进度圆环
    final progressPaint = Paint()
      ..color = progressColor
      ..shader = gradient.createShader(backgroundRect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 计算进度对应的角度（360度 = 2π弧度，从-90度开始即顶部开始）
    const startAngle = -0.5 * pi;
    final sweepAngle = progress * 2 * pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false, // 不填充
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BorderProgressPainter oldDelegate) {
    // 当进度或样式变化时重绘
    return progress != oldDelegate.progress ||
        strokeWidth != oldDelegate.strokeWidth ||
        backgroundColor != oldDelegate.backgroundColor ||
        progressColor != oldDelegate.progressColor;
  }
}
