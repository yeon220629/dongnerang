

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'logger.service.dart';

class DynamicLink {
  Future<bool> setup() async {
    bool isExistDynamicLink = await _getInitialDynamicLink();
    print("setUp dynamic link : $isExistDynamicLink");

    _addListener();

    return isExistDynamicLink;
  }

  Future<bool> _getInitialDynamicLink() async {
    final PendingDynamicLinkData? deepLink = await FirebaseDynamicLinks.instance.getInitialLink();
    final shorLink = getShortLink('', '');
    print("shortLink : ${shorLink}");
    print("shortLink : ${shorLink..then((value) => print('value : $value'))}");
    print("deepLink : ${deepLink}");
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
    print("dynamic link addListener");
    FirebaseDynamicLinks.instance.onLink.listen((
        PendingDynamicLinkData dynamicLinkData,
        ) {
      print("dynamicLinkData : $dynamicLinkData");
      _redirectScreen(dynamicLinkData);
    }).onError((error) {
      logger.e(error);
    });
  }

  void _redirectScreen(PendingDynamicLinkData dynamicLinkData) {
    if (dynamicLinkData.link.queryParameters.containsKey('id')) {
      String link = dynamicLinkData.link.path.split('/').last;
      String id = dynamicLinkData.link.queryParameters['id']!;

      // switch (link) {
      //   case exhibition:
      //     Get.offAll(
      //           () => ExhibitionDetailScreen(
      //         mainBottomTabIndex: MainBottomTabScreenType.exhibitionMap.index,
      //       ),
      //       arguments: {
      //         "exhibitionId": id,
      //       },
      //     );
      //     break;
      //   case artist:
      //     Get.offAll(
      //           () => ArtistScreen(),
      //       arguments: {
      //         "artistId": id,
      //       },
      //     );
      //     break;
      //   case exhibitor:
      //     Get.offAll(
      //           () => ExhibitorScreen(),
      //       arguments: {
      //         "exhibitorId": id,
      //       },
      //     );
      //     break;
      // }
    }
  }

  Future<String> getShortLink(String screenName, String id) async {
    final dynamicLinkPrefix = 'https://dongnerang.page.link';
    final dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: dynamicLinkPrefix,
      link: Uri.parse('$dynamicLinkPrefix/$screenName?id=$id'),
      androidParameters: const AndroidParameters(
        packageName: 'com.dongnerang.com.dongnerang"',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.dongnerang.com.dongnerang',
        minimumVersion: '0',
      ),
    );
    final dynamicLink =
    await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);

    return dynamicLink.shortUrl.toString();
  }
}