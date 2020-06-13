import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/flutter_player.dart';
import 'package:http/http.dart' as http;
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';

abstract class PlayerState {}

class InitPlayerState extends PlayerState {}

class HttpState extends PlayerState {
  HttpState(this.url, this.status, this.userData);

  final Uri url;
  final int status;
  final dynamic userData;
}

class ReadyToPlayState extends PlayerState {
  ReadyToPlayState(this.url, this.userData);

  final Uri url;
  final dynamic userData;
}

abstract class LitePlayer<T extends StatefulWidget> extends State<T> {
  final _player = FlutterPlayer();
  final StreamController<PlayerState> _state = StreamController<PlayerState>();

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
    _state.close();
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
            child: StreamBuilder<PlayerState>(
                stream: _state.stream,
                initialData: InitPlayerState(),
                builder: (context, snapshot) {
                  if (snapshot.data is HttpState) {
                    final HttpState resp = snapshot.data;
                    if (resp.status == 202) {
                      Future.delayed(Duration(milliseconds: 10000)).whenComplete(() {
                        _initVideoLink(resp.url, resp.userData);
                      });
                    } else {
                      _initVideoLink(resp.url, resp.userData);
                    }
                    return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Center(
                            child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        )));
                  } else if (snapshot.data is ReadyToPlayState) {
                    seekToInterrupt();
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

    if (parsed.scheme == 'http' || parsed.scheme == 'https') {
      http.get(url).then((value) {
        _state.add(HttpState(parsed, value.statusCode, userData));
      });
      return;
    }

    _initVideoLink(parsed, userData);
  }

  void _initVideoLink(Uri url, dynamic userData) {
    final init = _player.setStreamUrl(url);
    init.whenComplete(() {
      _state.add(ReadyToPlayState(url, userData));
    });
    play().then((_) {
      onPlaying(userData);
    });
  }

  void playLink(String url, dynamic userData) {
    if (url.isEmpty) {
      return;
    }

    _initLink(url, userData);
  }
}
