import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcProgressIndicator extends StatefulWidget {
  final VlcPlayerController controller;

  VlcProgressIndicator(this.controller);

  @override
  State<StatefulWidget> createState() => VlcProgressIndicatorState();
}

class VlcProgressIndicatorState extends State<VlcProgressIndicator> {
  double sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      String state = widget.controller.playingState.toString();
      if (this.mounted) {
        setState(() {
          if (state == "PlayingState.PLAYING" &&
              sliderValue < widget.controller.duration.inSeconds) {
            sliderValue = widget.controller.position.inSeconds.toDouble();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
        activeColor: Colors.white,
        value: sliderValue,
        min: 0.0,
        max: widget.controller.duration == null
            ? 1.0
            : widget.controller.duration.inSeconds.toDouble(),
        onChanged: (progress) {
          setState(() {
            sliderValue = progress.floor().toDouble();
          });
          //convert to Milliseconds since VLC requires MS to set time
          widget.controller.setTime(sliderValue.toInt() * 1000);
        });
  }
}
