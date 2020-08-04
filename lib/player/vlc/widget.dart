import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/player.dart';
import 'package:flutter_fastotv_common/player/vlc/player.dart';


abstract class LitePlayerVLC<T extends StatefulWidget, S> extends LitePlayer<T, S> {
  VLCPlayer _player = VLCPlayer();

  bool _init = false;

  String url;

  dynamic userData;

  @override
  VLCPlayer get player => _player;

  @override
  void playLink(String url, dynamic userData) {
    if (url.isEmpty) {
      return;
    }

    _player.controller.setStreamUrl(url).catchError((Object error) => onPlayingError(error));
  }

  @override
  void initState() {
    super.initState();
    _player.addListener(_playerHadler);
    _initLink(currentUrl());
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

  // private:
  void _initLink(String url) {
    if (url.isEmpty) {
      return;
    }

    _player.setInitUrl(url);
  }

  void _onVlcInit(String url, dynamic userData) {
    changeState(ReadyToPlayState(url, userData));
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
