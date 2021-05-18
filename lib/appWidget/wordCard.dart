
import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  const WordCard({
    Key key,
    @required this.textWidget,
    this.cartWidth = 76,
    this.isHidden = false
  }) : super(key: key);

  // final bool isDepressed;
  final Text textWidget;
  final double cartWidth;
  final bool isHidden;

  @override
  Widget build(BuildContext context){
    return Material(
      elevation: 0.0,
      color: Colors.transparent,
      child: Visibility(
        visible: !isHidden,
        child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: cartWidth,
                  width: cartWidth,
                  // padding: EdgeInsets.only(left: 20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    height: cartWidth,
                    width: cartWidth,
                    child: textWidget,
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}