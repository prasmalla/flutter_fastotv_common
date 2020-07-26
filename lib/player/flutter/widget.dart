import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/flutter_player.dart';
import 'package:flutter_fastotv_common/player/player.dart';

abstract class LitePlayerFlutter<T extends StatefulWidget> extends LitePlayer<T> {
  FlutterPlayer _player = FlutterPlayer();

  @override
  FlutterPlayer get player => _player;

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
                    return _player.makePlayer();
                  }
                  return _player.makeCircular();
                })));
  }

  // private:
  void initVideoLink(Uri url) {
    final Future<void> init = _player.setStreamUrl(url);
    init.then((value) {
      changeState(ReadyToPlayState(url, null));
      play().then((_) {
        onPlaying(null);
      }).catchError(() => onPlayingError(null));
    }).catchError(() => onPlayingError(null));
  }

  void setVideoLink(Uri url, dynamic userData) {
    final Future<void> init = _player.setStreamUrl(url);
    init.then((value) {
      changeState(ReadyToPlayState(url, userData));
      play().then((_) {
        onPlaying(userData);
      }).catchError(() => onPlayingError(userData));
    }).catchError(() => onPlayingError(userData));
  }
}
