
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_fourcharacter/Screeen/playScreen.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter_fourcharacter/const/appconst.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  AdmobInterstitial interstitialAd;

  @override
  void initState() {
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
        // print('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        // print('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        // showPalyScreen();
        break;
      case AdmobAdEvent.failedToLoad:
        interstitialAd.show();
        // print('Admob $adType failed to load. :(');
        break;
      default:
    }
  }

  void showPalyScreen(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) {
          return PlayScreen();
        })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 248, 229, 1.0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/images/first_main_bg.png'),
            ),
            Padding(padding: EdgeInsets.only(top: 30)),
            ElevatedButton(
              onPressed: () {
                interstitialAd.show();
                showPalyScreen();
              },
              child: Text('スタート', style: TextStyle(fontSize: 25),),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed))
                      return Color.fromRGBO(223, 37, 37, 0.7);
                    return Color.fromRGBO(223, 37, 37, 1.0); // Use the component's default.
                  },
                ),
                padding: MaterialStateProperty.all(EdgeInsets.only(top: 7, bottom: 7, left: 15, right: 15))
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: AdmobBanner (
        adUnitId: AppConst.getBannerAdUnitId(),
        adSize: AdmobBannerSize.BANNER,
      ),
    );
  }
}
