import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:dongnerang/screens/mainScreenBar.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/colors.constants.dart';


class urlLoadScreen extends StatefulWidget {
  final Uri urldata;
  final s; final o; final j; final i;
  //url, post["title"], post['center_name '], dateTime, 0
  const urlLoadScreen( this.urldata, this.s, this.o, this.j, this.i);

  @override
  State<urlLoadScreen> createState() => _urlLoadScreenState();
}

class _urlLoadScreenState extends State<urlLoadScreen> {
  bool toggle = false;

  InAppWebViewController? webViewController;
  InAppWebViewSettings setting = InAppWebViewSettings(

  );

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        useOnDownloadStart: true,
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
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  final ReceivePort _port = ReceivePort();

  @pragma('vm:entry-point')
  static void downloadCallback(String id, DownloadTaskStatus status, int downloadProgress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, downloadProgress]);
  }


  Future<Uri> _createDynamicLink() async {
    var _url = widget.urldata.toString();
    var title = widget.s.toString();
    var centername = widget.o.toString();
    var timedate = widget.j;
    var number = widget.i;

    final dynamicLinkPrefix = 'https://dongnerang.page.link';
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: dynamicLinkPrefix,
      // link: Uri.parse('${dynamicLinkPrefix}/deeplink?id=test'),
      link: Uri.parse(
        //url, post["title"], post['center_name '], dateTime, 0
        //   '${dynamicLinkPrefix}/deeplink?url=$_url&title=$title&centername=$centername&timedate=$timedate&number=$number',
        '${dynamicLinkPrefix}/deeplink?title=$title&centername=$centername&timedate=$timedate&number=$number&url=$_url',
      ),
      androidParameters: const AndroidParameters(
        packageName: 'com.dongnerang.com.dongnerang',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.dongnerang.com.dongnerang',
        minimumVersion: '0',
      ),
    );
    final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
    Uri url = shortLink.shortUrl;
    // print("url : ${url}"); //queryParameters 값을 받아옴
    return url;
  }

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
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){ });
    });
    FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    IsolateNameServer.removePortNameMapping('downloader_send_port');
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
                print('더이상 뒤로 갈 페이지가 없습니다.');
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
                // _createDynamicLink().then((value) async {
                  final TextTemplate defaultText = TextTemplate(
                    text:
                    '우리 동네의 모든 공공소식 \'동네랑\'\n\n[${widget.o}]\n${widget.s}\n\n',
                    link: Link(
                      webUrl: Uri.parse('${widget.urldata.toString()}'),
                      mobileWebUrl: Uri.parse('${widget.urldata.toString()}'),
                    ),
                  );
                  // 카카오톡 실행 가능 여부 확인
                  bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
                  if (isKakaoTalkSharingAvailable) {
                    print('카카오톡으로 공유 가능');
                    try{
                      Uri uri = await ShareClient.instance.shareDefault(template: defaultText);
                                await ShareClient.instance.launchKakaoTalk(uri);
                    }catch (e){
                      print('카카오톡 공유 실패 $e');
                    }
                  } else {
                    print('카카오톡 미설치: 웹 공유 기능 사용 권장');
                    // print("firebasesUrl : ${value}");

                    EasyLoading.showError("카카오톡 미설치: 카카오톡 다운로드 권장");
                  }
                // });
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
                        // initialSettings: options,
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
                        onDownloadStartRequest: (InAppWebViewController controller, DownloadStartRequest downloadStartRequest) async {
                          final directory = await getApplicationDocumentsDirectory();
                          var savedDirPath = directory.path;

                          await FlutterDownloader.enqueue(
                            url: downloadStartRequest.url.toString(),
                            savedDir: savedDirPath,
                            saveInPublicStorage: true,
                            showNotification: true,
                            openFileFromNotification: true,
                          );
                        },
                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                          var uri = navigationAction.request.url!;

                          if (![ "http", "https", "file", "chrome",
                            "data", "javascript", "about"].contains(uri.scheme)) {
                            return NavigationActionPolicy.CANCEL;
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onReceivedError: (controller, request, error) {
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
                          print("messageLevel : ${consoleMessage.messageLevel}");
                          print("message : ${consoleMessage.message}");
                        },
                      ),
                      progress < 1.0
                          ? LinearProgressIndicator(value: progress)
                          : Container(),
                    ],
                  ),
                ),
                //애드몹
                // BannerAdMob(),
              ],
            ),
          ),
        )
    );
  }
}


