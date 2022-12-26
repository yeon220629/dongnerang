import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class seoulUrlLoadScreen extends StatefulWidget {
  final Uri s;
  const seoulUrlLoadScreen(this.s);
  @override
  State<seoulUrlLoadScreen> createState() => _seoulUrlLoadScreenState();
}

class _seoulUrlLoadScreenState extends State<seoulUrlLoadScreen> {
  //애드몹 테스트 ID
  final String iOSTestId = 'ca-app-pub-3940256099942544/2934735716';
  final String androidTestId = 'ca-app-pub-3940256099942544/6300978111';

  //애드몹 찐 ID
  final String iOSRealId = 'ca-app-pub-3415104781631988/3367223383';
  final String androidRealId = 'ca-app-pub-3415104781631988/9379594822';
  BannerAd? banner;

  static const platform = MethodChannel('fcm_default_channel');

  bool toggle = false;
  InAppWebViewController? webViewController;
  late PullToRefreshController pullToRefreshController = PullToRefreshController();

  String url = '';
  double progress = 0;
  final urlController = TextEditingController();
  @override
  void initState() {
    super.initState();
    //애드몹
    banner = BannerAd(
      size: AdSize.banner,
      // adUnitId: Platform.isIOS ? iOSRealId : androidRealId,
      adUnitId: Platform.isIOS ? iOSTestId : androidTestId,
      listener: BannerAdListener(),
      request: AdRequest(),
    )..load();

    pullToRefreshController = PullToRefreshController(
        onRefresh: () async {
          webViewController?.reload();
        }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getAppUrl(String url) async {
    await platform.invokeMethod('getAppUrl', <String, Object>{'url': url}).then((value) async{
      if(value.toString().startsWith('ispmobile://')) {
        await platform.invokeMethod('startAct', <String, Object>{'url': url}).then((value) {
          return;
        });
      }

      if (await canLaunchUrl(Uri.parse(value))) {
        await launchUrl(Uri.parse(value),);
        return;
      } else {
        EasyLoading.showError('해당 앱 설치 후 이용바랍니다.');
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(Platform.isAndroid){
      return WillPopScope(
          onWillPop: (){
            var future = webViewController?.canGoBack();
            future?.then((canGoBack) {
              if (canGoBack) {
                webViewController?.goBack();
              } else {
                print('더 이상 뒤로 갈 페이지가 없습니다.');
                Navigator.pop(context);
                //뒤로가기 시 처리코드
              }
            });
            return Future.value(false);
          },
          child : ScaffordPlatform(),
      );
    }
    return ScaffordPlatform();
  }
  Widget ScaffordPlatform(){
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri.uri(widget.s)),
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      var uri = navigationAction.request.url!;
                      if(!uri.scheme.startsWith('http') && !uri.scheme.startsWith('https')) {
                        if(Platform.isAndroid) {
                          getAppUrl(navigationAction.request.url.toString());
                          return NavigationActionPolicy.CANCEL;
                        }else if(Platform.isIOS){
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                            return NavigationActionPolicy.CANCEL;
                          }
                        }
                      }
                      if (![ "http", "https", "file", "chrome",
                        "data", "javascript", "about"].contains(uri.scheme)) {
                        return NavigationActionPolicy.CANCEL;
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController.endRefreshing();
                      }
                      setState(() {
                        this.progress = progress / 100;
                        urlController.text = this.url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print(consoleMessage);
                    },
                  ),
                  progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container(),
                ],
              ),
            ),
            // //애드몹
            StatefulBuilder(
              builder: (context, setState) => Container(height: 50,
                width: size.width,
                child: this.banner == null
                    ? Container()
                    : AdWidget( ad: this.banner!,),),
            ),
          ],
        ),
      ),
    );
  }
}
