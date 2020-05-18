import 'dart:core';

import 'package:flutter/material.dart';

import 'package:flutter_fastotv_common/player/appbar_player.dart';
import 'package:fastotv_common/screen_orientation.dart' as orientation;
import 'package:fastotv_common/colors.dart';

abstract class SideAppBarPlayer<T extends StatefulWidget> extends AppBarPlayer<T> with WidgetsBindingObserver {
  bool isVisiblePrograms = false;
  Orientation _orientation;

  Widget sideListContent();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => isVisiblePrograms = orientation.isPortrait(context));
  }

  @override
  void didChangeMetrics() {
    setState(() {
      _orientation = MediaQuery.of(context).orientation;
      if (_orientation == Orientation.portrait) {
        isVisiblePrograms = true;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _orientation = MediaQuery.of(context).orientation;
    final ora = Builder(builder: (context) {
      if (_orientation == Orientation.landscape) {
        return Row(children: <Widget>[_playerArea(), sideList()]);
      }
      return Column(children: <Widget>[appBar(), playerArea(), bottomControls(), sideList()]);
    });
    return Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: false,
        body: Container(width: MediaQuery.of(context).size.width, child: ora));
  }

  Widget sideBarButton() {
    if (orientation.isPortrait(context)) {
      return SizedBox();
    }
    return IconButton(
      icon: Icon(Icons.list),
      color: Colors.white,
      onPressed: () {
        setState(() {
          isVisiblePrograms = !isVisiblePrograms;
        });
      },
    );
  }

  Widget sideList() {
    return !isVisiblePrograms ? SizedBox() : Expanded(flex: 2, child: sideListContent());
  }

  Widget _playerArea() {
    return Expanded(flex: 3, child: playerOverlays());
  }

  Color get overlaysTextColor {
    Color color;
    if (orientation.isLandscape(context)) {
      color = Colors.white;
    } else {
      color = CustomColor().backGroundColorBrightness(Theme.of(context).primaryColor);
    }
    return color;
  }

  Color get backgroundColor {
    Color color;
    if (orientation.isLandscape(context)) {
      color = Colors.black.withOpacity(overlaysOpacity);
    }
    return color;
  }
}
