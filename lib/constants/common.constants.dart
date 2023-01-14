import 'dart:collection';

import 'package:dongnerang/models/space.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';



const CIRCLE_RADIUS = 50.0;
const KAKAO_NATIVE_APP_KEY = "d7eaa723a1b0bbd17635330c5c561a5e"; //real

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

// 개인설정 공통값
List CustomKeyword = [];
List Privatekeyword = [];
List mypageCustomKeyword = [];
List mypageCustomlocal = [];
List PrivateLocalData = [];

String? profileImage = '';
String? userName = '';
late Future<List> mypageUserSaveData;
String? userUpdageName;
List userUpdateData = [];

final List CustomData = [
  "강남", "강동", "강북","강서","관악",
  "광진", "구로", "금천", "노원","도봉","동대문","동작","마포",
  "서대문","서초","성동","성북","송파",
  "양천","영등포","용산","은평","종로","중구","중랑",

];

final List mostPopularKeyword = [
  '인기', '키워드의', '종류는', '111', '222', '333', '444', '555'
  , '888', '777', '666'
];

String getToday() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  String strToday = formatter.format(now);
  return strToday;
}

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
  }else if(local == '구로'){  //구로 없어서 추가함
    return ['구로', 'GURO'];
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
  }else if(local == '서대문'){
    return ['서대문', 'SEODAEMUN'];
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
    return ['용산', 'YONGSAN'];
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
  "1978","1977","1976","1975","1974","1973","1972",
  "1971","1970","1969","1968","1967","1966","19665",
  "1964","1963","1962","1961","1960","1959","1958",
  "1957","1956","1955","1954","1953","1952","1951",
  "1950","1949","1955","1948","1947","1946","1945",
  "1944","1943","1942","1941","1940"
];
List dropdownMonth = ["1","2","3","4","5","6","7","8","9","10","11","12"];
List dropdownDay = ['1','2','3','4','5','6','7','8','9','10','11','12','13',
  '14','15','16','17','18','19','20','21','22','23','24','25','26',
  '27','28','29','30','31'
];
// List centerCheck = ['전체', '문화재단', '구청'];
List centerCheck = ['전체', '구청', '문화재단'];
List SeoulCheck = ['전체',
  // '서울관광재단','서울산업진흥원','서울주거포털','NPO지원센터', '청년몽땅정보통','아트누리','서울시청'];
  '서울관광재단','서울산업진흥원','서울주거포털','NPO지원센터', '청년몽땅정보통','서울시청','서울시문화원','서울문화재단'];

int fnSeoulCnterCheck(centerValue){
  if(centerValue.contains("구청")){
    return 1;
  }else if(centerValue.contains("문화재단")){
    return 0;
  }else if(centerValue.contains("청년몽땅정보통")){
    return 2;
  }else if(centerValue.contains("서울산업진흥원")){
    return 3;
  }else if(centerValue.contains("서울주거포털")){
    return 4;
  }else if(centerValue.contains("서울NPO지원센터")){
    return 5;
  }else if(centerValue.contains("서울관광재단")){
    return 6;
  }
  return 0;
}

int fnCenterCheck(centerValue){
  if(centerValue.contains('문화원')){
    return 1;
  }else if(centerValue.contains('공단')){
    return 2;
  }else if(centerValue.contains('구청')){
    return 3;
  } return 0;
}

fnOnlineUrl(value){

  print("dropDown Value : $value");

  if(value == '중구'){
    return 'http://www.junggu.seoul.kr/content.do?cmsid=14195';
  }else if(value == '중랑'){
    return 'https://www.jungnang.go.kr/portal/app/integrateApp/integrateList.do?programId=integrateApp&menuNo=200108';
  }else if(value == '종로'){
    return 'https://www.jongno.go.kr/portal/app/integrateApp/list.do?division=01&menuId=388366&menuNo=388366';
  }else if(value == '은평'){
    return 'https://www.ep.go.kr/www/selectUserCourseList.do?key=987&searchEdcKey=9';
  }else if(value == '용산'){
    return 'https://yedu.yongsan.go.kr/site/edtotal/lesson/userlist.do?sitecdv=S0000500&menucdv=02020000&decorator=user27EdTotal';
  }else if(value == '영등포'){
    return 'https://www.ydp.go.kr/reserve/index.do';
  }else if(value == '양천'){
    return 'https://www.yangcheon.go.kr/reservation/reservation/main.do';
  }else if(value == '송파'){
    return 'https://www.songpa.go.kr/www/userRecptMain.do?key=2173&';
  }else if(value == '성북'){
    return 'https://www.sb.go.kr/PageLink.do';
  }else if(value == '성동'){
    return 'https://www.sd.go.kr/reserve/index.do?';
  }else if(value == '서초'){
    return 'https://www.seocho.go.kr/site/seocho/ex/reservationMain/Sub_Main.do';
  }else if(value == '서대문'){
    return 'https://www.sdm.go.kr/educate/propose/information/app.do';
  }else if(value == '마포'){
    return 'https://www.mapo.go.kr/site/mll/edu/lecture_list';
  }else if(value == '동작'){
    return 'https://www.dongjak.go.kr/reservation/progrm/master/reservation/list.do?menuNo=400031';
  }else if(value == '동대문'){
    return 'https://www.ddm.go.kr/www/selectUserOnlineReceptionList.do?key=96';
  }else if(value == '도봉'){
    return 'https://www.dobong.go.kr/bbs.asp?code=10004125';
  }else if(value == '노원'){
    return 'https://www.nowon.kr/www/mlrd/onlineRcept/BD_selectOnlineRceptList.do#none';
  }else if(value == '금천'){
    return 'https://www.geumcheon.go.kr/reserve/webEdcLctreList.do?key=112&rep=1';
  }else if(value == '구로'){
    return 'https://www.guro.go.kr/yeyak/index.do';
  }else if(value == '광진'){
    return 'https://www.gwangjin.go.kr/portal/pgm/online/list.do?menuNo=200061';
  }else if(value == '관악'){
    return 'https://www.gwanak.go.kr/site/gwanak/ex/reservation/re00401.do?riType=A';
  }else if(value == '강서'){
    return 'https://www.gangseo.seoul.kr/reserve/re040101';
  }else if(value == '강북'){
    return 'https://www.gangbuk.go.kr/www/selectTnOnlineRceptWebList.do?key=12724';
  }else if(value == '강동'){
    return 'https://www.gangdong.go.kr/web/newreserve/reserve/list?basicType=reserveType_01';
  }else if(value == '강남'){
    return 'https://www.gangnam.go.kr/edu/lecture/edu/list.do?mid=ID04_02070201';
  }
}

// 네이버 지도 로컬 DB에 저장될 데이터
Queue<Space> SpacesQueue = ListQueue<Space>();