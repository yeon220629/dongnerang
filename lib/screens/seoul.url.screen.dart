import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../constants/common.constants.dart';

class seoulUrlLoadScreen extends StatefulWidget {
  final Uri s;
  const seoulUrlLoadScreen(this.s);
  @override
  State<seoulUrlLoadScreen> createState() => _seoulUrlLoadScreenState();
}

class _seoulUrlLoadScreenState extends State<seoulUrlLoadScreen> {
  static const platform = MethodChannel('fcm_default_channel');

  @override
  void initState() {
    super.initState();
    // pullToRefreshController = PullToRefreshController(
    //     onRefresh: () async {
    //       webViewController?.reload();
    //     }
    // );
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  void dispose() {
    super.dispose();

  }

  Future getAppUrl(String url) async {
    print(url);
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
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      child : Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                  children: [
                    WebView(
                      navigationDelegate: (request) async{
                        // 2 채널이용
                        if(!request.url.startsWith('http') && !request.url.startsWith('https')) {
                          if(Platform.isAndroid) {
                            getAppUrl(request.url.toString());
                            return NavigationDecision.prevent;
                          }else if(Platform.isIOS){
                            if (await canLaunchUrl(Uri.parse(request.url))) {
                              await launchUrl(Uri.parse(request.url),);
                              return NavigationDecision.prevent;
                            }
                          }
                        }
                        return NavigationDecision.navigate;
                      },
                      initialUrl: widget.s.toString(),
                    )
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }
}
//   bool toggle = false;
//   InAppWebViewController? webViewController;
//   late PullToRefreshController pullToRefreshController = PullToRefreshController();
//
//   String url = '';
//   double progress = 0;
//   final urlController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     pullToRefreshController = PullToRefreshController(
//         onRefresh: () async {
//           webViewController?.reload();
//         }
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//     onWillPop: (){
//       var future = webViewController?.canGoBack();
//       future?.then((canGoBack) {
//         if (canGoBack) {
//           webViewController?.goBack();
//         } else {
//           print('더 이상 뒤로 갈 페이지가 없습니다.');
//           Navigator.pop(context);
//           //뒤로가기 시 처리코드
//         }
//       });
//       return Future.value(false);
//     },
//     child : Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: <Widget>[
//             Expanded(
//               child: Stack(
//                 children: [
//                   InAppWebView(
//                     initialUrlRequest: URLRequest(url: WebUri.uri(widget.s)),
//                     pullToRefreshController: pullToRefreshController,
//                     onWebViewCreated: (controller) {
//                       webViewController = controller;
//                     },
//                     onLoadStart: (controller, url) {
//                       setState(() {
//                         this.url = url.toString();
//                         urlController.text = this.url;
//                       });
//                     },
//                     shouldOverrideUrlLoading: (controller, navigationAction) async {
//                       var uri = navigationAction.request.url!;
//
//                       if (![ "http", "https", "file", "chrome",
//                         "data", "javascript", "about"].contains(uri.scheme)) {
//                         return NavigationActionPolicy.CANCEL;
//                       }
//
//                       return NavigationActionPolicy.ALLOW;
//                     },
//                     onProgressChanged: (controller, progress) {
//                       if (progress == 100) {
//                         pullToRefreshController.endRefreshing();
//                       }
//                       setState(() {
//                         this.progress = progress / 100;
//                         urlController.text = this.url;
//                       });
//                     },
//                     onUpdateVisitedHistory: (controller, url, androidIsReload) {
//                       setState(() {
//                         this.url = url.toString();
//                         urlController.text = this.url;
//                       });
//                     },
//                     onConsoleMessage: (controller, consoleMessage) {
//                       print(consoleMessage);
//                     },
//                   ),
//                   progress < 1.0
//                       ? LinearProgressIndicator(value: progress)
//                       : Container(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//     );
//   }
// }
