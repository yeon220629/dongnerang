import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:latlong2/latlong.dart';

import '../screens/freeComponent_viewpage.dart';

const CIRCLE_RADIUS = 50.0;
const KAKAO_NATIVE_APP_KEY = "fc7ff62469909fc60350045b7bc1178e"; //real
const KAKAO_NATIVE_APP_KEY2 = "7d87ad463053b80008264d1eb03665b1"; //real

const NO_CATEGORY_TEXT = "없음";
final MAP_INITIAL_CENTER_LOCATION = LatLng(37.5547125, 126.9707878);
const ZOOM_FOR_SHOW_MARKER_NAME = 13;

var POPUP_MENU_ITEMS = [
  PopupMenuItem(
      value: "edit",
      child: TextButton.icon(
        icon: const Icon(
          Icons.edit,
          color: Colors.black54,
        ),
        label: const Text(
          "편집",
          style: TextStyle(color: Colors.black54),
        ),
        onPressed: null,
      )),
  PopupMenuItem(
      value: "share",
      child: TextButton.icon(
        icon: const Icon(
          Icons.share,
          color: Colors.black54,
        ),
        label: const Text(
          "공유",
          style: TextStyle(color: Colors.black54),
        ),
        onPressed: null,
      )),
  PopupMenuItem(
      value: "delete",
      child: TextButton.icon(
        icon: const Icon(
          Icons.delete,
          color: Colors.black54,
        ),
        label: const Text(
          "삭제",
          style: TextStyle(color: Colors.black54),
        ),
        onPressed: null,
      ))
];

var POPUP_MENU_ITEMS_OTHERS = [
  PopupMenuItem(
      value: "share",
      child: TextButton.icon(
        icon: const Icon(
          Icons.share,
          color: Colors.black54,
        ),
        label: const Text(
          "공유",
          style: TextStyle(color: Colors.black54),
        ),
        onPressed: null,
      )),
];
// Controller
final CategoriesScroller categoriesScroller = CategoriesScroller();
late final ScrollController controller = ScrollController();
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
  )
);
late PullToRefreshController pullToRefreshController = PullToRefreshController();
final urlController = TextEditingController();

