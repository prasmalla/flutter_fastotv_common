import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

enum PreviewType { LIVE, VOD }

class PreviewIcon extends StatelessWidget {
  final String link;
  final double height;
  final double width;
  final PreviewType type;

  PreviewIcon.live(this.link, {this.height, this.width}) : this.type = PreviewType.LIVE;

  PreviewIcon.vod(this.link, {this.height, this.width}) : this.type = PreviewType.VOD;

  String assetsLink() {
    if (type == PreviewType.LIVE) {
      return 'install/assets/unknown_channel.png';
    } else if (type == PreviewType.VOD) {
      return 'install/assets/unknown_preview.png';
    } else {
      return 'install/assets/unknown_channel.png';
    }
  }

  Widget defaultIcon() {
    return Image.asset(assetsLink(), height: height, width: width);
  }

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
        imageUrl: link,
        placeholder: (context, url) => defaultIcon(),
        errorWidget: (context, url, error) => defaultIcon(),
        height: height,
        width: width);
    return ClipRect(child: image);
  }
}
