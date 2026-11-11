import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';

/// 图片：统一的占位、失败图和圆角。http(s) 开头按网络图加载，其余按 asset。
///
/// ```dart
/// XImage(article.cover, width: 120, height: 80, radius: 8)
/// XImage('assets/images/logo.png', size: 80)
/// XImage.avatar(user.avatar, size: 40, onTap: _openProfile)
/// ```
///
/// 地址为空或加载失败时显示占位图标。
/// 网络图只有内存缓存。需要磁盘缓存时引入 cached_network_image，只改这个文件。
class XImage extends StatelessWidget {
  const XImage(
    this.src, {
    super.key,
    double? size,
    double? width,
    double? height,
    this.radius = 0,
    this.fit = BoxFit.cover,
    this.onTap,
    this.placeholder,
  }) : width = width ?? size,
       height = height ?? size,
       _circle = false;

  /// 圆形头像，地址为空时显示人像占位
  const XImage.avatar(this.src, {super.key, double size = 40, this.onTap, this.placeholder})
    : width = size,
      height = size,
      radius = 0,
      fit = BoxFit.cover,
      _circle = true;

  /// 图片地址：http(s) 开头是网络图，其余是 asset 路径
  final String? src;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;
  final VoidCallback? onTap;

  /// 自定义占位（地址为空、加载中、加载失败时显示）
  final Widget? placeholder;
  final bool _circle;

  @override
  Widget build(BuildContext context) {
    final src = this.src;
    Widget image;
    if (src == null || src.isEmpty) {
      image = _placeholder(context, _circle ? Icons.person : Icons.image_outlined);
    } else if (src.startsWith('http://') || src.startsWith('https://')) {
      image = Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(context, null),
        errorBuilder: (context, _, _) => _placeholder(context, Icons.broken_image_outlined),
      );
    } else {
      image = Image.asset(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, _, _) => _placeholder(context, Icons.broken_image_outlined),
      );
    }
    if (_circle) {
      image = ClipOval(child: image);
    } else if (radius > 0) {
      image = ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
    }
    if (onTap == null) return image;
    return GestureDetector(onTap: onTap, child: image);
  }

  Widget _placeholder(BuildContext context, IconData? icon) {
    final c = context.xColors;
    final shortest = [width, height].whereType<double>().fold<double>(48, (a, b) => a < b ? a : b);
    return Container(
      width: width,
      height: height,
      color: c.background,
      alignment: Alignment.center,
      child:
          placeholder ??
          (icon == null ? null : Icon(icon, color: c.textHint, size: shortest * 0.5)),
    );
  }
}
