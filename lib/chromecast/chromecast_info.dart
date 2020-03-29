import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dart_chromecast/casting/cast_device.dart';
import 'package:dart_chromecast/casting/cast.dart';

import 'package:flutter_mdns_plugin/flutter_mdns_plugin.dart';

import 'package:flutter_fastotv_common/chromecast/device_picker.dart';
import 'package:flutter_fastotv_common/chromecast/disconnect.dart';

class ChromeCastInfo {
  static const int DISCOVERY_TIME_SEC = 3;
  static final ChromeCastInfo _instance = ChromeCastInfo._internal();

  factory ChromeCastInfo() {
    return _instance;
  }

  ChromeCastInfo._internal() {
    _flutterMdnsPlugin = FlutterMdnsPlugin(
        discoveryCallbacks: DiscoveryCallbacks(
            onDiscoveryStarted: () => {},
            onDiscoveryStopped: () => {},
            onDiscovered: (ServiceInfo serviceInfo) => {},
            onResolved: (ServiceInfo serviceInfo) {
              _foundServices.add(serviceInfo);
            }));
    _refreshDevices();
  }

  void _refreshDevices() {
    _foundServices = [];
    _flutterMdnsPlugin.startDiscovery('_googlecast._tcp');
    Timer(Duration(seconds: DISCOVERY_TIME_SEC), () {
      _flutterMdnsPlugin.stopDiscovery();
    });
  }

  CastSender _castSender;
  FlutterMdnsPlugin _flutterMdnsPlugin;
  bool _castConnected;
  Function _callbackOnConnected;
  List<ServiceInfo> _foundServices = [];

  void pickDeviceDialog(BuildContext context, {String url, String name, void Function() onConnected}) async {
    bool connected = false;
    connected = await showDialog(
      context: context,
      builder: (context) => ChromeCastDevicePicker(url, name),
    );
    if (connected ?? false) {
      ChromeCastInfo().initVideo(url, name);
      onConnected();
    }
  }

  void disconnectDialog(BuildContext context, {void Function() onDisconnected}) async {
    if (ChromeCastInfo().castConnected) {
      bool disconnected = await showDialog(context: context, builder: (BuildContext context) => CCDisconnectDialog());
      if (disconnected ?? false) {
        onDisconnected();
      }
    }
  }

  void disconnect() async {
    if (_castSender != null) {
      _castSender.disconnect();
      _castSender = null;
      _castConnected = false;
    }
  }

  void _castSessionIsConnected(CastSession castSession) async {
    _castConnected = true;
    if (_callbackOnConnected != null) {
      _callbackOnConnected();
    }
  }

  Future _connectToDevice(CastDevice device) async {
    _castSender = CastSender(device);
    StreamSubscription subscription = _castSender.castSessionController.stream.listen((CastSession castSession) {
      if (castSession.isConnected) {
        _castSessionIsConnected(castSession);
      }
    });

    bool connected = await _castSender.connect();
    if (!connected) {
      // show error message...
      subscription.cancel();
      _castSender = null;
      return;
    }
    _castSender.launch();
  }

  CastSender get castSender => _castSender;

  List<ServiceInfo> get foundServices => _foundServices;

  Future Function(CastDevice) get onDevicePicked => _connectToDevice;

  bool get castConnected => _castConnected ?? false;

  void play() => _castSender.play();

  void pause() => _castSender.pause();

  double position() => _castSender.castSession?.castMediaStatus?.position;

  bool serviceFound() {
    return _foundServices.length > 0;
  }

  void initVideo(String contentID, String title) {
    final castMedia = CastMedia(
      contentId: contentID,
      title: title,
    );
    _castSender.load(castMedia);
  }

  void setCallbackOnConnect(Function callback) {
    _callbackOnConnected = callback;
  }

  void togglePlayPauseCC() {
    if (_castSender == null) {
      return;
    }

    isPlaying() ? castSender.togglePause() : castSender.play();
  }

  void setVolume(double volume) {
    if (_castSender == null) {
      return;
    }
    _castSender.setVolume(volume);
  }

  bool isPlaying() {
    if (_castSender == null || _castSender.castSession == null || _castSender.castSession.castMediaStatus == null) {
      return false;
    }

    return _castSender.castSession.castMediaStatus.isPlaying;
  }
}
