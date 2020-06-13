import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/iplayer.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class FlutterPlayer extends IPlayer {
  VideoPlayerController _controller;

  VideoPlayerController controller() {
    return _controller;
  }

  Widget makePlayer() {
    return AspectRatio(aspectRatio: aspectRatio(), child: VideoPlayer(_controller));
  }

  bool isPlaying() {
    if (_controller == null) {
      return false;
    }

    return _controller.value.isPlaying;
  }

  Duration position() {
    if (_controller == null) {
      return Duration(milliseconds: 0);
    }
    return _controller.value.position;
  }

  double aspectRatio() {
    if (_controller == null) {
      return 16 / 9;
    }

    return _controller.value.aspectRatio;
  }

  Future<void> pause() async {
    if (_controller == null) {
      return Future.error('Invalid state');
    }

    return _controller.pause();
  }

  Future<void> play() async {
    if (_controller == null) {
      return Future.error('Invalid state');
    }

    return _controller.play();
  }

  Future<void> seekTo(Duration duration) async {
    if (_controller == null) {
      return Future.error('Invalid state');
    }

    return _controller.seekTo(duration);
  }

  Future<void> setVolume(double volume) {
    if (_controller == null) {
      return Future.error('Invalid state');
    }
    return _controller.setVolume(volume);
  }

  Future<void> setStreamUrl(String url) {
    if (url.isEmpty) {
      return Future.error('Invalid input');
    }

    final parsed = Uri.tryParse(url);
    if (parsed == null) {
      return Future.error('Invalid url');
    }

    // cod workaround
    if (parsed.scheme == 'http' || parsed.scheme == 'https') {
      return _delayedStart(url);
    }

    return _startUrl(url);
  }

  Future<void> _delayedStart(String url) async {
    final resp = await http.get(url);
    if (resp.statusCode == 202) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    return _startUrl(url);
  }

  Future<void> _startUrl(String url) {
    VideoPlayerController old = _controller;
    _controller = VideoPlayerController.network(url);
    Future<void> result = _controller.initialize();
    if (old != null) {
      //old.pause();
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        old.dispose();
      });
    }
    return result;
  }

  void dispose() {
    _controller?.dispose();
  }
}
