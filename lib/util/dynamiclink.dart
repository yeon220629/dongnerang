

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../screens/url.load.screen.dart';
import 'logger.service.dart';

class DynamicLink {
  Future<bool> setup() async {
    bool isExistDynamicLink = await _getInitialDynamicLink();
    _addListener();
    return isExistDynamicLink;
  }

  Future<bool> _getInitialDynamicLink() async {
    final PendingDynamicLinkData? deepLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (deepLink != null) {
      PendingDynamicLinkData? dynamicLinkData = await FirebaseDynamicLinks
          .instance
          .getDynamicLink(deepLink.link);

      if (dynamicLinkData != null) {
        _redirectScreen(dynamicLinkData);
        return true;
      }
    }
    return false;
  }

  void _addListener() {
    FirebaseDynamicLinks.instance.onLink.listen((
        PendingDynamicLinkData dynamicLinkData,
        ) {
      _redirectScreen(dynamicLinkData);
    }).onError((error) {
      logger.e(error);
    });
  }

  void _redirectScreen(PendingDynamicLinkData dynamicLinkData) async {
    Map<String, String> dynamicModel = new Map();
    var url = '';
    dynamicLinkData.link.queryParameters.forEach((key, values) {
      // print("$key : $values");
      dynamicModel.addAll({key : values});
      if(key != 'title' && key != 'centername' && key != 'timedate' && key != 'number'){
        url += '&$key=$values';
      }
    });
    // DateFormat dateFormat = DateFormat("yyyy-MM-dd").parse();
    DateTime dateTime = new DateFormat("yyyy-MM-dd").parse(dynamicModel['timedate']!);
    url = url.replaceAll('&url=', '');
    // 페이지 다른 변수만 세팅 하면 끝날 듯. url, post["title"], post['center_name '], dateTime, 0
    Get.to(urlLoadScreen(Uri.parse(url), dynamicModel['title'],
        dynamicModel['centername'], dateTime, int.parse(dynamicModel['number']!)));

  }
}