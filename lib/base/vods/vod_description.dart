import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgress extends CustomPainter {
  double currentProgress;
  BuildContext context;

  static const WIDTH_CONTROL = 6.0;

  CircleProgress(this.currentProgress, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    //this is base circle
    Paint outerCircle = Paint()
      ..strokeWidth = WIDTH_CONTROL
      ..color = Theme
          .of(context)
          .brightness == Brightness.dark
          ? Color.fromRGBO(255, 255, 255, 0.1)
          : Color.fromRGBO(0, 0, 0, 0.1)
      ..style = PaintingStyle.stroke;

    Paint completeArc = Paint()
      ..strokeWidth = WIDTH_CONTROL
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - WIDTH_CONTROL;

    canvas.drawCircle(center, radius, outerCircle); // this draws main outer circle

    double angle = 2 * pi * (currentProgress / 100);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, angle, false, completeArc);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class UserScore extends StatelessWidget {
  final double score;
  final double fontSize;

  UserScore(this.score, {this.fontSize});

  @override
  Widget build(BuildContext context) {
    double size = fontSize ?? 14;
    Widget circleIndicator(double score) {
      return Center(
          child: CustomPaint(
              foregroundPainter: CircleProgress(score, context), // this will add custom painter after child
              child: Container(
                  width: size * 4,
                  height: size * 4,
                  child: Center(child: Text(score.toStringAsFixed(0), style: TextStyle(fontSize: size / 3 * 4))))));
    }

    return Row(children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('User', style: TextStyle(fontSize: size + 4, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text("score", style: TextStyle(fontSize: size + 4, fontWeight: FontWeight.bold))
      ]),
      SizedBox(width: 8),
      circleIndicator(score)
    ]);
  }
}

class VodDescriptionText extends StatelessWidget {
  final String description;
  final ScrollController scrollController;
  final double textSize;

  VodDescriptionText(this.description, {this.scrollController, this.textSize});

  static const TEXT_SIZE = 16.0;

  @override
  Widget build(BuildContext context) {
    return description == ''
        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Icon(Icons.warning),
      SizedBox(height: 8),
      Flexible(child: Text("No description provided", softWrap: true))
    ])
        : SingleChildScrollView(
        controller: scrollController ?? ScrollController(),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(children: <Widget>[
                    Text('Description',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: (textSize ?? TEXT_SIZE) + 8, fontWeight: FontWeight.bold))
                  ]),
                  SizedBox(height: 8),
                  Row(children: <Widget>[
                    Flexible(
                        child: Text(description, style: TextStyle(fontSize: textSize ?? TEXT_SIZE), softWrap: true))
                  ])
                ])));
  }
}

class SideInfoItem extends StatelessWidget {
  final String title;
  final String data;
  final double fontSize;
  final double padding;
  final double betweenLines;

  SideInfoItem({this.title, this.data, this.fontSize, this.padding, this.betweenLines});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(padding ?? 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(title, style: TextStyle(fontSize: fontSize ?? 14, fontWeight: FontWeight.bold)),
          SizedBox(height: betweenLines ?? 4),
          Text(data ?? 'N/A', style: TextStyle(fontSize: fontSize ?? 14))
        ]));
  }
}
