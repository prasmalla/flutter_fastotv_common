import 'package:flutter/material.dart';

import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';

class CCDisconnectDialog extends StatefulWidget {
  final Color textColor;

  CCDisconnectDialog({this.textColor});

  _CCDisconnectDialogState createState() => _CCDisconnectDialogState();
}

class _CCDisconnectDialogState extends State<CCDisconnectDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: new Text("Disconnect"),
        content: new Text("Are you sure you want to disconnect and stop casting?", softWrap: true),
        contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
              child: new Text("Cancel", style: TextStyle(fontSize: 14, color: widget.textColor)),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          new FlatButton(
              textColor: Theme.of(context).accentColor,
              child: new Text("Disconnect", style: TextStyle(fontSize: 14)),
              onPressed: () {
                Navigator.pop(context, true);
                ChromeCastInfo().disconnect();
              })
        ]);
  }
}
