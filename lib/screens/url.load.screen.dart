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
  final s; final o; final j;
  const urlLoadScreen( this.urldata, this.s, this.o, this.j);

  @override
  State<urlLoadScreen> createState() => _urlLoadScreenState();
}

class _urlLoadScreenState extends State<urlLoadScreen> {

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
        actions: [
          IconButton(onPressed: (){
            String? userEmail = FirebaseAuth.instance.currentUser?.email;
            saveData.add(widget.urldata.toString());
            saveData.add(widget.o);
            saveData.add(widget.j);
            saveData.add(widget.s);
            FirebaseService.saveUserPrivacyData(userEmail!, saveData);
            // Get.to(() => NoticePage()),
          }, icon: const Icon(Icons.bookmark_border_rounded)),
          IconButton(onPressed: ()async {
            // 사용자 정의 템플릿 ID
            // String url = "https://developers.kakao.com";
            String firebasesUrl = widget.urldata.toString();
            int templateId = 83950;

            print("firebasesUrl : $firebasesUrl");

            // 카카오톡 실행 가능 여부 확인
            bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
            if (isKakaoTalkSharingAvailable) {
              print('카카오톡으로 공유 가능');
              try{
                Uri uri = await ShareClient.instance.shareScrap(url: firebasesUrl, templateId: templateId);
                await ShareClient.instance.launchKakaoTalk(uri);
                print('카카오톡 공유 완료');
                EasyLoading.showSuccess("공유 완료");
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
                    initialUrlRequest: URLRequest(url: widget.urldata),
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
            //버릴거!!
            // BottomNavigationBar(
            //   showUnselectedLabels: true,
            //   showSelectedLabels: true,
            //   selectedLabelStyle: const TextStyle(color: Colors.red),
            //   selectedItemColor: AppColors.primary,
            //   unselectedItemColor: AppColors.grey,
            //   items: [
            //     BottomNavigationBarItem(
            //       label: '저장',
            //       icon: IconButton(onPressed: (){
            //         String? userEmail = FirebaseAuth.instance.currentUser?.email;
            //         saveData.add(widget.urldata.toString());
            //         saveData.add(widget.o);
            //         saveData.add(widget.j);
            //         saveData.add(widget.s);
            //         FirebaseService.saveUserPrivacyData(userEmail!, saveData);
            //
            //       }, icon: Icon(Icons.save)),
            //     ),
            //     BottomNavigationBarItem(
            //         // icon: Icon(Icons.share),
            //       icon: IconButton(onPressed: () async {
            //         // 사용자 정의 템플릿 ID
            //         // String url = "https://developers.kakao.com";
            //         String firebasesUrl = widget.urldata.toString();
            //         int templateId = 83950;
            //
            //         print("firebasesUrl : $firebasesUrl");
            //
            //         // 카카오톡 실행 가능 여부 확인
            //         bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
            //         if (isKakaoTalkSharingAvailable) {
            //           print('카카오톡으로 공유 가능');
            //           try{
            //             Uri uri = await ShareClient.instance.shareScrap(url: firebasesUrl, templateId: templateId);
            //             await ShareClient.instance.launchKakaoTalk(uri);
            //             print('카카오톡 공유 완료');
            //             EasyLoading.showSuccess("공유 완료");
            //           }catch (e){
            //             print('카카오톡 공유 실패 $e');
            //           }
            //         } else {
            //           print('카카오톡 미설치: 웹 공유 기능 사용 권장');
            //         }
            //       }, icon: Icon(Icons.share)),
            //       label: "공유"
            //     )
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
