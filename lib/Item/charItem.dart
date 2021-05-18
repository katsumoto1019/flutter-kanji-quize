
import 'package:flutter/material.dart';

class CharItem {

  final String chaStr;
  final Text textWidget;
  bool isMatch;

  CharItem({
    this.chaStr,
    this.textWidget,
    this.isMatch = false
  });
}