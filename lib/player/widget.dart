import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/player.dart';
import 'package:screen/screen.dart';

abstract class IPlayerState {}

class InitIPlayerState extends IPlayerState {}

class ErrorState extends IPlayerState {}

class ReadyToPlayState extends IPlayerState {
  ReadyToPlayState(this.url, this.userData);

  final String url;
  final dynamic userData;
}

abstract class LitePlayer<T extends StatefulWidget, S> extends State<T> {
  static const TS_DURATION_MSEC = 5000;
  final StreamController<IPlayerState> state = StreamController<IPlayerState>.broadcast();

  VLCPlayer _player = VLCPlayer();

  bool _init = false;

  String url;

  dynamic userData;

  VLCPlayer get player => _player;

  void playLink(String url, dynamic userData) {
    _player.setStreamUrl(url).catchError((Object error) => onPlayingError(error));
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black, child: Center(child: _player.makePlayer()));
  }

  LitePlayer();

  void onPlaying(dynamic userData);

  void onPlayingError(dynamic userData);

  void seekToInterrupt() {}

  String currentUrl();

  void playChannel(S stream);

  bool isPlaying() {
    return player.isPlaying();
  }

  Duration position() {
    return player.position();
  }

  Future<void> pause() async {
    return player.pause();
  }

  Future<void> play() async {
    return player.play();
  }

  Future<void> seekTo(Duration duration) async {
    return player.seekTo(duration);
  }

  Future<void> seekForward(Duration duration) {
    return player.seekForward(duration);
  }

  Future<void> seekBackward(Duration duration) {
    return player.seekBackward(duration);
  }

  Future<void> setVolume(double volume) async {
    return player.setVolume(volume);
  }

  @override
  void initState() {
    _player.addListener(_playerHadler);
    _initLink(currentUrl());
    _setScreen(true);
    super.initState();
  }

  @override
  void dispose() {
    state.close();
    _player.removeListener(_playerHadler);
    _setScreen(false);
    _player.dispose();
    super.dispose();
  }

  Widget timeLine() {
    return StreamBuilder<IPlayerState>(
        stream: state.stream,
        initialData: InitIPlayerState(),
        builder: (context, snapshot) {
          if (snapshot.data is ReadyToPlayState) {
            return player.timeLine();
          }
          return player.makeLinear();
        });
  }

  // private:
  void _changeState(IPlayerState state) {
    this.state.add(state);
  }

  void _setScreen(bool keepOn) {
    if (!kIsWeb) {
      Screen.keepOn(keepOn);
    }
  }

  void _initLink(String url) {
    if (url.isEmpty) {
      return;
    }

    _player.setInitUrl(url);
  }

  void _onVlcInit(String url, dynamic userData) {
    _changeState(ReadyToPlayState(url, userData));
    _player.play().then((value) {
      onPlaying(userData);
    }).catchError((Object error) => onPlayingError(error));
  }

  void _playerHadler() {
    if (_player.initialized != _init) {
      _init = _player.initialized;
      if (_player.initialized) {
        _onVlcInit(url, userData);
      }
    }
  }
}
