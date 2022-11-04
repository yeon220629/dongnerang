import 'package:dongnerang/screens/mainScreenBar.dart';
import 'package:dongnerang/screens/search.screen.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../constants/colors.constants.dart';


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
  List saveData = [];
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(
        color: AppColors.primary,
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        //페이지 리로드
        onPressed: (){
          print("toggle : $toggle");
          if(toggle == true){
            // 메인 페이지
            if(widget.i == 0){
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (BuildContext context) =>
                      mainScreen()), (route) => false);
            }
            if(widget.i == 1){
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (BuildContext context) =>
                      mainScreen()), (route) => false);
            }
            if(widget.i == 2){
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (BuildContext context) =>
                      searchScreen(title: "")), (route) => false);
            }
          }else{
            Navigator.pop(context);
          }
        }
      ),
      actions: [
          IconButton(onPressed: (){
            saveData = [];
            setState(() {
              toggle = !toggle;
            });
            String? userEmail = FirebaseAuth.instance.currentUser?.email;
            if(toggle){
              saveData.add(widget.urldata.toString());
              saveData.add(widget.o);
              saveData.add(widget.j);
              saveData.add(widget.s);
              saveData.add(toggle);
              FirebaseService.saveUserPrivacyData(userEmail!, saveData);
            }
            if(!toggle){
              FirebaseService.deleteUserPrivacyData(userEmail!, widget.s);
            }
          },
          icon: toggle
              ? Icon(Icons.bookmark)
              : Icon(Icons.bookmark_border_rounded)
          ),

          IconButton(onPressed: ()async {
            String firebasesUrl = widget.urldata.toString();
            // print("firebasesUrl : $firebasesUrl");
            final TextTemplate defaultText = TextTemplate(
              text:
              '우리 동네의 모든 공공소식 \'동네랑\'\n\n[${widget.o}] ${widget.s}\n\n${firebasesUrl}',
              link: Link(
                webUrl: Uri.parse('firebasesUrl'),
                mobileWebUrl: Uri.parse('firebasesUrl'),
              ),
            );
            // 카카오톡 실행 가능 여부 확인
            bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
            if (isKakaoTalkSharingAvailable) {
              print('카카오톡으로 공유 가능');
              try{
                Uri uri =
                  await ShareClient.instance.shareDefault(template: defaultText);
                  await ShareClient.instance.launchKakaoTalk(uri);
                // EasyLoading.showSuccess("공유 완료");
              }catch (e){
                print('카카오톡 공유 실패 $e');
              }
            } else {
              print('카카오톡 미설치: 웹 공유 기능 사용 권장');
            }

          // Get.to(() => NoticePage()),
        }, icon: const Icon(Icons.share)),
        ],
    ),
    body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
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
          ],
        ),
      ),
    );
  }
}
