import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

class ChromeCastFiller extends StatelessWidget {
  final String link;
  final Size size;
  final int type;

  ChromeCastFiller.live(this.link, {this.size}) : type = 0;

  ChromeCastFiller.vod(this.link, {this.size}) : type = 1;

  @override
  Widget build(BuildContext context) => Center(
      child: type == 0
          ? PreviewIcon.live(link, height: size.height, width: size.width)
          : PreviewIcon.vod(link, height: size.height, width: size.width));
}
