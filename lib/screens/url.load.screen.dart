import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/colors.constants.dart';


class urlLoadScreen extends StatefulWidget {
  final Uri urldata;
  const urlLoadScreen(this.urldata);

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

  return Scaffold(
    appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text("Web Page", style: TextStyle(
          fontSize: 14, color: Colors.black
        ))
    ),
    body: SafeArea(
        child: Column(
          children: <Widget>[
            // TextField(
            //   decoration: InputDecoration(
            //     prefixIcon: Icon(Icons.search)
            //   ),
            //   controller: urlController,
            //   keyboardType: TextInputType.text,
            //   onSubmitted: (value){
            //     var url = Uri.parse(value);
            //     if(url.scheme.isEmpty){
            //       url = widget.urldata;
            //     }
            //   },
            // ),
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
            BottomNavigationBar(
              showUnselectedLabels: true,
              showSelectedLabels: true,
              selectedLabelStyle: const TextStyle(color: Colors.red),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.save),
                  label: "저장",
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.share),
                    label: "공유"
                )
              ],
            )
            // ButtonBar(
            //   alignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     ElevatedButton(
            //       child: Icon(Icons.arrow_back),
            //       onPressed: () {
            //         webViewController?.goBack();
            //       },
            //     ),
            //     ElevatedButton(
            //       child: Icon(Icons.arrow_forward),
            //       onPressed: () {
            //         webViewController?.goForward();
            //       },
            //     ),
            //     ElevatedButton(
            //       child: Icon(Icons.refresh),
            //       onPressed: () {
            //         webViewController?.reload();
            //       },
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
