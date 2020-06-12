import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

class VodCard extends StatelessWidget {
  final String iconLink;
  final int duration;
  final int interruptTime;
  final double width;
  final double height;
  final double borderRadius;
  final Function onPressed;

  VodCard(
      {this.iconLink, this.interruptTime, this.duration, this.height, this.width, this.borderRadius, this.onPressed});

  static const double BORDER_RADIUS = 2.0;
  static const CARD_WIDTH = 172.0;
  static const ASPECT_RATIO = 1.481;

  @override
  Widget build(BuildContext context) {
    Size getSize() {
      if (height != null && width == null) {
        return Size(height / ASPECT_RATIO, height);
      } else if (height == null && width != null) {
        return Size(width, width * ASPECT_RATIO);
      } else if (height != null && width != null) {
        return Size(width, height);
      }
      return (Size(CARD_WIDTH, CARD_WIDTH * ASPECT_RATIO));
    }

    double timeLine() {
      int stopTime = interruptTime;
      int _duration = duration;
      if (_duration == 0) {
        _duration = 1;
      }
      return (width ?? CARD_WIDTH) * ((stopTime ?? 0) / _duration);
    }

    final size = getSize();
    final border = BorderRadius.circular(borderRadius ?? BORDER_RADIUS);
    return Container(
        width: size.width,
        height: size.height,
        child: Card(
            margin: EdgeInsets.all(0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: border),
            child: Stack(children: <Widget>[
              Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Expanded(child: ClipRRect(borderRadius: border, child: PreviewIcon.vod(iconLink)))
              ]),
              duration == null ? SizedBox() : Positioned(
                  bottom: 0, child: Container(height: 5, width: timeLine(), color: Theme.of(context).accentColor)),
              InkWell(onTap: () => onPressed())
            ])));
  }
}
