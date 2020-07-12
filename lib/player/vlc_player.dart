import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/iplayer.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcPlayerControllerEx extends VlcPlayerController {
  String url;

  VlcPlayerControllerEx() : super(onInit: _onInitOnce) {}

  @override
  Future<void> setStreamUrl(String url) async {
    this.url = url;
    return super.setStreamUrl(url);
  }

  Future<void> setVolume(double volume) {
    return Future<void>.value();
  }

  static void _onInitOnce() {}
}

class VLCPlayer extends IPlayer {
  VlcPlayerControllerEx _controller = VlcPlayerControllerEx();

  @override
  Widget timeLine() {
    return CircularProgressIndicator(); //VideoProgressIndicator(_controller, allowScrubbing: true);
  }

  @override
  Widget makePlayer() {
    return VlcPlayer(url: _controller.url, aspectRatio: aspectRatio(), controller: _controller);
  }

  @override
  bool isPlaying() {
    if (_controller == null) {
      return false;
    }

    return _controller.playingState == PlayingState.PLAYING;
  }

  @override
  Duration position() {
    if (_controller == null) {
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

    return _controller.setTime(duration.inMilliseconds);
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

    return _controller.setStreamUrl(url.toString());
  }

  @override
  void dispose() {
    _controller?.dispose();
  }
}
