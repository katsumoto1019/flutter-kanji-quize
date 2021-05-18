// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DraggingItem extends StatelessWidget {
  const DraggingItem({
    Key key,
    @required this.dragKey,
    @required this.str,
    this.cardWidth = 76,
    this.fontSize = 45
  }) : super(key: key);

  final GlobalKey dragKey;
  final String str;
  final double fontSize;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: Card(
          key: dragKey,
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            height: cardWidth,
            width: cardWidth,
            child: Opacity(
              opacity: 0.85,
              child: Text(str, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: Colors.black, fontFamily: 'YUGOTHIC')),
            ),
          )
      ),
    );
  }
}