import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:video_player/video_player.dart';

import 'package:screen/screen.dart';

abstract class LitePlayer<T extends StatefulWidget> extends State<T> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  LitePlayer();

  void onPlaying(dynamic userData);

  void seekToInterrupt() {}

  bool isPlaying() {
    if (_controller == null) {
      return false;
    }

    return _controller.value.isPlaying;
  }

  void pause() async {
    if (_controller == null) {
      return;
    }

    _controller.pause();
  }

  void play() async {
    if (_controller == null) {
      return;
    }

    _controller.play();
  }

  void seekTo(Duration duration) async {
    if (_controller == null) {
      return;
    }

    _controller.seekTo(duration);
  }

  void seekForward(Duration duration) {
    if (_controller == null || _controller.value.duration == null) {
      return;
    }

    _controller.seekTo(_controller.value.position + duration);
  }

  void seekBackward(Duration duration) {
    if (_controller == null || _controller.value.duration == null) {
      return;
    }

    _controller.seekTo(_controller.value.position - duration);
  }

  VideoPlayerController controller() {
    return _controller;
  }

  Duration position() {
    if (_controller == null) {
      return Duration(milliseconds: 0);
    }
    return _controller.value.position;
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
    _controller?.dispose();
    super.dispose();
  }

  void _setScreen(bool keepOn) {
    if (!kIsWeb) {
      Screen.keepOn(keepOn);
    }
  }

  void setVolume(double volume) async {
    if (_controller == null) {
      return;
    }
    _controller.setVolume(volume);
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
                    return AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller));
                  }
                  return AspectRatio(aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator()));
                })));
  }

  void _initLink(String url, dynamic userData) {
    if (url.isEmpty) {
      return;
    }

    VideoPlayerController old = _controller;
    _controller = VideoPlayerController.network(url);
    _initializeVideoPlayerFuture = _controller.initialize().whenComplete(() => seekToInterrupt());
    if (old != null) {
      //old.pause();
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        old.dispose();
      });
    }
    final play = _controller.play();
    play.then((_) {
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
