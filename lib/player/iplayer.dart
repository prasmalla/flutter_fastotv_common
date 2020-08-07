import 'dart:async';

import 'package:flutter/material.dart';

abstract class IPlayer {
  bool isPlaying();

  Duration position();

  double aspectRatio();

  Future<void> pause();

  Future<void> play();

  Future<void> seekTo(Duration duration);

  Future<void> seekForward(Duration duration) {
    return seekTo(position() + duration);
  }

  Future<void> seekBackward(Duration duration) {
    return seekTo(position() - duration);
  }

  void setVolume(double volume);

  Future<void> setStreamUrl(Uri url);

  Widget makePlayer();

  Widget makeCircular() {
    return AspectRatio(aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator()));
  }

  Widget makeLinear() {
    return Padding(padding: const EdgeInsets.only(top: 5.0), child: LinearProgressIndicator());
  }

  Widget timeLine();

  void dispose();
}
