import 'package:flutter/material.dart';
import 'package:xjj_app_base/core/utils/context_ext.dart';

/// 图片：统一的占位、失败图和圆角。
///
/// ```dart
/// AppImage.network(user.avatar, width: 40, height: 40, radius: 20)
/// AppImage.asset('assets/images/logo.png', width: 80)
/// ```
///
/// 网络图只有内存缓存。需要磁盘缓存时引入 cached_network_image，只改这个文件。
class AppImage extends StatelessWidget {
  const AppImage.network(
    String? url, {
    super.key,
    this.width,
    this.height,
    this.radius = 0,
    this.fit = BoxFit.cover,
  }) : _url = url,
       _asset = null;

  const AppImage.asset(
    String asset, {
    super.key,
    this.width,
    this.height,
    this.radius = 0,
    this.fit = BoxFit.cover,
  }) : _asset = asset,
       _url = null;

  final String? _url;
  final String? _asset;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (_asset != null) {
      image = Image.asset(_asset, width: width, height: height, fit: fit);
    } else if (_url == null || _url.isEmpty) {
      image = _placeholder(context, Icons.image_outlined);
    } else {
      image = Image.network(
        _url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(context, null),
        errorBuilder: (context, _, _) => _placeholder(context, Icons.broken_image_outlined),
      );
    }
    if (radius <= 0) return image;
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }

  Widget _placeholder(BuildContext context, IconData? icon) {
    final c = context.appColors;
    final shortest = [width, height].whereType<double>().fold<double>(48, (a, b) => a < b ? a : b);
    return Container(
      width: width,
      height: height,
      color: c.background,
      alignment: Alignment.center,
      child: icon == null ? null : Icon(icon, color: c.textHint, size: shortest * 0.4),
    );
  }
}
