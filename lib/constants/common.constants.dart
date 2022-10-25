import 'package:dongnerang/services/firebase.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:latlong2/latlong.dart';

import '../screens/mainScreenBar.dart';
import 'colors.constants.dart';

const CIRCLE_RADIUS = 50.0;
const KAKAO_NATIVE_APP_KEY = "d7eaa723a1b0bbd17635330c5c561a5e"; //real

const NO_CATEGORY_TEXT = "없음";
final MAP_INITIAL_CENTER_LOCATION = LatLng(37.5547125, 126.9707878);
const ZOOM_FOR_SHOW_MARKER_NAME = 13;

class fnCommnAppbar extends StatelessWidget implements PreferredSizeWidget {
  const fnCommnAppbar({
    required this.appBar,
    required this.title,
    this.center = false,
    required this.email,
    required this.ListData,
    required this.keyName,
  });

  final AppBar appBar;
  final String title;
  final bool center;
  final String email;
  final List ListData;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: AppColors.black,
      ),
      backgroundColor: AppColors.white,
      centerTitle: true,
      elevation: 0.0,
      title: Text('$title', style: TextStyle(color: AppColors.black),),
      actions: [
        TextButton(onPressed: (){
          FirebaseService.savePrivacyProfile(email, ListData, keyName);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (BuildContext context) =>
                  mainScreen()), (route) => false);
        }, child: Text("완료", style: TextStyle(color: AppColors.black),))
      ],
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}

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

List CustomKeyword = [];
List mypageCustomKeyword = [];

final List CustomData = [
  "강남", "강동", "강북","강서","관악",
  "광진", "금천", "노원","도봉",
  "동대문","동작", "마포","서초",
  "성동", "성북", "송파", "양천", "영등포",
  "용산", "은평", "종로", "중구", "중랑"
];

final List mostPopularKeyword = [
  '인기', '키워드의', '종류는', '111', '222', '333', '444', '555'
  , '888', '777', '666'
];

List? fnChecklocal(String local){
  if(local == '강남'){
    return ['강남','GANGNAM'];
  }else if(local == '강동'){
    return ['강동','GANGDONG'];
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
    return ['노원', 'NOWON'];
  }else if(local == '도봉'){
    return ['도봉', 'DOBONG'];
  }else if(local == '동대문'){
    return ['동대문', 'DONGDAEMUN'];
  }else if(local == '동작'){
    return ['동작', 'DONGJAK'];
  }else if(local == '마포'){
    return ['마포', 'MAPO'];
  //  서대문 잠깐 보류
  }
  // else if(local == '서대문'){
  //   return ['마포', 'MAPO'];
  // }
  else if(local == '서초'){
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
    return ['용산', 'YOUNGSAN'];
  }else if(local == '은평'){
    return ['은평', 'EUNPYENG'];
  }else if(local == '종로'){
    return ['종로', 'JONGRO'];
  }else if(local == '중구'){
    return ['중구', 'JUNGGU'];
  }else if(local == '중랑'){
    return ['중랑', 'JUNGNANG'];
  }else if(local == '서울'){
    return ['서울', 'SEOUL'];
  }
}

// 반환에 사용할 클래스
class ReturnValue{
  String result;
  ReturnValue({required this.result});
}
class Arguments {
  late String arg;   // 전달에 사용할 데이터
  ReturnValue returnValue; //반환때 사용할 클래스
  Arguments(
    {this.arg: '', required this.returnValue}
  );
}

List dropdownYear = [
  "2022","2021","2020","2019","2018","2017","2016",
  "2015","2014","2013","2012","2011","2010","2009",
  "2008","2007","2006","2005","2004","2003","2002",
  "2001","2000","1999","1998","1997","1996","1995",
  "1994","1993","1992","1991","1990","1989","1988",
  "1987","1986","1985","1984","1983","1982","1981",
  "1980","1979","1978","1977","1976","1975","1979",
];
List dropdownMonth = ["1","2","3","4","5","6","7","8","9","10","11","12"];
List dropdownDay = ['1','2','3','4','5','6','7','8','9','10','11','12','13',
            '14','15','16','17','18','19','20','21','22','23','24','25','26',
            '27','28','29','30','31'
            ];
List centerCheck = ['전체', '문화재단', '구청'];
