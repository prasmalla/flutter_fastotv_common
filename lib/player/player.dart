import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';

abstract class Player {
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

class FlutterPlayer extends Player {
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

abstract class LitePlayer<T extends StatefulWidget> extends State<T> {
  Player _player;
  Future<void> _initializeVideoPlayerFuture;

  LitePlayer();

  void onPlaying(dynamic userData);

  void seekToInterrupt() {}

  VideoPlayerController controller() {
    return _player.controller();
  }

  bool isPlaying() {
    return _player.isPlaying();
  }

  Duration position() {
    return _player.position();
  }

  Future<void> pause() async {
    return _player.pause();
  }

  Future<void> play() async {
    return _player.play();
  }

  Future<void> seekTo(Duration duration) async {
    return _player.seekTo(duration);
  }

  Future<void> seekForward(Duration duration) {
    return _player.seekForward(duration);
  }

  Future<void> seekBackward(Duration duration) {
    return _player.seekBackward(duration);
  }

  String currentUrl();

  @override
  void initState() {
    _setScreen(true);
    _initLink(currentUrl(), null);
    super.initState();
  }

  @override
  void dispose() {
    _setScreen(false);
    _player.dispose();
    super.dispose();
  }

  void _setScreen(bool keepOn) {
    if (!kIsWeb) {
      Screen.keepOn(keepOn);
    }
  }

  void setVolume(double volume) async {
    _player.setVolume(volume);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Center(
            child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _player.makePlayer();
                  }
                  return AspectRatio(aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator()));
                })));
  }

  void _initLink(String url, dynamic userData) {
    final init = _player.setStreamUrl(url);
    _initializeVideoPlayerFuture = init.whenComplete(() => seekToInterrupt());
    play().then((_) {
      onPlaying(userData);
    });
  }

  void playLink(String url, dynamic userData) {
    if (url.isEmpty) {
      return;
    }

    setState(() {
      _initLink(url, userData);
    });
  }
}
