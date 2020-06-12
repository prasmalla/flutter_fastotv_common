import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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

  Future<void> setStreamUrl(String url);

  Widget makePlayer();

  VideoPlayerController controller();

  void dispose();
}
