import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/player.dart';
import 'package:flutter_fastotv_common/player/vlc_player.dart';


abstract class LitePlayerVLC<T extends StatefulWidget> extends LitePlayer<T> {
  VLCPlayer _player = VLCPlayer();

  bool _init = false;

  Uri uri;

  dynamic userData;

  @override
  VLCPlayer get player => _player;

  @override
  void initState() {
    super.initState();
    _player.setInitUrl(currentUrl());
    _player.addListener(_playerHadler);
  }

  @override
  void dispose() {
    super.dispose();
    _player.removeListener(_playerHadler);
  }

  @override
  Widget build(BuildContext context) {
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

  void initVideoLink(Uri url) {
    _player.setInitUrl(url.toString());
  }

  void setVideoLink(Uri url, dynamic userData) {
    _player.setStreamUrl(url).catchError(() => onPlayingError(userData));
  }

  // private:
  void _onVlcInit(Uri url, dynamic userData) {
    changeState(ReadyToPlayState(url, userData));
    onPlaying(userData);
  }

  void _playerHadler() {
    if (_player.initialized != _init) {
      _init = _player.initialized;
      if (_init) {
        _onVlcInit(uri, userData);
      }
    }
  }
}
