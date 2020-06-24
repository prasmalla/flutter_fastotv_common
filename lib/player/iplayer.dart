import 'dart:async';

import 'package:flutter/material.dart';

abstract class IPlayer extends ChangeNotifier {
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

  Widget timeLine();

  void dispose();
}
