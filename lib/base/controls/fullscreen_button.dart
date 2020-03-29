import 'package:flutter/material.dart';
import 'package:fastotv_common/screen_orientation.dart' as orientation;

class FullscreenButton extends StatelessWidget {
  final bool opened;
  final Color color;
  final void Function() onTap;

  FullscreenButton.close({this.color, this.onTap}) : opened = true;

  FullscreenButton.open({this.color, this.onTap}) : opened = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(opened ? Icons.fullscreen_exit : Icons.fullscreen),
        color: color,
        onPressed: () {
          opened ? orientation.onlyPortrait() : orientation.onlyLandscape();
          if (onTap != null) {
            onTap();
          }
        });
  }
}
