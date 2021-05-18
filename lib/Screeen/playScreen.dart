
import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:admob_flutter/admob_flutter.dart';

import 'package:flutter_fourcharacter/Item/charItem.dart';
import 'package:flutter_fourcharacter/appWidget/wordCard.dart';
import 'package:flutter_fourcharacter/appWidget/draggingItem.dart';
import 'package:flutter_fourcharacter/DatabaseHelper/databaseHelper.dart';
import 'package:flutter_fourcharacter/Screeen/resultScreen.dart';
import 'package:flutter_fourcharacter/const/appconst.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const int LIMIT_CNT = 10;
const int LIMIT_TIME = 60;

class PlayScreen extends StatefulWidget {
  @override
  _PlayScreenState createState() =>_PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with TickerProviderStateMixin {

  final dbHelper = DatabaseHelper.instance;

  int _queryLimitStart = 0;
  bool _firstLoadFlag = false;

  //ヒントの表示/非表示
  bool _showHintFlag = false; // true : 表示, false : 非表示

  int _problemIndex = 1; //問題番号
  // 文字のマッチ状態
  int _perfectValue = 0; // 0: default, 1: incorrect, 2: correct, 3: perfect
  int _correctCnt = 0; //正解数

  List<CharItem> _chaItems = []; //下に表示文字の配列
  List<CharItem> _problemItems = []; //四字熟語文字の配列

  Map<String, dynamic> _mainProblemData; //四字熟語データ
  List<Map<String, dynamic>> _dbData = []; //SQLiteから取得したデータ

  Timer _perfectTimer; //マッチ状態のアニメーションTimer
  bool _isPerfectAnimation = false;

  final GlobalKey _draggableKey = GlobalKey(); // drag key

  int _randIndex1 = 1;
  int _randIndex2 = 1;
  int _randIndex3 = 1;
  int _randIndex4 = 1;

  AdmobInterstitial interstitialAd;

  @override
  void initState(){

    if (!_firstLoadFlag) getProblemDataArray(start: _queryLimitStart, count: LIMIT_CNT);
    _firstLoadFlag = true;

    super.initState();

    interstitialAd = AdmobInterstitial(
      adUnitId: AppConst.getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
        handleEvent(event, args, 'Interstitial');
      },
    );
    interstitialAd.load();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

  }

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        break;
      case AdmobAdEvent.opened:
        break;
      case AdmobAdEvent.closed:
        break;
      case AdmobAdEvent.failedToLoad:
        interstitialAd.show();
        break;
      default:
    }
  }

  @override
  void dispose() {
    _perfectTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(AppConst.designSizeWidth, AppConst.designSizeHeight),
      allowFontScaling: false,
      builder: () => Scaffold(
        backgroundColor: Color.fromRGBO(255, 248, 229, 1.0),
        body: _buildContent(),
        bottomNavigationBar: AdmobBanner(
          adSize: AdmobBannerSize.BANNER,
          adUnitId: AppConst.getBannerAdUnitId(),
        ),
      ),
    );
  }

  void initData() {
    _showHintFlag = false;
    _perfectValue = 0;
  }

  void _wordDroppedOnProbCard({
    CharItem wordItem,
    CharItem probItem
  }){
    setState(() {
      if (!_isPerfectAnimation){
        if (wordItem.chaStr == probItem.chaStr) {
          probItem.isMatch = true;
          wordItem.isMatch = true;
          _perfectValue = 2;

          bool tmpFlag = true;
          for(int i = 0; i < _problemItems.length; i++){
            if (!_problemItems[i].isMatch){
              tmpFlag = false;
            }
          }
          if (tmpFlag) _perfectValue = 3;
        }else{
          _perfectValue = 1;
        }
        _isPerfectAnimation = true;
        startPerfectTimer();
      }
    });
  }

  void getCurrentProblemData() {
    // 四字熟語文字の取得
    //----------------------------------------------------------
    if(_problemIndex < 1) {
      _problemIndex = 1;
    }

    _mainProblemData = _dbData[_problemIndex-1];
    String problemString = _mainProblemData['character'];
    var arr = problemString.split('');

    var random = new Random();

    _randIndex1 = random.nextInt(6);
    if (_randIndex1 == 0) _randIndex1 = 1;

    _randIndex2 = random.nextInt(6);
    if (_randIndex2 == 0) _randIndex2 = 1;

    _randIndex3 = random.nextInt(6);
    if (_randIndex3 == 0) _randIndex3 = 1;

    _randIndex4 = random.nextInt(6);
    if (_randIndex4 == 0) _randIndex4 = 1;

    _problemItems.clear();
    for(int i = 0; i < arr.length; i++){
      _problemItems.add(CharItem(chaStr: arr[i], textWidget: Text(arr[i], style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(50, allowFontScalingSelf: true), fontFamily: 'YUGOTHIC'))));
    }
    //----------------------------------------------------------

    //下に表示される漢字の取得
    //----------------------------------------------------------
    String charString = '';
    for(int i = 0; i < _dbData.length; i++){
      if (_mainProblemData['_id'] != _dbData[i]['_id']){
        charString = charString + _dbData[i]['character'];
      }
    }

    List<String> tmpCharArray = arr;
    var charArray = charString.split('');
    charArray = List.from(charArray)..shuffle();
    for(int i = 0; i < charArray.length; i++){
      bool isDuplicate = false;
      for (int j = 0; j < arr.length; j++){
        if (arr[j] == charArray[i]){
          isDuplicate = true;
          break;
        }
      }
      if(!isDuplicate && tmpCharArray.length < 11) {
        tmpCharArray.add(charArray[i]);
      }
    }
    charArray.clear();

    _chaItems.clear();
    tmpCharArray = List.from(tmpCharArray)..shuffle();
    for(int i = 0; i < tmpCharArray.length; i++){
      _chaItems.add(CharItem(chaStr: tmpCharArray[i], textWidget: Text(tmpCharArray[i], style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(50, allowFontScalingSelf: true), fontFamily: 'YUGOTHIC'))));
    }
    tmpCharArray.clear();

    setState(() {

    });

  }

  Future getProblemDataArray({int start, int count}) async {

    List<Map<String, dynamic>> tmpArray = [];

    // databaseからデータの取得
    String queryStr = ' WHERE play_flag = 0 ORDER BY _id ASC LIMIT $start, $count';
    final allRows = await dbHelper.querySelectRows(whereQuery: queryStr);
    allRows.forEach((Map<String, dynamic> row) =>
        tmpArray.add(row)
    );

    // データのRandom処理
    tmpArray = List.from(tmpArray)..shuffle();
    _dbData.clear();
    for(int i = 0; i < tmpArray.length; i ++){
      _dbData.add(tmpArray[i]);
    }
    tmpArray.clear();

    getCurrentProblemData();

  }

  void showHintAction (bool visibility) {
    setState(() {
      _showHintFlag = visibility;
    });
  }

  void closeButtonAction () {
    Navigator.pop(context);
  }

  void skipButtonAction () {
    _problemIndex ++;
    initData();
    if (_problemIndex < LIMIT_CNT + 1) {
      getCurrentProblemData();
    }else{
      _problemIndex = 1;
      interstitialAd.show();
      showResultScreen();
    }
  }

  Widget _buildHeaderWidget() {
    return Container(
      padding: EdgeInsets.only(right: ScreenUtil().setWidth(10), left: ScreenUtil().setWidth(10), top: ScreenUtil().setHeight(10)),
      width:  ScreenUtil().setWidth(AppConst.designSizeWidth),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: ScreenUtil().setWidth(90),
            alignment: Alignment.centerLeft,
            child:
            TextButton(
              onPressed: () => { },
                child: Text('$_problemIndex/10', style: TextStyle(color: Color.fromRGBO(151, 152, 151, 1.0), fontSize: ScreenUtil().setSp(18, allowFontScalingSelf: true)),)
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(90),
            child:
            TextButton(
                onPressed: closeButtonAction,
                child: Text('閉じる', style: TextStyle(color: Color.fromRGBO(151, 152, 151, 1.0), fontSize: ScreenUtil().setSp(18, allowFontScalingSelf: true)),)
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(90),
            child:
            TextButton(
                onPressed: skipButtonAction,
                child: Text('スキップ', style: TextStyle(color: Color.fromRGBO(151, 152, 151, 1.0), fontSize: ScreenUtil().setSp(18, allowFontScalingSelf: true)),)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintBtn({String hintString}){
    return Container(
      width: ScreenUtil().setWidth(AppConst.designSizeWidth),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: _showHintFlag,
            child: Container(
              width: ScreenUtil().setWidth(320),
              height: ScreenUtil().setHeight(70),
              alignment: Alignment.center,
              child: new Text(hintString, style: TextStyle(height: null, fontSize: ScreenUtil().setSp(15, allowFontScalingSelf: true)) ,),
            ),
          ),
          Visibility(
            visible: !_showHintFlag,
            child: new MaterialButton(
              onPressed:(){
                showHintAction(true);
              },
              child: Container(
                width: ScreenUtil().setWidth(91),
                height: ScreenUtil().setHeight(70),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/images/second_hinto_btn.png'),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbLabel({int probNumber}){
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.only(left: ScreenUtil().setWidth(35)),
        child: Text(_problemItems.length > 0 ? '問$probNumber' : '',style: TextStyle(fontSize: ScreenUtil().setSp(30, allowFontScalingSelf: true), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProbContent({double largeCellWidth, double fontSize}) {
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if(_problemItems.length > 0) _buildProbWithDropZone(_problemItems[0], 1, _randIndex1),
            if(_problemItems.length > 1) _buildProbWithDropZone(_problemItems[1], 2, _randIndex2),
            if(_problemItems.length > 2) _buildProbWithDropZone(_problemItems[2], 2, _randIndex3),
            if(_problemItems.length > 3) _buildProbWithDropZone(_problemItems[3], 3, _randIndex4),
          ],
        ),
      ),
    );
  }

  Widget _buildProbWithDropZone(CharItem probItem, int frameIndex, int index) {
    return DragTarget<CharItem>(
      builder: (context, candidateItems, rejectedItems) {
        return ProblemCart(probItem: probItem, cardWidth: ScreenUtil().setWidth(AppConst.problemCardWidth), fontSize: ScreenUtil().setSp(AppConst.problemFontSize, allowFontScalingSelf: true), frameIndex: frameIndex, index: index,);
      },
      onAccept: (item){
        _wordDroppedOnProbCard(wordItem: item, probItem: probItem);
      },
    );
  }

  Widget _buildWordCard({
    @required CharItem wordItem,
  }) {
    return Draggable(
      data: wordItem,
      dragAnchor: DragAnchor.pointer,
      child: WordCard(
        textWidget: wordItem.textWidget,
        cartWidth: ScreenUtil().setWidth(AppConst.problemCardWidth),
        isHidden: wordItem.isMatch,
      ),
      feedback: DraggingItem(str: wordItem.chaStr, fontSize: ScreenUtil().setSp(AppConst.problemFontSize, allowFontScalingSelf: true), dragKey: _draggableKey, cardWidth: ScreenUtil().setWidth(AppConst.problemCardWidth),),
      childWhenDragging: Container(),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        SafeArea(
            child: Column(
              children: [
                _buildHeaderWidget(),
                Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(5))),
                if(_mainProblemData != null) _buildHintBtn(hintString: _mainProblemData['mean']),
                Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(5))),
                _buildProbLabel(probNumber: _problemIndex),
                _buildProbContent(largeCellWidth: ScreenUtil().setWidth(AppConst.problemCardWidth), fontSize: ScreenUtil().setSp(AppConst.problemFontSize, allowFontScalingSelf: true)),
                Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(5))),
                Expanded(
                  // child: _buildWordList(),
                  child: Stack(
                    children: [
                      if (_chaItems.length > 0 ) Positioned(
                        top: ScreenUtil().setHeight(10),
                        left: ScreenUtil().setWidth(AppConst.cardSpace),
                        child: _buildWordCard(wordItem: _chaItems[0]),
                      ),
                      if (_chaItems.length > 1) Positioned(
                          top: ScreenUtil().setHeight(30),
                          left: ScreenUtil().setWidth(AppConst.cardSpace)*2+ScreenUtil().setWidth(AppConst.problemCardWidth) + ScreenUtil().setWidth(20),
                          child: _buildWordCard(wordItem: _chaItems[1])
                      ),
                      if (_chaItems.length > 2) Positioned(
                          top: ScreenUtil().setHeight(8),
                          left: ScreenUtil().setWidth(AppConst.cardSpace)*3+ScreenUtil().setWidth(AppConst.problemCardWidth)*2 + ScreenUtil().setWidth(30),
                          child: _buildWordCard(wordItem: _chaItems[2])
                      ),
                      if (_chaItems.length > 3) Positioned(
                          top: ScreenUtil().setHeight(AppConst.problemCardWidth +13),
                          left: ScreenUtil().setWidth(AppConst.cardSpace) + ScreenUtil().setWidth(20),
                          child: _buildWordCard(wordItem: _chaItems[3])
                      ),
                      if (_chaItems.length > 4) Positioned(
                          top: ScreenUtil().setHeight(AppConst.problemCardWidth +43),
                          left: ScreenUtil().setWidth(AppConst.cardSpace)*2 +  ScreenUtil().setWidth(AppConst.problemCardWidth) + ScreenUtil().setWidth(25),
                          child: _buildWordCard(wordItem: _chaItems[4])
                      ),
                      if (_chaItems.length > 5) Positioned(
                          top: ScreenUtil().setHeight(AppConst.problemCardWidth + 13),
                          left: ScreenUtil().setWidth(AppConst.cardSpace)*3 + ScreenUtil().setWidth(AppConst.problemCardWidth*2) + ScreenUtil().setWidth(25),
                          child: _buildWordCard(wordItem: _chaItems[5])
                      ),
                      if (_chaItems.length > 6) Positioned(
                          top: ScreenUtil().setHeight(AppConst.problemCardWidth*2 + 23),
                          left: ScreenUtil().setWidth(AppConst.cardSpace),
                          child: _buildWordCard(wordItem: _chaItems[6])
                      ),
                      if (_chaItems.length > 7) Positioned(
                          top: ScreenUtil().setHeight(AppConst.problemCardWidth*2 + 38),
                          left: ScreenUtil().setWidth(AppConst.cardSpace)*2 + ScreenUtil().setWidth(AppConst.problemCardWidth),
                          child: _buildWordCard(wordItem: _chaItems[7])
                      ),
                      if (_chaItems.length > 8) Positioned(
                          top: ScreenUtil().setHeight(AppConst.problemCardWidth*2 + 18),
                          left: ScreenUtil().setWidth(AppConst.cardSpace*3 + AppConst.problemCardWidth*2 + 20),
                          child: _buildWordCard(wordItem: _chaItems[8])
                      ),
                      if (_chaItems.length > 9) Positioned(
                          top: ScreenUtil().setHeight(AppConst.problemCardWidth*3 + AppConst.cardSpace-8),
                          left: ScreenUtil().setWidth(AppConst.cardSpace*2 + AppConst.problemCardWidth*2),
                          child: _buildWordCard(wordItem: _chaItems[9])
                      ),
                      if (_chaItems.length > 10) Positioned(
                          top: ScreenUtil().setHeight(AppConst.problemCardWidth*3 + AppConst.cardSpace + 5),
                          left: ScreenUtil().setWidth(AppConst.cardSpace*2 + 30),
                          child: _buildWordCard(wordItem: _chaItems[10])
                      ),
                    ],
                  ),
                ),
              ],
            )
        ),
        Container(
          width: ScreenUtil().setWidth(AppConst.designSizeWidth),
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(140)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_perfectValue == 1) Image.asset('assets/images/incorrect.png', fit: BoxFit.fill,),
              if (_perfectValue == 2) Image.asset('assets/images/correct.png', fit: BoxFit.fill,),
              if (_perfectValue == 3) Image.asset('assets/images/perfect.png', fit: BoxFit.fill,),
              Padding(padding: EdgeInsets.only(top: 50)),
              if (_perfectValue == 3) Opacity(
                opacity: 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 0,
                      color: Colors.transparent,
                      child:ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          alignment: Alignment.center,
                          width: ScreenUtil().setWidth(AppConst.designSizeWidth)/2+50,
                          height: ScreenUtil().setHeight(60),
                          color: Colors.black,
                          padding: EdgeInsets.all(8),
                          child: Text(_mainProblemData["read"], style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showResultScreen () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(currentOffset: _queryLimitStart+LIMIT_CNT, correctCount: _correctCnt, inCorrectCount: LIMIT_CNT),
      ),
    );

    interstitialAd.show();

    _queryLimitStart = result;

    _problemIndex = 1;
    _correctCnt = 0;
    getProblemDataArray(start: _queryLimitStart, count: LIMIT_CNT);
    setState(() {

    });
  }

  void startPerfectTimer(){

    _perfectTimer = new Timer.periodic(
        _perfectValue < 3 ? const Duration(milliseconds: 300) : const Duration(seconds: 2),
            (Timer timer) {
          if (_perfectValue > 0) {
            if (_perfectValue == 3) {

              _correctCnt ++;

              _problemIndex ++;
              initData();
              if (_problemIndex < LIMIT_CNT + 1) {
              // if (_problemIndex < 3) {
                getCurrentProblemData();
              }else{
                _problemIndex = 1;
                interstitialAd.show();
                showResultScreen();
              }
            }
            _perfectValue = 0;
          }else {
            setState(() {
              _isPerfectAnimation = false;
              timer.cancel();
            });
          }
        }
    );
  }

}

class ProblemCart extends StatelessWidget {

  const ProblemCart({
    Key key,
    @required this.probItem,
    @required this.cardWidth,
    @required this.fontSize,
    @required this.frameIndex,
    this.index = 1,
    this.highlighted = false,
    this.hashItems = false,
  }) : super(key: key);

  final CharItem probItem;
  final bool highlighted;
  final bool hashItems;
  final double cardWidth;
  final double fontSize;
  final int frameIndex;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: !probItem.isMatch,
          child: Stack(
            children: [
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                width: cardWidth,
                height: cardWidth,
                padding: EdgeInsets.only(top: 1),
                child: Text(probItem.chaStr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, fontFamily: 'YUGOTHIC', height: 1.28),),
              ),
              Container(
                // color: Colors.white,
                alignment: Alignment.center,
                width: cardWidth,
                height: cardWidth,
                child: Image.asset('assets/images/frame_hint_$frameIndex'+'_$index.png', fit: BoxFit.fill,)
              ),
            ],
          ),
        ),
        Visibility(
          visible: probItem.isMatch,
          child: Stack(
            children: [
              Container(
                color: Colors.white,
                  alignment: Alignment.center,
                  width: cardWidth,
                  height: cardWidth,
                  child: Image.asset('assets/images/frame_hint_$frameIndex'+'_$index.png', fit: BoxFit.fill,)
              ),
              Container(
                alignment: Alignment.center,
                width: cardWidth,
                height: cardWidth,
                child: Text(probItem.chaStr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, fontFamily: 'YUGOTHIC', height: 1.28),),
              ),
            ],
          ),
        ),
      ],
    );
  }
}