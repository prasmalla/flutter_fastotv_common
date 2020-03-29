import 'dart:core';

import 'package:flutter/material.dart';
import 'package:persist_theme/persist_theme.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';
import 'package:fastotv_common/colors.dart';

class ChannelPageAppBar extends StatefulWidget {
  final String title;
  final String link;
  final Color backgroundColor;
  final Color textColor;
  final List<Widget> actions;
  final void Function() onChromeCast;
  final dynamic onExit;

  ChannelPageAppBar(
      {this.link, this.title, this.onChromeCast, this.backgroundColor, this.textColor, this.actions, this.onExit});

  @override
  _ChannelPageAppBarState createState() => _ChannelPageAppBarState();
}

class _ChannelPageAppBarState extends State<ChannelPageAppBar> {
  List<Widget> actionButtons = [];

  @override
  void initState() {
    super.initState();
    if (widget.actions != null) {
      actionButtons = widget.actions;
    }
    if (ChromeCastInfo().serviceFound()) {
      actionButtons.add(ChromeCastInfo().castConnected ? castConnectedIcon() : castNotConnectedIcon());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, model, child) {
      final textColor = widget.textColor ?? CustomColor().primaryColorBrightness(model);
      return AppBar(
          actionsIconTheme: IconThemeData(color: textColor),
          leading: IconButton(
              onPressed: () => Navigator.pop(context, widget.onExit), icon: Icon(Icons.arrow_back), color: textColor),
          actions: actionButtons,
          backgroundColor: widget.backgroundColor ?? Theme.of(context).primaryColor,
          title: Text(widget.title, style: TextStyle(color: textColor)));
    });
  }

  Widget castConnectedIcon() {
    return IconButton(icon: Icon(Icons.cast_connected), onPressed: () => _disconnect());
  }

  Widget castNotConnectedIcon() {
    return IconButton(icon: Icon(Icons.cast), onPressed: () => _pickDevice());
  }

  void _pickDevice() {
    ChromeCastInfo()
        .pickDeviceDialog(context, url: widget.link, name: widget.title, onConnected: () => _updChromeCastIcon());
  }

  void _disconnect() {
    ChromeCastInfo().disconnectDialog(context, onDisconnected: () => _updChromeCastIcon());
  }

  void _updChromeCastIcon() {
    actionButtons.removeAt(actionButtons.length - 1);
    actionButtons.add(ChromeCastInfo().castConnected ? castConnectedIcon() : castNotConnectedIcon());
    widget.onChromeCast();
  }
}
