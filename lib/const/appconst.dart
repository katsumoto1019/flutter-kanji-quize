
import 'dart:io';

class AppConst {
  static final double designSizeWidth = 360;
  static final double designSizeHeight = 690;

  static final double problemCardWidth = 75;
  static final double cardSpace = 33.75;
  static final problemFontSize = 55;

  static String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3148915736664098/8890537179';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3148915736664098/6185849760';
    }
    return null;
  }

  static String getInterstitialAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3148915736664098/6072802140';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3148915736664098/4414722658';
    }
    return null;
  }
}