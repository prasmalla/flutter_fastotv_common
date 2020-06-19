import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/flutter_player.dart';
import 'package:http/http.dart' as http;
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';

abstract class IPlayerState {}

class InitIPlayerState extends IPlayerState {}

class HttpState extends IPlayerState {
  HttpState(this.url, this.status, this.userData);

  final Uri url;
  final int status;
  final dynamic userData;
}

class ReadyToPlayState extends IPlayerState {
  ReadyToPlayState(this.url, this.userData);

  final Uri url;
  final dynamic userData;
}

abstract class LitePlayer<T extends StatefulWidget> extends State<T> {
  static const TS_DURATION_MSEC = 10000;
  final _player = FlutterPlayer();
  final StreamController<IPlayerState> _state = StreamController<IPlayerState>();

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

  void setVolume(double volume) async {
    _player.setVolume(volume);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Center(
            child: StreamBuilder<IPlayerState>(
                stream: _state.stream,
                initialData: InitIPlayerState(),
                builder: (context, snapshot) {
                  if (snapshot.data is ReadyToPlayState) {
                    seekToInterrupt();
                    return _player.makePlayer();
                  } else if (snapshot.data is HttpState) {
                    final HttpState resp = snapshot.data;
                    if (resp.status == 202) {
                      Future.delayed(Duration(milliseconds: TS_DURATION_MSEC)).whenComplete(() {
                        _initVideoLink(resp.url, resp.userData);
                      });
                    } else {
                      _initVideoLink(resp.url, resp.userData);
                    }
                    return _makeCircular();
                  }
                  return _makeCircular();
                })));
  }

  void playLink(String url, dynamic userData) {
    if (url.isEmpty) {
      return;
    }

    _initLink(url, userData);
  }

  // private:
  void _changeState(IPlayerState state) {
    _state.add(state);
  }

  void _setScreen(bool keepOn) {
    if (!kIsWeb) {
      Screen.keepOn(keepOn);
    }
  }

  Widget _makeCircular() {
    return AspectRatio(aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator()));
  }

  void _initLink(String url, dynamic userData) {
    final parsed = Uri.tryParse(url);
    if (parsed == null) {
      return;
    }

    _player.flush();
    if (parsed.scheme == 'http' || parsed.scheme == 'https') {
      http.head(url).then((value) {
        _changeState(HttpState(parsed, value.statusCode, userData));
      });
      return;
    }

    _initVideoLink(parsed, userData);
  }

  void _initVideoLink(Uri url, dynamic userData) {
    final init = _player.setStreamUrl(url);
    init.whenComplete(() {
      _changeState(ReadyToPlayState(url, userData));
    });
    play().then((_) {
      onPlaying(userData);
    });
  }
}
