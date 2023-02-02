import 'dart:io';
import 'package:dongnerang/screens/mainScreenBar.dart';
import 'package:dongnerang/screens/search.screen.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:dongnerang/util/admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../constants/colors.constants.dart';
import 'mypage/mypage.screen.dart';


class urlLoadScreen extends StatefulWidget {
  final Uri urldata;
  final s; final o; final j; final i;
  const urlLoadScreen( this.urldata, this.s, this.o, this.j, this.i);

  @override
  State<urlLoadScreen> createState() => _urlLoadScreenState();
}

class _urlLoadScreenState extends State<urlLoadScreen> {
  bool toggle = false;

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController = PullToRefreshController();
  String url = "";
  double progress = 0;

  final urlController = TextEditingController();


  @override
  void initState() {
    super.initState();

    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    // 사용자 북마크 클릭시 저장 여부 판단 부분 -> 현재 return 값을 bool 값으로 주고있음
    Future<bool> toggleVal = FirebaseService.getUserSaveToggleData(userEmail!,widget.s);
    toggleVal.then((value) {
      toggle = value;
    });

    pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(
          color : Colors.blue,
        ),
        onRefresh: () async {
          webViewController?.reload();
        }
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _firstMainScreenProvider = Provider.of<FirstMainScreenProvider>(context);
    List saveData = [];
    if(Platform.isAndroid){
      return WillPopScope(
          child: checkFlactform(saveData),
          onWillPop: (){
            var future = webViewController?.canGoBack();
            future?.then((canGoBack) {
              if (canGoBack) {
                webViewController?.goBack();
              } else {
                print('더이상 뒤로갈페이지가 없습니다.');
                // Navigator.pop(context);
                if(toggle != true){
                  if(widget.i == 1){
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (BuildContext context) =>
                            mainScreen()), (route) => false);
                  }else{
                    Navigator.pop(context);
                  }
                }else{
                  Navigator.pop(context);
                }
                // if(toggle == true){
                //   if(widget.i == 0){
                //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                //         builder: (BuildContext context) =>
                //             mainScreen()), (route) => false);
                //   }
                //   if(widget.i == 1){
                //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                //         builder: (BuildContext context) =>
                //             mainScreen()), (route) => false);
                //   }
                //   if(widget.i == 2){
                //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                //         builder: (BuildContext context) =>
                //             searchScreen(title: "")), (route) => false);
                //   }
                // }else{
                //   if(widget.i == 0){
                //     Navigator.pop(context);
                //   }
                //   if(widget.i == 1){
                //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                //         builder: (BuildContext context) =>
                //             mainScreen()), (route) => false);
                //   }
                //   if(widget.i == 2){
                //     Navigator.pop(context);
                //   }
                // }
                //뒤로가기 시 처리코드
              }
            });
            return Future.value(false);
          }
      );
    }
    return checkFlactform(saveData);
  }
  Widget checkFlactform(saveData){
    final Size size = MediaQuery.of(context).size;
    return MaterialApp(
        theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                }
            )
        ),
        home: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: AppColors.primary,
            ),
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                //페이지 리로드
                onPressed: (){
                  if(toggle != true){
                    if(widget.i == 1){
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                      builder: (BuildContext context) => mainScreen()), (route) => false);
                    }else{
                      Navigator.pop(context);
                    }
                  }else{
                    Navigator.pop(context);
                  }
                  // if(toggle == true){
                  //   // 메인 페이지
                  //   if(widget.i == 0){
                  //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  //         builder: (BuildContext context) =>
                  //             mainScreen()), (route) => false);
                  //   }
                  //   if(widget.i == 1){
                  //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  //         builder: (BuildContext context) =>
                  //             mainScreen()), (route) => false);
                  //   }
                  //   if(widget.i == 2){
                  //     Navigator.pop(context);
                  //   }
                  // }else{
                  //   if(widget.i == 0){
                  //     Navigator.pop(context);
                  //   }
                  //   if(widget.i == 1){
                  //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  //         builder: (BuildContext context) =>
                  //             mainScreen()), (route) => false);
                  //   }
                  //   if(widget.i == 2){
                  //     Navigator.pop(context);
                  //   }
                  // }
                }
            ),
            actions: [
              IconButton(onPressed: (){
                saveData = [];
                setState(() {
                  toggle = !toggle;
                });
                String? userEmail = FirebaseAuth.instance.currentUser?.email;
                var widgetTime = widget.j;
                if(widget.j.runtimeType == String){
                  widgetTime = DateTime.parse(widget.j);
                }

                if(toggle){
                  saveData.add(widget.urldata.toString());
                  saveData.add(widget.o);
                  saveData.add(widgetTime);
                  saveData.add(widget.s);
                  saveData.add(toggle);
                  FirebaseService.saveUserPrivacyData(userEmail!, saveData);
                  // mypageScreen(1);
                }
                if(!toggle){
                  FirebaseService.deleteUserPrivacyData(userEmail!, widget.s);
                }
              },
                  icon: toggle
                      ? Icon(Icons.bookmark, color: Colors.black)
                      : Icon(Icons.bookmark_border_rounded, color: Colors.black)
              ),

              IconButton(onPressed: ()async {
                String firebasesUrl = widget.urldata.toString();
                final TextTemplate defaultText = TextTemplate(
                  text:
                  '우리 동네의 모든 공공소식 \'동네랑\'\n\n[${widget.o}]\n${widget.s}\n\n',
                  link: Link(
                    webUrl: Uri.parse('$firebasesUrl'),
                    mobileWebUrl: Uri.parse('$firebasesUrl'),
                  ),
                );
                // 카카오톡 실행 가능 여부 확인
                bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
                if (isKakaoTalkSharingAvailable) {
                  print('카카오톡으로 공유 가능');
                  try{
                    // Uri uri = await ShareClient.instance.shareScrap(url: firebasesUrl);
                    // await ShareClient.instance.launchKakaoTalk(uri);
                    Uri uri = await ShareClient.instance.shareDefault(template: defaultText);
                    await ShareClient.instance.launchKakaoTalk(uri);
                    // EasyLoading.showSuccess("공유 완료");
                  }catch (e){
                    print('카카오톡 공유 실패 $e');
                  }
                } else {
                  print('카카오톡 미설치: 웹 공유 기능 사용 권장');
                  EasyLoading.showError("카카오톡 미설치: 웹 공유 기능 사용 권장");
                }
              }, icon: const Icon(Icons.share_outlined, color: Colors.black)),
            ],
          ),
          // 백키옵션
          body:SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    // alignment: Alignment.bottomCenter,
                    children: [
                      InAppWebView(
                        // key: webViewKey,
                        // initialUrlRequest: URLRequest(url: Uri.parse("https://inappwebview.dev/")),
                        initialUrlRequest: URLRequest(url: WebUri.uri(widget.urldata)),
                        initialOptions: options,
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
                        androidOnPermissionRequest: (controller, origin, resources) async {
                          return PermissionRequestResponse(
                              resources: resources,
                              action: PermissionRequestResponseAction.GRANT);
                        },
                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                          var uri = navigationAction.request.url!;

                          if (![ "http", "https", "file", "chrome",
                            "data", "javascript", "about"].contains(uri.scheme)) {
                            return NavigationActionPolicy.CANCEL;
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadError: (controller, url, code, message) {
                          pullToRefreshController.endRefreshing();
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
                //애드몹
                BannerAdMob(),
              ],
            ),
          ),
        )
    );
  }
}


