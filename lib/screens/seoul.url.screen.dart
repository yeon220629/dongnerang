import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class seoulUrlLoadScreen extends StatefulWidget {
  final Uri s;
  const seoulUrlLoadScreen(this.s);
  @override
  State<seoulUrlLoadScreen> createState() => _seoulUrlLoadScreenState();
}

class _seoulUrlLoadScreenState extends State<seoulUrlLoadScreen> {
  bool toggle = false;
  InAppWebViewController? webViewController;
  late PullToRefreshController pullToRefreshController = PullToRefreshController();

  String url = '';
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
    super.dispose();

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
          print('더이상 뒤로갈페이지가 없습니다.');
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
    ),
    );
  }
}
