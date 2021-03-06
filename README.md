# 四字熟語アプリ

「開発環境」
------------------------------------------------------------------

macOS Big Sur 11.3 , FlutterSDK2.0.3, AndroidStudio4.1.3

------------------------------------------------------------------

「開発環境の構築方法」
------------------------------------------------------------------

・ FlutterSDKを入手する
1.https://storage.googleapis.com/flutter_infra/releases/stable/macos/flutter_macos_2.0.3-stable.zip
でflutter_macos_2.0.3-stable.zipをダウンロードしてください。
2.zipファイル解凍後「flutter」フォルダが表示されるので、そのフォルダをユーザー名直下に移動させる。

・ パスの設定
1. flutter直下のbinフォルダを右クリック後、「optionキー」を長押しし表示された、「”bin”のパス名をコピー」クリックしてコピーする。
2. ターミナルを起動して
  echo export PATH="$PATH:1でコピーしたflutter直下のbinまでのパスに変更" >> ~/.bash_profile
  を実行する。
3. 一度ターミナルを閉じて、もう一度ターミナルを開く。
4. echo export PATH="$PATH:1でコピーしたflutter直下のbinまでのパスに変更" >> ~/.zshrc
   を実行する。
5. 一度ターミナルを閉じて、もう一度ターミナルを開く。

・Android Studioをインストールします。
Android Studioをインストールして、エミュレーターを作成します。

・Xcodeをインストールします。


MacOSでのFlutter開発環境構築の詳細は
URL : https://note.com/hatchoutschool/n/n9846d3b90a02#wn2Yk
を参照してください。

------------------------------------------------------------------

 「ローカルでのテスト方法」
------------------------------------------------------------------

1.PCの任意の位置にflutter_fourcharacterプロジェクトをコピー
2.Android Studioでflutter_fourcharacterプロジェクトのオープン
3.Android StudioのAVD Managerでエミュレーターの開始
4.Android StudioのメニューのRunで「Run ’main.dart’」を選択

------------------------------------------------------------------

「ビルド方法」
------------------------------------------------------------------

・Android
Android StudioのTerminalで下の命令を入力します。
flutter clean (プロジェクトのクリーン)
flutter build apk --release (プロジェクトのビルド)

・iOS
1. iOS Certificate の作成する。
https://i-app-tec.com/ios/apply-application.html
を参照してください。
2. App IDs を登録する
https://i-app-tec.com/ios/ios-app-ids.html
を参照してください。
3. Provisioning Profile を作成する。
https://i-app-tec.com/ios/provisioning-profile.html
を参照してください。
4. Xcodeでビルド設定
flutter_fourcharacter/ios/Runner.xcodeproj
をダブルクリックしてXcodeを起動する。
5. 開発用のProvisioning Profileを選択して、実機でビルドする。
   申請時には、配布用のProvisioning Profileを選択する。
   https://i-app-tec.com/ios/app-upload.html
   を参照してください。

------------------------------------------------------------------