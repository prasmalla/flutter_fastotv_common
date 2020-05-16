import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:screen/screen.dart';

import 'package:fastotv_common/volume_manager.dart';
import 'package:fastotv_common/system_methods.dart' as system;
import 'package:fastotv_common/screen_orientation.dart' as orientation;
import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';

enum OverlayControl { NONE, VOLUME, BRIGHTNESS, SEEK_FORWARD, SEEK_REPLAY }

abstract class AppBarPlayer<T extends StatefulWidget> extends State<T> with TickerProviderStateMixin{
  static const int APPBAR_TIMEOUT = 5;
  static const APPBAR_HEIGHT = 56.0;

  double playerOverlayOpacity = 0.0;
  OverlayControl currentPlayerControl = OverlayControl.NONE;

  Timer _timer;

  AnimationController _appbarController;
  AnimationController _bottomOverlayController;
  bool _appBarVisible;

  double brightness = 0.5;

  double get overlaysOpacity => 0.5;

  GlobalKey _gestureControllerKey = GlobalKey();

  VolumeManager _volumeManager;

  bool brightnessChange();

  bool soundChange();

  Widget appBar();

  Widget playerArea();

  Widget bottomControls();

  double bottomControlsHeight();

  bool isPlaying();

  void play();

  void pause();

  void onLongTapLeft();

  void onLongTapRight();

  Color get overlaysTextColor;

  Color get backgroundColor;

  @override
  void initState() {
    super.initState();
    _appBarVisible = true;
    _initPlatformState();
    setTimerOverlays();
    _appbarController = AnimationController(duration: const Duration(milliseconds: 100), value: 1.0, vsync: this);
    _bottomOverlayController = AnimationController(duration: const Duration(milliseconds: 100), value: 1.0, vsync: this);
  }

  @override
  void dispose() {
    _appbarController.dispose();
    _bottomOverlayController.dispose();
    _timer?.cancel();
    system.setStatusBar(true);
    orientation.allowAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor?.withOpacity(1),
        resizeToAvoidBottomInset: false,
        body: Container(width: MediaQuery.of(context).size.width, child: playerOverlays()));
  }

  Widget playerOverlays() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomHeight = bottomControlsHeight();
    //Animates appBar
    Animation<Offset> offsetAnimation = new Tween<Offset>(
      begin: Offset(0.0, -(APPBAR_HEIGHT + statusBarHeight)),
      end: Offset(0.0, 0.0),
    ).animate(_appbarController);
    // Animates bottom
    Animation<Offset> bottomOffsetAnimation = new Tween<Offset>(
      begin: Offset(0.0, 0.0),
      end: Offset(0.0, -(bottomHeight)),
    ).animate(_bottomOverlayController);
    return Expanded(
        flex: 3,
        child: Stack(children: <Widget>[
          /// Don't delete, or Stack widget will throw an exception
          Container(),

          playerArea(),

          /// Control view overlay
          Center(
              child: Opacity(
                  opacity: 0.5,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _currentPlayerControlWidget()))),

          /// AppBar & bottom bar
          SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    //AppBar
                    AnimatedBuilder(
                        animation: offsetAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: offsetAnimation.value,
                            child: Container(
                                color: Colors.transparent,
                                height: APPBAR_HEIGHT + statusBarHeight,
                                child: appBar()));
                        }),
                    //Gesture controller
                    Container(
                        key: _gestureControllerKey,
                        height: MediaQuery.of(context).size.height - APPBAR_HEIGHT - statusBarHeight,
                        child: _gestureController),
                    //Bottom controls
                    AnimatedBuilder(
                        animation: bottomOffsetAnimation,
                        builder: (context, child) {
                          return Transform.translate(offset: bottomOffsetAnimation.value, child: bottomControls());
                        })
                  ]))
        ]));
  }

  // public:
  void setTimerOverlays() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: APPBAR_TIMEOUT), () {
      if (orientation.isLandscape(context)) {
        setState(() {
          setOverlaysVisible(false);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void setOverlaysVisible(bool visible) {
    _appBarVisible = visible;

    if (_appBarVisible == true) {
      _appbarController.forward();
      _bottomOverlayController.forward();
      system.setStatusBar(true);
      setTimerOverlays();
    } else {
      if (_timer.isActive) {
        _timer.cancel();
      }
      system.setStatusBar(false);
      _appbarController.reverse();
      _bottomOverlayController.reverse();
    }
  }

  void togglePlayPause() {
    if (ChromeCastInfo().castConnected) {
      isPlaying() ? ChromeCastInfo().pause() : ChromeCastInfo().play();
    } else {
      isPlaying() ? pause() : play();
    }
    if (orientation.isLandscape(context)) {
      playerOverlayOpacity = isPlaying() ? 0.0 : 0.5;
      setOverlaysVisible(isPlaying());
      currentPlayerControl = OverlayControl.NONE;
    }
    setState(() {});
  }

  Widget createPlayPauseButton() {
    return IconButton(
      onPressed: () => togglePlayPause(),
      color: overlaysTextColor,
      icon: Icon(isPlaying() ? Icons.pause : Icons.play_arrow),
    );
  }

  // private:
  Future<void> _initPlatformState() async {
    if (!kIsWeb) {
      _volumeManager = await VolumeManager.getInstance();
      final bright = await Screen.brightness;
      setState(() {
        brightness = bright;
      });
    }
  }

  Widget get _gestureController {
    return Center(
      child: GestureDetector(
        onTap: () {
          _appBarVisible ? setOverlaysVisible(false) : setOverlaysVisible(true);
        },
        onVerticalDragUpdate: (DragUpdateDetails details) {
          if (!kIsWeb) {
            final isLeftPart = details.localPosition.dx < _getSizes().width / 2;
            isLeftPart ? _onVerticalDragUpdateVolume(details) : _onVerticalDragUpdateBrightness(details);
          }
        },
        onVerticalDragStart: (DragStartDetails details) {
          if (!kIsWeb) {
            _handleVerticalDragStart(details);
          }
        },
        onVerticalDragEnd: (DragEndDetails details) {
          if (!kIsWeb) {
            _handleVerticalDragEnd(details);
          }
        },
        onLongPressStart: (LongPressStartDetails details) {
          final isLeftPart = details.localPosition.dx < _getSizes().width / 2;
          isLeftPart ? onLongTapLeft() : onLongTapRight();
        },
        onDoubleTap: () {
          togglePlayPause();
        },
        child: Container(
          foregroundDecoration: new BoxDecoration(color: Color.fromRGBO(155, 85, 250, 0.0)),
        ),
      ),
    );
  }

  Size _getSizes() {
    final RenderBox renderBoxRed = _gestureControllerKey.currentContext.findRenderObject();
    return renderBoxRed.size;
  }

  void _onVerticalDragUpdateVolume(DragUpdateDetails details) {
    final maxHeight = MediaQuery.of(context).size.height;
    final maxVol = _volumeManager.maxVolume();
    double currentVol = _volumeManager.currentVolume();
    void relative() {
      final oneStep = maxVol / maxHeight;
      currentVol -= (1 * oneStep * details.delta.dy);
      if (currentVol > maxVol) {
        currentVol = maxVol;
      }
      if (currentVol < 0) {
        currentVol = 0;
      }
    }

    void absolute() {
      currentVol = (maxHeight - details.localPosition.dy) * maxVol / maxHeight;
    }

    if (details.localPosition.dy > 0 && details.localPosition.dy <= maxHeight)
      setState(() {
        soundChange() ? absolute() : relative();
      });

    _volumeManager.setVolume(currentVol);
  }

  void _onVerticalDragUpdateBrightness(DragUpdateDetails details) {
    final maxHeight = MediaQuery.of(context).size.height;
    void relative() {
      final oneStep = 1 / maxHeight;
      brightness -= oneStep * details.delta.dy;
      if (brightness > 1.0) {
        brightness = 1.0;
      }
      if (brightness < 0) {
        brightness = 0;
      }
    }

    void absolute() {
      brightness = (maxHeight - details.localPosition.dy) / maxHeight;
    }

    if (details.localPosition.dy > 0 && details.localPosition.dy <= maxHeight)
      setState(() {
        brightnessChange() ? absolute() : relative();
      });
    Screen.setBrightness(brightness);
  }

  /// Makes control widget invisible and resets current control
  void _handleVerticalDragEnd(DragEndDetails details) {
    setState(() {
      playerOverlayOpacity = isPlaying() ? 0.0 : 0.5;
      currentPlayerControl = OverlayControl.NONE;
    });
  }

  /// Sets current control [brightness] or [volume] widget and makes it visible
  void _handleVerticalDragStart(DragStartDetails details) {
    setState(() {
      playerOverlayOpacity = 0.5;
      final isLeftPart = details.localPosition.dx < _getSizes().width / 2;
      currentPlayerControl = isLeftPart ? OverlayControl.VOLUME : OverlayControl.BRIGHTNESS;
    });
  }

  List<Widget> _currentPlayerControlWidget() {
    if (currentPlayerControl == OverlayControl.VOLUME) {
      final maxVol = _volumeManager.maxVolume();
      final currentVol = _volumeManager.currentVolume();
      return [
        Icon(Icons.volume_up, color: Colors.white, size: 84),
        Text((currentVol / maxVol * 100).toStringAsFixed(0) + "%", style: TextStyle(fontSize: 84, color: Colors.white))
      ];
    } else if (currentPlayerControl == OverlayControl.BRIGHTNESS) {
      return [
        Icon(Icons.brightness_high, color: Colors.white, size: 84),
        Text((brightness * 100).toStringAsFixed(0) + "%", style: TextStyle(fontSize: 84, color: Colors.white))
      ];
    } else if (currentPlayerControl == OverlayControl.SEEK_REPLAY) {
      return [Icon(Icons.replay_5, color: Colors.white, size: 84)];
    } else if (currentPlayerControl == OverlayControl.SEEK_FORWARD) {
      return [Icon(Icons.forward_5, color: Colors.white, size: 84)];
    }
    return [SizedBox()];
  }
}
