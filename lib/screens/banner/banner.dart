import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class bannerWidget extends StatefulWidget {
  final title; final link;
  bannerWidget(this.title, this.link);

  @override
  State<bannerWidget> createState() => _bannerWidgetState();
}

class _bannerWidgetState extends State<bannerWidget> {

  bool toggle = false;

  InAppWebViewController? webViewController;

  late PullToRefreshController pullToRefreshController = PullToRefreshController();
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
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
    if (Platform.isAndroid) {
      return WillPopScope(
        onWillPop: () {
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
        child: platformCheck(),
      );
    }
    return platformCheck();
    // return GestureDetector(
    //   child: platformCheck(),
    //     onHorizontalDragUpdate: (details) {
    //       int sensitivity = 8;
    //       if (details.delta.dx > sensitivity) {
    //         // Right Swipe
    //       } else if(details.delta.dx < -sensitivity){
    //         //Left Swipe
    //       }
    //   },
    // );
  }

  Widget platformCheck() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            //페이지 리로드
            onPressed: () {
              Navigator.pop(context);
            }
        ),
        centerTitle: true,
        title: Text(widget.title, style: TextStyle(color: Colors.black)),
        actions: [
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                        url: WebUri.uri(Uri.parse(widget.link))),
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
                    shouldOverrideUrlLoading: (controller,
                        navigationAction) async {
                      var uri = navigationAction.request.url!;

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
          ],
        ),
      ),
    );
  }
}