import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/iplayer.dart';
import 'package:flutter_fastotv_common/player/vlc/progress_bar.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcPlayerControllerEx extends VlcPlayerController {
  String url;

  VlcPlayerControllerEx([VoidCallback _onInit]) : super(onInit: _onInit);

  @override
  Future<void> setStreamUrl(String url) async {
    this.url = url;
    return super.setStreamUrl(url);
  }

  Future<void> setVolume(double volume) {
    return Future<void>.value();
  }
}

class VLCPlayer extends IPlayer {
  VlcPlayerControllerEx _controller = VlcPlayerControllerEx();

  VLCPlayer([VoidCallback _onInit]) {
    _controller = VlcPlayerControllerEx(() {
      if (_onInit != null) _onInit();
    });
  }

  VlcPlayerControllerEx get controller => _controller;

  bool get initialized => _controller.initialized;

  void setInitUrl(String url) {
    _controller.url = url;
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
    return VlcPlayer(url: _controller.url, aspectRatio: aspectRatio(), controller: _controller, placeholder: makeCircular());
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
    return _controller.setVolume(volume);
  }

  @override
  Future<void> setStreamUrl(Uri url) async {
    if (url == null || _controller.initialized) {
      return Future.error('Invalid input');
    }

    return _controller.setStreamUrl(url.toString());
  }

  @override
  void dispose() {
    _controller?.dispose();
  }
}
