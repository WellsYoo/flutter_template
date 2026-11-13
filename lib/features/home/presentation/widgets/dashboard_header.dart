import 'package:flutter/material.dart';
import 'package:xjj_app_base/features/home/data/dashboard.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 首页头部：问候语 + 本月签约额 + 近 7 天趋势 + 三个统计数字。
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.name, required this.data, this.onBell});

  final String name;
  final Dashboard? data;
  final VoidCallback? onBell;

  static String greetingOf(int hour) {
    if (hour < 6) return '夜深了';
    if (hour < 11) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    return XContainer(
      gradient: LinearGradient(
        colors: brandGradient(context.primary),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: EdgeInsets.fromLTRB(20, context.safeTop + 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    XText.caption(
                      '${greetingOf(DateTime.now().hour)}，欢迎回来',
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    XGap.v4,
                    XText(name.isEmpty ? '未命名用户' : name, size: 22, bold: true, color: Colors.white),
                  ],
                ),
              ),
              _GlassButton(icon: Icons.notifications_none_rounded, onTap: onBell, badge: d != null),
            ],
          ),
          XGap.v20,
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                XText.caption('本月签约额', color: Colors.white.withValues(alpha: 0.75)),
                XGap.v6,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '¥',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeights.medium,
                      ),
                    ),
                    const SizedBox(width: 2),
                    if (d == null)
                      const _SkeletonBar(width: 120, height: 26)
                    else
                      Text(
                        Fmt.money(d.monthAmount),
                        style: const TextStyle(
                          fontSize: 26,
                          height: 1.1,
                          color: Colors.white,
                          fontWeight: FontWeights.semibold,
                        ),
                      ),
                  ],
                ),
                XGap.v16,
                if (d == null)
                  const _SkeletonBar(width: double.infinity, height: 40)
                else
                  SizedBox(height: 40, child: TrendBars(values: d.trend)),
                XGap.v16,
                const Divider(color: Colors.white24, height: 1),
                XGap.v12,
                Row(
                  children: [
                    _Stat(label: '待审批', value: d?.pending),
                    _VerticalDivider(),
                    _Stat(label: '执行中', value: d?.ongoing),
                    _VerticalDivider(),
                    _Stat(label: '30 天到期', value: d?.expiring),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => XContainer(
    padding: XPad.all16,
    radius: 16,
    color: Colors.white.withValues(alpha: 0.14),
    borderColor: Colors.white.withValues(alpha: 0.18),
    borderWidth: 1,
    child: child,
  );
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, this.onTap, this.badge = false});

  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final button = XContainer(
      size: 40,
      circle: true,
      color: Colors.white.withValues(alpha: 0.16),
      alignment: Alignment.center,
      onTap: onTap,
      child: Icon(icon, size: 21, color: Colors.white),
    );
    return badge ? XBadge(dot: true, child: button) : button;
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        if (value == null)
          const _SkeletonBar(width: 36, height: 20)
        else
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              height: 1.2,
              color: Colors.white,
              fontWeight: FontWeights.semibold,
            ),
          ),
        XGap.v4,
        XText.caption(label, color: Colors.white.withValues(alpha: 0.7)),
      ],
    ),
  );
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 24, margin: XPad.h8, color: Colors.white.withValues(alpha: 0.18));
}

/// 加载中的占位条，只用在渐变头部里（浅色半透明）
class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({this.width, this.height = 16});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => XContainer(
    width: width,
    height: height,
    radius: height / 3,
    color: Colors.white.withValues(alpha: 0.18),
  );
}

/// 近 7 天的柱状趋势图。用 CustomPaint 手绘，不引图表库。
class TrendBars extends StatelessWidget {
  const TrendBars({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.infinite, painter: _TrendPainter(values));
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max <= 0) return;
    final slot = size.width / values.length;
    final barWidth = slot * 0.56;
    final radius = Radius.circular(barWidth / 4);
    for (var i = 0; i < values.length; i++) {
      final height = size.height * (0.12 + 0.88 * values[i] / max);
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(i * slot + (slot - barWidth) / 2, size.height - height, barWidth, height),
        topLeft: radius,
        topRight: radius,
      );
      // 最后一根（今天）最亮，其余越早越淡
      final last = i == values.length - 1;
      final alpha = last ? 0.95 : 0.22 + 0.3 * (i / values.length);
      canvas.drawRRect(rect, Paint()..color = Colors.white.withValues(alpha: alpha));
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) => old.values != values;
}
