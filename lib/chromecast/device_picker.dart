import 'dart:async';

import 'package:dart_chromecast/casting/cast_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';
import 'package:flutter_mdns_plugin/flutter_mdns_plugin.dart';

class ChromeCastDevicePicker extends StatefulWidget {
  final String url;
  final String name;
  final Color buttonTextColor;

  ChromeCastDevicePicker(this.url, this.name, {this.buttonTextColor});

  _ChromeCastDevicePickerState createState() => _ChromeCastDevicePickerState();
}

class _ChromeCastDevicePickerState extends State<ChromeCastDevicePicker> {
  List<CastDevice> _devices = [];
  List<StreamSubscription> _streamSubscriptions = [];
  bool isReady = true;

  void initState() {
    super.initState();
    ChromeCastInfo().setCallbackOnConnect(() => Navigator.pop(context, true));
    _devices = ChromeCastInfo().foundServices.map((ServiceInfo serviceInfo) {
      CastDevice device = _deviceByName(serviceInfo.name);
      if (device == null) {
        device = _castDeviceFromServiceInfo(serviceInfo);
      }
      return device;
    }).toList();
  }

  _deviceDidUpdate(CastDevice device) {
    // this device did update, we need to trigger setState
    setState(() => {});
  }

  CastDevice _deviceByName(String name) {
    return _devices.firstWhere((CastDevice d) => d.name == name, orElse: () => null);
  }

  CastDevice _castDeviceFromServiceInfo(ServiceInfo serviceInfo) {
    CastDevice castDevice =
        CastDevice(name: serviceInfo.name, type: serviceInfo.type, host: serviceInfo.hostName, port: serviceInfo.port);
    _streamSubscriptions.add(castDevice.changes.listen((_) => _deviceDidUpdate(castDevice)));
    return castDevice;
  }

  Widget _buildListViewItem(BuildContext context, int index) {
    CastDevice castDevice = _devices[index];
    return ListTile(
        title: Text(castDevice.friendlyName),
        onTap: () async {
          if (null != ChromeCastInfo().onDevicePicked) {
            setState(() {
              isReady = false;
            });
            await ChromeCastInfo().onDevicePicked(castDevice);
            // clean up steam listeners
            _streamSubscriptions.forEach((StreamSubscription subscription) => subscription.cancel());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
        title: new Text(isReady ? "Choose device" : "Connecting..."),
        content: SingleChildScrollView(
            child: new Column(
                //mainAxisSize: MainAxisSize.min,
                children: isReady
                    ? new List<ListTile>.generate(_devices.length, (int index) => _buildListViewItem(context, index))
                    : [Container(height: 56, child: Center(child: CircularProgressIndicator()))])),
        contentPadding: EdgeInsets.fromLTRB(8, 20.0, 8, 0),
        actions: <Widget>[
          isReady
              ? new FlatButton(
                  child: new Text("Cancel", style: TextStyle(fontSize: 14, color: widget.buttonTextColor)),
                  onPressed: () {
                    Navigator.pop(context, false);
                  })
              : SizedBox()
        ]);
  }
}
