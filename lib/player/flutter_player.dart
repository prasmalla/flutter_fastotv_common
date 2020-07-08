import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/iplayer.dart';
import 'package:video_player/video_player.dart';

class FlutterPlayer extends IPlayer {
  VideoPlayerController _controller;

  @override
  Widget timeLine() {
    return VideoProgressIndicator(_controller, allowScrubbing: true);
  }

  @override
  Widget makePlayer() {
    return AspectRatio(aspectRatio: aspectRatio(), child: VideoPlayer(_controller));
  }

  @override
  bool isPlaying() {
    if (_controller == null) {
      return false;
    }

    return _controller.value.isPlaying;
  }

  @override
  Duration position() {
    if (_controller == null) {
      return Duration(milliseconds: 0);
    }
    return _controller.value.position;
  }

  @override
  double aspectRatio() {
    if (_controller == null) {
      return 16 / 9;
    }

    return _controller.value.aspectRatio;
  }

  @override
  Future<void> pause() async {
    if (_controller == null) {
      return Future.error('Invalid state');
    }

    return _controller.pause();
  }

  @override
  Future<void> play() async {
    if (_controller == null) {
      return Future.error('Invalid state');
    }

    return _controller.play();
  }

  @override
  Future<void> seekTo(Duration duration) async {
    if (_controller == null) {
      return Future.error('Invalid state');
    }

    return _controller.seekTo(duration);
  }

  @override
  Future<void> setVolume(double volume) {
    if (_controller == null) {
      return Future.error('Invalid state');
    }
    return _controller.setVolume(volume);
  }

  @override
  Future<void> setStreamUrl(Uri url) async {
    if (url == null) {
      return Future.error('Invalid input');
    }

    VideoPlayerController old = _controller;
    _controller = VideoPlayerController.network(url.toString());
    if (old != null) {
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        old.dispose();
      });
    }
    return _controller.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
  }
}
