import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/flutter_player.dart';
import 'package:http/http.dart' as http;
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';

abstract class LitePlayer<T extends StatefulWidget> extends State<T> {
  final _player = FlutterPlayer();
  final http.Client _httpChecker = http.Client();
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
    _httpChecker.close();
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
    final parsed = Uri.tryParse(url);
    if (parsed == null) {
      return;
    }

    final start = () {
      final init = _player.setStreamUrl(parsed);
      _initializeVideoPlayerFuture = init.whenComplete(() => seekToInterrupt());
      play().then((_) {
        onPlaying(userData);
      });
    };

    if (parsed.scheme == 'http' || parsed.scheme == 'https') {
      final get = _httpChecker.get(url);
      get.then((resp) {
        if (resp.statusCode == 202) {
          Future.delayed(Duration(milliseconds: 500)).whenComplete(() {
            start();
          });
        } else {
          start();
        }
      }, onError: () {
        start();
      });
      return;
    }

    start();
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
