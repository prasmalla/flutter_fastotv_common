import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/iplayer.dart';
import 'package:flutter_fastotv_common/player/progress_bar.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VLCPlayer extends IPlayer {
  Completer<void> _creatingCompleter;
  VlcPlayerController _controller;
  String url;

  VLCPlayer() {
    _creatingCompleter = Completer<void>();
    _controller = VlcPlayerController(onInit: _handleInit);
  }

  void addListener(VoidCallback listener) {
    _controller.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    _controller.removeListener(listener);
  }

  @override
  Widget timeLine() {
    return VideoProgressIndicatorVLC(_controller, allowScrubbing: true);
  }

  @override
  Widget makePlayer() {
    return VlcPlayer(url: url, aspectRatio: aspectRatio(), controller: _controller, placeholder: makeCircular());
  }

  @override
  bool isPlaying() {
    if (!_controller.initialized) {
      return false;
    }

    return _controller.playingState == PlayingState.PLAYING;
  }

  @override
  Duration position() {
    if (!_controller.initialized) {
      return Duration(milliseconds: 0);
    }
    return _controller.position;
  }

  @override
  double aspectRatio() {
    return 16 / 9;
  }

  @override
  Future<void> pause() async {
    if (!_controller.initialized) {
      return Future.error('Invalid state');
    }

    return _controller.pause();
  }

  @override
  Future<void> play() async {
    if (!_controller.initialized) {
      return Future.error('Invalid state');
    }

    return _controller.play();
  }

  @override
  Future<void> seekTo(Duration duration) async {
    if (!_controller.initialized) {
      return Future.error('Invalid state');
    }

    return _controller.setTime(duration.inMilliseconds);
  }

  @override
  Future<void> setVolume(double volume) {
    if (!_controller.initialized) {
      return Future.error('Invalid state');
    }
    return _controller.setVolume((volume * 100).toInt());
  }

  @override
  Future<void> setStreamUrl(String url) async {
    if (url == null) {
      return Future.error('Invalid input');
    }

    _controller.setStreamUrl(url);
    return _creatingCompleter.future;
  }

  @override
  void dispose() {
    _controller?.dispose();
  }

  void _handleInit() {
    _creatingCompleter.complete();
  }
}
