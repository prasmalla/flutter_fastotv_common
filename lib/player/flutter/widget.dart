import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/flutter/player.dart';
import 'package:flutter_fastotv_common/player/player.dart';

abstract class LitePlayerFlutter<T extends StatefulWidget> extends LitePlayer<T> {
  FlutterPlayer _player = FlutterPlayer();

  @override
  FlutterPlayer get player => _player;

  @override
  void playLink(String url, dynamic userData) {
    if (url.isEmpty) {
      return;
    }

    _initLink(url, (uri) => _setVideoLink(uri, userData));
  }

  @override
  void initState() {
    _initLink(currentUrl(), (uri) => _setVideoLink(uri, null));
    super.initState();
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
                    return _player.makePlayer();
                  }
                  return _player.makeCircular();
                })));
  }

  // private:
  void _initLink(String url, void Function(Uri) onInit) async {
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
            onInit(parsed);
          });
        } else {
          onInit(parsed);
        }
      } on TimeoutException catch (e) {
        onInit(parsed);
      } on Error catch (e) {
        onInit(parsed);
      }
      return;
    }*/

    onInit(parsed);
  }

  void _setVideoLink(Uri url, dynamic userData) {
    final Future<void> init = _player.setStreamUrl(url);
    init.then((value) {
      changeState(ReadyToPlayState(url.toString(), userData));
      play().then((_) {
        onPlaying(userData);
      }).catchError(() => onPlayingError(userData));
    }).catchError(() => onPlayingError(userData));
  }
}
