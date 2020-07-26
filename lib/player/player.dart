import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/flutter_player.dart';
import 'package:flutter_fastotv_common/player/iplayer.dart';
import 'package:flutter_fastotv_common/player/vlc_player.dart';
import 'package:screen/screen.dart';

abstract class IPlayerState {}

class InitIPlayerState extends IPlayerState {}

class ErrorState extends IPlayerState {}

class ReadyToPlayState extends IPlayerState {
  ReadyToPlayState(this.url, this.userData);

  final Uri url;
  final dynamic userData;
}

enum PlayerImpl { VLC, FLUTTER }

abstract class LitePlayer<T extends StatefulWidget> extends State<T> {
  static const TS_DURATION_MSEC = 5000;
  final IPlayer _player;
  final StreamController<IPlayerState> state = StreamController<IPlayerState>.broadcast();
  PlayerImpl impl = PlayerImpl.VLC;

  LitePlayer({this.impl = PlayerImpl.VLC})
      : _player = impl == PlayerImpl.FLUTTER ? FlutterPlayer() : VLCPlayer();

  LitePlayer.vlc() : _player = VLCPlayer();

  LitePlayer.flutter() : _player = FlutterPlayer();

  void playLink(String url, dynamic userData) {
    if (url.isEmpty) {
      return;
    }

    _initLink(url, userData);
  }

  void onPlaying(dynamic userData);

  void onPlayingError(dynamic userData);

  void seekToInterrupt() {}

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
    state.close();
    _setScreen(false);
    _player.dispose();
    super.dispose();
  }

  Future<void> setVolume(double volume) async {
    return _player.setVolume(volume);
  }

  @override
  Widget build(BuildContext context) {
    return impl == PlayerImpl.FLUTTER ? _buildFlutter() : _buildVlc();
  }

  Widget _buildFlutter() {
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

  Widget _buildVlc() {
    return Container(
        color: Colors.black,
        child: Center(child: _player.makePlayer()));
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
  void changeState(IPlayerState state) {
    this.state.add(state);
  }

  void _setScreen(bool keepOn) {
    if (!kIsWeb) {
      Screen.keepOn(keepOn);
    }
  }

  void _initLink(String url, dynamic userData) async {
    final parsed = Uri.tryParse(url);
    if (parsed == null) {
      return;
    }

    changeState(InitIPlayerState());
    /*if (parsed.scheme == 'http' || parsed.scheme == 'https') {
      try {
        final resp = await http.get(url).timeout(const Duration(seconds: 1));
        if (resp.statusCode == 202) {
          Future.delayed(Duration(milliseconds: TS_DURATION_MSEC)).whenComplete(() {
            _initVideoLink(parsed, userData);
          });
        } else {
          _initVideoLink(parsed, userData);
        }
      } on TimeoutException catch (e) {
        _initVideoLink(parsed, userData);
      } on Error catch (e) {
        _initVideoLink(parsed, userData);
      }
      return;
    }*/

    _initVideoLink(parsed, userData);
  }

  void _initVideoLink(Uri url, dynamic userData) {
    final Future<void> init = _player.setStreamUrl(url);
    init.then((value) {
      changeState(ReadyToPlayState(url, userData));
      play().then((_) {
        onPlaying(userData);
      }).catchError(() => onPlayingError(userData));
    }).catchError(() => onPlayingError(userData));
  }
}
