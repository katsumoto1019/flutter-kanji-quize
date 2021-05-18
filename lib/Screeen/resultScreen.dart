
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_fourcharacter/const/appconst.dart';

class ResultScreen extends StatelessWidget  {

  final int correctCount;
  final int inCorrectCount;
  final int currentOffset;

  ResultScreen({Key key, @required this.correctCount, @required this.inCorrectCount, @required this.currentOffset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(AppConst.designSizeWidth, AppConst.designSizeHeight),
      allowFontScaling: false,
      builder: () => Scaffold(
        backgroundColor: Color.fromRGBO(255, 248, 229, 1.0),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildContent())
            ],
          ),
        ),
        bottomNavigationBar: AdmobBanner(
          adUnitId: AppConst.getBannerAdUnitId(),
          adSize: AdmobBannerSize.BANNER,
        ),
      ),
    );
  }

  Widget _buildHeader (BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left:ScreenUtil().setWidth(5), right: ScreenUtil().setWidth(10), top: ScreenUtil().setHeight(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: new Icon(Icons.home, color: Color.fromRGBO(151, 152, 151, 1.0),), onPressed: () => _homeBtnPressed(context), alignment: Alignment.centerRight, iconSize: ScreenUtil().setWidth(35),),
          TextButton(
              onPressed: () => _backBtnPressed(context),
              child: Text('次の問題へ', style: TextStyle(color: Color.fromRGBO(151, 152, 151, 1.0), fontSize: ScreenUtil().setSp(18, allowFontScalingSelf: true)),)
          ),
          // IconButton(icon: new Icon(Icons.close, color: Color.fromRGBO(151, 152, 151, 1.0),), onPressed: () => _backBtnPressed(context), alignment: Alignment.centerLeft,),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [ //正解数   お疲れ様でした。
        Text('正解数', style: TextStyle(fontSize: ScreenUtil().setSp(50, allowFontScalingSelf: true), fontWeight: FontWeight.bold, color: Colors.black),),
        Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(70))),
        Text('$correctCount', style: TextStyle(fontSize: ScreenUtil().setSp(50, allowFontScalingSelf: true), fontWeight: FontWeight.bold, color: Colors.black),),
        Container(
          width: ScreenUtil().setWidth(50),
          height: ScreenUtil().setHeight(4),
          color: Colors.black,
          padding: EdgeInsets.only(top: 5, bottom: 5),
        ),
        Text('$inCorrectCount', style: TextStyle(fontSize: ScreenUtil().setSp(50, allowFontScalingSelf: true), fontWeight: FontWeight.bold, color: Colors.black),),
        Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(70))),
        Text('お疲れ様でした', style: TextStyle(fontSize: ScreenUtil().setSp(20, allowFontScalingSelf: true), color: Colors.black),),
      ],
    );
  }

  void _backBtnPressed(BuildContext context) {
    Navigator.pop(context, currentOffset);
  }

  void _homeBtnPressed(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

}