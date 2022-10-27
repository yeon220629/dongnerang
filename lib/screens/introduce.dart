import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../constants/colors.constants.dart';


class introduceWidget extends StatefulWidget {

  @override
  State<introduceWidget> createState() => _introduceWidgetState();
}

class _introduceWidgetState extends State<introduceWidget> {

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
    List saveData = [];
    return Scaffold(
      appBar: AppBar(
        // title: Text('동네랑 소개'),
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          // color: AppColors.green,
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            //페이지 리로드
            onPressed: (){
              Navigator.pop(context);
            }
        ),
        centerTitle: true,
        title: Text('동네랑 소개', style: TextStyle(color: Colors.black)) ,
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
                     initialUrlRequest: URLRequest(url: Uri.parse('https://moored-adasaurus-5d6.notion.site/bbdd58432e9d4f95a0863e691bffe61d')),
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
    );
  }
}
