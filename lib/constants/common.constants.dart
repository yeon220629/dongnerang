import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:latlong2/latlong.dart';

import '../screens/freeComponent_viewpage.dart';

const CIRCLE_RADIUS = 50.0;
const KAKAO_NATIVE_APP_KEY = "d7eaa723a1b0bbd17635330c5c561a5e"; //real
// const KAKAO_NATIVE_APP_KEY2 = "7d87ad463053b80008264d1eb03665b1"; //real

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
final ScrollController controllers = ScrollController();
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

final List CustomData = [
  "강남", "강동", "강북","강서","관악",
  "광진", "금천", "노원","도봉",
  "동대문","동작", "마포", "서대문","서초",
  "성동", "성북", "송파", "양천", "영등포",
  "용산", "은평", "종로", "중구", "중랑"
];


List? fnChecklocal(String local){
  if(local == '강남'){
    return ['강남'',''GANGNAM'];
  }else if(local == '강동'){
    return ['강동'',''GANGDONG'];
  }else if(local == '강북'){
    return ["강북",'GANGBUK'];
  }else if(local == '강서'){
    return ['강서', 'GANGSEO'];
  }else if(local == '관악'){
    return ['관악', 'GWANAK'];
  }else if(local == '광진'){
    return ['광진', 'GWANGZIN'];
  }else if(local == '금천'){
    return ['금천', 'GEUAMCHEOUN'];
  }else if(local == '노원'){
    return ['노원', 'NOWON_NOTICE'];
  }else if(local == '도봉'){
    return ['도봉', 'DOBONG'];
  }else if(local == '동대문'){
    return ['동대문', 'DONGDAEMUN'];
  }else if(local == '동작'){
    return ['동작', 'DONGJAK'];
  }else if(local == '마포'){
    return ['마포', 'MAPO'];
  }else if(local == '서대문'){
    return ['마포', 'MAPO'];
  }else if(local == '서초'){
    return ['서초', 'SEOCHO'];
  }else if(local == '성동'){
    return ['성동', 'SEONGDONG'];
  }else if(local == '성북'){
    return ['성북', 'SEONGBUK'];
  }else if(local == '송파'){
    return ['송파', 'SONGPA'];
  }else if(local == '양천'){
    return ['양천', 'YANGCHEON'];
  }else if(local == '영등포'){
    return ['영등포', 'YEONGDEUNGPO'];
  }else if(local == '용산'){
    return ['용산', 'YOUNGSAN_NOTICE'];
  }else if(local == '은평'){
    return ['은평', 'EUNPYENG'];
  }else if(local == '종로'){
    return ['종로', 'JONGRO'];
  }else if(local == '중구'){
    return ['중구', 'JUNGGU'];
  }else if(local == '중랑'){
    return ['중랑', 'JUNGNANG_NOTICE'];
  }
}