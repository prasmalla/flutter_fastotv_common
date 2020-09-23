import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/iplayer.dart';
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

  IPlayer _player = VLCPlayer();

  void playLink(String url, dynamic userData) {
    _setVideoLink(url, userData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Center(
            child: StreamBuilder<IPlayerState>(
                stream: state.stream,
                initialData: InitIPlayerState(),
                builder: (context, snapshot) {
                  if (snapshot.data is ReadyToPlayState) {
                    seekToInterrupt();
                  }
                  return _player.makePlayer();
                })));
  }

  LitePlayer();

  void onPlaying(dynamic userData);

  void onPlayingError(dynamic userData);

  void seekToInterrupt() {}

  String currentUrl();

  void playChannel(S stream);

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

  Future<void> setVolume(double volume) async {
    return _player.setVolume(volume);
  }

  @override
  void initState() {
    _initLink(currentUrl());
    _setScreen(true);
    super.initState();
  }

  @override
  void dispose() {
    state.close();
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
            return _player.timeLine();
          }
          return _player.makeLinear();
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
    _setVideoLink(url, null);
  }

  void _setVideoLink(String url, dynamic userData) {
    _changeState(InitIPlayerState());
    final Future<void> init = _player.setStreamUrl(url);
    init.then((value) {
      _changeState(ReadyToPlayState(url, userData));
      play().then((_) {
        onPlaying(userData);
      }).catchError((Object error) => onPlayingError(userData));
    }).catchError((Object error) => onPlayingError(userData));
  }
}
