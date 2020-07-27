import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/iplayer.dart';
import 'package:screen/screen.dart';

abstract class IPlayerState {}

class InitIPlayerState extends IPlayerState {}

class ErrorState extends IPlayerState {}

class ReadyToPlayState extends IPlayerState {
  ReadyToPlayState(this.url, this.userData);

  final String url;
  final dynamic userData;
}

abstract class LitePlayer<T extends StatefulWidget> extends State<T> {
  static const TS_DURATION_MSEC = 5000;
  IPlayer get player;
  final StreamController<IPlayerState> state = StreamController<IPlayerState>.broadcast();

  LitePlayer();

  void playLink(String url, dynamic userData);

  void onPlaying(dynamic userData);

  void onPlayingError(dynamic userData);

  void seekToInterrupt() {}

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

  String currentUrl();

  @override
  void initState() {
    _setScreen(true);
    super.initState();
  }

  @override
  void dispose() {
    state.close();
    _setScreen(false);
    player.dispose();
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
  void changeState(IPlayerState state) {
    this.state.add(state);
  }

  void _setScreen(bool keepOn) {
    if (!kIsWeb) {
      Screen.keepOn(keepOn);
    }
  }
}
