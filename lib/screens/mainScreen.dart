import 'dart:ui' as ui;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/seoul.url.screen.dart';
import 'package:dongnerang/screens/updatedialog.dart';
import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version/new_version.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/colors.constants.dart';
import '../constants/common.constants.dart';
import '../constants/common.constants2.dart';
import 'package:dongnerang/screens/search.screen.dart';
import '../services/firebase.service.dart';
import '../util/dynamiclink.dart';
import '../util/logger.service.dart';
import '../widgets/app_button.widget.dart';
import 'banner/banner.dart';
import 'notice.main.screen.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';


class freeComponent_viewpage extends StatefulWidget {
  const freeComponent_viewpage({Key? key}) : super(key: key);

  @override
  State<freeComponent_viewpage> createState() => freeComponentviewpageState();
}

class freeComponentviewpageState extends State<freeComponent_viewpage> {

  // //애드몹 테스트 ID
  // final String iOSTestId = 'ca-app-pub-3940256099942544/2934735716';
  // final String androidTestId = 'ca-app-pub-3940256099942544/6300978111';
  //
  // //애드몹 찐 ID
  // final String iOSRealId = 'ca-app-pub-3415104781631988/3367223383';
  // final String androidRealId = 'ca-app-pub-3415104781631988/9379594822';

  // BannerAd? banner;
  CarouselController buttonCarouselController = CarouselController();
  var _currentPage;
  var listLength;   // 리스트 뷰 불러올시 로딩 중 메시지 띄우기 위한 변수
  bool closeTapContainer = false;
  final List<bool> _selectedCenter = <bool>[true, false];
  late List<dynamic> bannerData = [];
  var product = [];
  List<String> LIST_MENU = [];
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  List listOrder = [];
  String _authStatus = 'unknown';
  String? defaultCenter = '전체';
  String? SeouldefaultCenter = "전체";
  String url = "";
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String dropdownValue = '';
  String? centerName = '';
  String? centerLabel = '';
  String? seoulCenterLabel = '';
  int cuindex = 0;
  int colorindex = 0;
  double topContainer = 0;
  int dotindex =0;
  Map<String, dynamic> urls = {};

  // ListView paging 관련 변수
  final int _pageSize = 20;
  final PagingController<int, dynamic> _pagingController = PagingController(firstPageKey: 0);


  // 자치구 관련 url들 가져오기
  Future<void> checkUrls(String gu) async {
    urls = await FirebaseService.getUrlsByGu(gu);
  }

  Future<void> getUserLocalData() async {
    FirebaseService.getUserLocalData(userEmail!, 'local').then((value){
      int ListData = value.length;
      for(int i = 0; i < ListData; i++){
        LIST_MENU.add(value[i]);
      }

      String? checklocalItem = fnChecklocal(LIST_MENU[0])?.first;
      getPostsData("${checklocalItem}_전체");

      setState(() {
        dropdownValue = LIST_MENU[0];
        checkUrls(dropdownValue);
      });
    });
  }

  Future<void> getPostsData(value) async {
    // 리스트를 다시 부를때 스크롤 위치를 맨위로
    var controller = PrimaryScrollController.of(context);
    controller?.jumpTo(0);

    if(value.toString().contains("_")){
      centerName = value.toString().split("_")[1];
      value = fnChecklocal(value.toString().split("_")[0])?.last;
    }else{
      value = 'SEOUL';
      centerName = seoulCenterLabel;
    }

    listOrder = [];
    listItems = [];
    List<dynamic> valueData = [];
    List<dynamic> responseList = [];

    DocumentReference<Map<String, dynamic>> docref = FirebaseFirestore.instance.collection("crawlingData").doc(value);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await docref.get();
    late  Map<String, dynamic>? valueDoc = documentSnapshot.data();

    valueDoc?.forEach((key, value) {
      valueData.add(value);
    });

    valueData.sort((a,b) {
      var adate = a['registrationdate']; //before -> var adate = a.expiry;
      var bdate = b['registrationdate']; //before -> var bdate = b.expiry;
      return bdate.compareTo(adate); //to get the order other way just switch `adate & bdate`
    });

    responseList = valueData;
    for ( var post in responseList){
      if(fnCenterCheck(post['center_name ']) == 0){
        centerCheck[2] = '문화재단';
      }else if(fnCenterCheck(post['center_name ']) == 1){
        centerCheck[2] = '문화원';
      }else if(fnCenterCheck(post['center_name ']) == 2){
        centerCheck[2] = '공단';
      }
      colorindex = fnSeoulCnterCheck(post['center_name ']);

      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateTime dateTime = post["registrationdate"].toDate();
      if(centerLabel == "전체"){ centerLabel = null;}
      if(centerName == centerLabel){
        if(post["center_name "].toString().contains(centerLabel!)){
          if(post['center_name '] == '중구구청'){ post['center_name '] = '중구청'; }
          listItems.add( GestureDetector(
              onTap: () async{
                final Uri url = Uri.parse('${post["link"]}');
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
                    url, post["title"], post['center_name '], dateTime, 0
                )));
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), //모서리를 둥글게
                      border: Border.all(color: Colors.black12, width: 1)), //테두리
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        post["title"].length >= 28
                          ? Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            '${post["title"]}',
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            maxLines: 2,
                          ),
                        )
                        :Padding(
                          padding: const EdgeInsets.only(left: 5,top: 10,right: 5,bottom: 0),
                          child: Text(
                            '${post["title"]}',
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: colorindex == 1
                                            ? Color(0xff5496D2)
                                            : colorindex == 0
                                            ? Color(0xff3CC181)
                                            : colorindex == 2
                                            ? AppColors.darkgreen
                                            : colorindex == 3
                                            ? AppColors.primary
                                            : colorindex == 4
                                            ? AppColors.orange
                                            : colorindex == 5
                                            ? AppColors.red
                                            : Color(0xffEE6D01),
                                      ),
                                      padding: EdgeInsets.all(2),
                                      child: Text(
                                        ' ${post['center_name ']} ',
                                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                        textDirection: ui.TextDirection.ltr,
                                      )
                                  ),
                                ),
                                SizedBox(width: 7),
                                Text(
                                  // '시작일 | ${post['registrationdate'].trim()}',
                                  '등록일 | ${dateFormat.format(dateTime)}',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  textDirection: ui.TextDirection.ltr,
                                ),
                              ],
                            )
                        )
                      ],
                    ),
                  )
              ))
          );
        }
      }else{
        if(post['center_name '] == '중구구청'){ post['center_name '] = '중구청'; }
        listItems.add( GestureDetector(
            onTap: () async{
              final Uri url = Uri.parse('${post["link"]}');
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
                // url, post["title"], post['center_name '], post['registrationdate'], 0
                  url, post["title"], post['center_name '], dateTime, 0
              )));
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 90,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), //모서리를 둥글게
                    border: Border.all(color: Colors.black12, width: 1)), //테두리
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      post["title"].length >= 28
                          ? Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          '${post["title"]}',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.justify,
                          maxLines: 2,
                        ),
                      )
                          :Padding(
                        padding: const EdgeInsets.only(left: 5,top: 10,right: 5,bottom: 0),
                        child: Text(
                          '${post["title"]}',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.justify,
                          maxLines: 1,
                        ),
                      ),
                      Expanded(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: colorindex == 1
                                          ? Color(0xff5496D2)
                                          : colorindex == 0
                                          ? Color(0xff3CC181)
                                          : colorindex == 2
                                          ? AppColors.darkgreen
                                          : colorindex == 3
                                          ? AppColors.primary
                                          : colorindex == 4
                                          ? AppColors.orange
                                          : colorindex == 5
                                          ? AppColors.red
                                          : Color(0xffEE6D01),
                                    ),
                                    child: Text(
                                      ' ${post['center_name ']} ',
                                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                      textDirection: ui.TextDirection.ltr,
                                    )
                                ),
                              ),
                              SizedBox(width: 7),
                              Text(
                                // '시작일 | ${post['registrationdate'].trim()}',
                                '등록일 | ${dateFormat.format(dateTime)}',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                                textDirection: ui.TextDirection.ltr,
                              ),
                            ],
                          )
                      )
                    ],
                  ),
                )
            ))
        );
      }
    }
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
    final FirebaseMessaging _messaging = FirebaseMessaging.instance;
    _getToken(_messaging);
    super.initState();

    final status = Permission.notification.request();
    if((status == PermissionStatus.permanentlyDenied)){
      Permission.accessNotificationPolicy.request();
    }

    // if (await Permission.notification.request().isGranted) {
    // // Either the permission was already granted before or the user just granted it.
    // }
    // Map<Permission, PermissionStatus> statuses = await [
    // Permission.notification,
    // ].request();
    // print("Permission.notification.status : ${Permission.notification.status}");
    // _permission();
    // PermissionScreen().requestCameraPermission(context);

    FirebaseService.findBanner().then((value){
      value.sort((a,b){
        var adata = a['number'];
        var bdata = b['number'];
        return adata.compareTo(bdata);
      });

      for(int i =0; i < value.length; i++){
        product.add(
            CachedNetworkImage(
              imageUrl: value[i]['image'], fit: BoxFit.cover,
            )
        );
        bannerData.add(value[i]);
      }
    });
    //애드몹
    // banner = BannerAd(
    //   size: AdSize.fullBanner,
    //   // adUnitId: Platform.isIOS ? iOSRealId : androidRealId,
    //   adUnitId: Platform.isIOS ? iOSTestId : androidTestId,
    //   listener: BannerAdListener(),
    //   request: AdRequest(),
    // )..load();
    // if(userEmail == null){
    //   userEmail = UserService.to.currentUser.value?.email;
    // }

    getUserLocalData();
    FirebaseService.getUserLocalData(userEmail!, 'local').then((value){
      int ListData = value.length;
      PrivateLocalData = [];
      for(int i = 0; i < ListData; i++){
        PrivateLocalData.add(value[i]);
      }
    });
    FirebaseService.getUserKeyExist(userEmail!, 'alramlocal').then((value) {
      if(value == false){
        FirebaseService.savePrivacyProfile(userEmail!,PrivateLocalData,'alramlocal');
      }
    });

    commonConstant2.mypageUserSaveData = FirebaseService.getUserPrivacyProfile(userEmail!);
    commonConstant2.mypageUserSaveData.then((value){
      setState(() {
        commonConstant2.mypageInformPhotoSetting = value[0]['profileImage'];
        commonConstant2.mypageInformNickSetting = value[0]['name'];
        commonConstant2.mypageInformGender = value[0]['gender'];
        commonConstant2.mypageInformAgeValue = value[0]['age'];
      });
    });
    controllers.addListener(() {
      double value = controllers.offset/119;
      setState(() {
        topContainer = value;
        closeTapContainer = controllers.offset > 50;
      });
    });

    final newVersion = NewVersion(
      androidId: 'com.dongnerang.com.dongnerang',
      iOSId: 'com.dongnerang.com.dongnerang',
    );
    checkNewVersion(newVersion);
    commonConstant2().fnResetValue();
    // deeplink
    // DynamicLink().setup();
    FirebaseDynamicLinks.instance.onLink.listen((
        PendingDynamicLinkData dynamicLinkData,
        ) {
      Map<String, String> dynamicModel = new Map();
      var url = '';
      dynamicLinkData.link.queryParameters.forEach((key, values) {
        print("$key : $values");
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
    }).onError((error) {
      logger.e(error);
    });
  }

  // 리스트 페이징 함수
  Future<void> _fetchPage(int pageKey) async {
    try {
      Future.delayed(const Duration(milliseconds: 500), () {
        int lastIdx = itemsData.length;

        // 카테고리 필터, 거리순, _pageSize개수 만큼 불러오기
        List<dynamic> newItems = itemsData.sublist(pageKey, (pageKey + _pageSize < lastIdx ? pageKey + _pageSize : lastIdx));

        bool isLastPage = newItems.length < _pageSize;

        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + newItems.length;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      });
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void checkNewVersion(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    // print("status appStoreLink : ${status?.appStoreLink}");
    // print("status LocalVersion : ${status?.localVersion}");
    // print("status storeVersion : ${status?.storeVersion}");
    // print("status releaseNotes : ${status?.releaseNotes}");
    if(status != null) {
      // 업데이트 테스트
      // if(!status.canUpdate) {
      if(status.canUpdate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return UpdateDialog(
              allowDismissal: true,
              description: status.releaseNotes!,
              version: status.storeVersion,
              appLink: status.appStoreLink,
            );
          },
        );
      }
    }
  }

  Future<void> _getToken(_messaging) async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    // await Firebase.initializeApp();
    _messaging.getToken().then((token) async {
      debugPrint('token~: [$token]');
      if(userEmail!= null){
        print("userEmail not Null");
        await FirebaseFirestore.instance.collection("users").doc(userEmail).update(({
          'usertoken': token,
        }));
      }
    });
  }

  Future <void> initPlugin() async{
    try{
      final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
      setState(() => _authStatus = '$status');
      if(status == TrackingStatus.notDetermined) {
        final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
        setState(() => _authStatus = '$status');
      }
    }on PlatformException{
      setState(() => _authStatus = 'PlatformException was thrown');
    }
    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("uuid : $uuid");
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    listLength = itemsData.length;

    List<Widget> CategoryCenter = <Widget>[
      Text('동네소식'),
      Text('서울소식'),
    ];

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            title: DropdownButton2(
              alignment: Alignment.center,
              focusColor: AppColors.primary,
              icon: const Icon(Icons.keyboard_arrow_down),
              isExpanded: false,
              isDense: false,
              underline: Container(),
              value: dropdownValue,
              items: LIST_MENU.map<DropdownMenuItem<String>>((String item) {
                if(item.contains('구')){
                  if(item == '중구'){
                    item = item;
                  }else{
                    if(item == '구로'){
                      item = item;
                    }else{
                      item = '${item}구';
                    }
                  }
                }
                return DropdownMenuItem<String>(
                  value: item,
                  child: item == '중구' || item == '구로구'
                    ? dropdownValue == item
                      ? Text("${item}" , style: TextStyle(fontWeight: FontWeight.bold))
                      : Text("${item}", style: TextStyle(fontWeight: FontWeight.normal))
                    : dropdownValue == item
                      ? Text("${item}구" , style: TextStyle(fontWeight: FontWeight.bold))
                      : Text("${item}구", style: TextStyle(fontWeight: FontWeight.normal))
                );
              }).toList(),
              onChanged: (dynamic value){
                var _msg = '';
                listItems = [];
                value == '중구'
                    ? _msg = '현재 동네가 "$value"로 변경되었습니다.'
                    : _msg = '현재 동네가 "$value구"로 변경되었습니다.';
                final snackBar = SnackBar(content: Text(_msg));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                List? item = fnChecklocal(value);
                if(value == item?.first){
                  getPostsData("${item?.first}_전체");
                  // getPostsData(item?.last);
                }
                setState(() {
                  for (int i = 0; i < _selectedCenter.length; i++) {
                    _selectedCenter[i] = i == 0;
                  }
                  cuindex = 0;
                  dropdownValue = value;
                  defaultCenter = "전체";
                  checkUrls(dropdownValue);
                });
              },
              barrierColor: Colors.black.withOpacity(0.5),
              iconOnClick: Icon(Icons.keyboard_arrow_up),
              offset: const Offset(0, -3),
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: (){
                    // final Uri url = Uri.parse('${fnOnlineUrl(dropdownValue)}');
                    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => onlineUrl( url )));
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          contentPadding: EdgeInsets.only(top: 0.0),
                          content: SizedBox(
                            width: size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                InkWell(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "동네신청",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  child: AppTextButton(
                                      text: "구청신청",
                                      onPressed: () async {
                                        final Uri url = Uri.parse(urls['reserveUrl']);
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen(url)));
                                      }),
                                  decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: urls['performUrl'].length,
                                  itemBuilder: (context, index) {
                                    String urlName = "공연・전시";

                                    if (urls['performUrl'].length > 1) {
                                      urlName += " (${urls['performUrl'][index]['name']})";
                                    }

                                    return Container(
                                      decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                      child: AppTextButton(
                                        text: urlName,
                                        onPressed: () async {
                                          final Uri url = Uri.parse(urls['performUrl'][index]['url']);
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen(url)));
                                        },
                                      ),
                                    );
                                  },
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: urls['cultureUrl'].length,
                                  itemBuilder: (context, index) {
                                    String urlName = "문화강좌";

                                    if (urls['cultureUrl'].length > 1) {
                                      urlName += " (${urls['cultureUrl'][index]['name']})";
                                    }

                                    return Container(
                                      decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                      child: AppTextButton(
                                        text: urlName,
                                        onPressed: () async {
                                          final Uri url = Uri.parse(urls['cultureUrl'][index]['url']);
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen(url)));
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(5),
                      //   border: Border.all(
                      //       width: 1.5,
                      //       color: AppColors.primary,
                      //   ),
                      //   color: AppColors.white
                      // ),
                      padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Text(
                        '동네신청 📝',
                        style: const TextStyle(fontSize: 15, color: Colors.black),
                        textDirection: ui.TextDirection.ltr,
                      )
                  ),
              ),
              IconButton(onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => searchScreen(title: '',))
                );
              },
                  icon: const Icon(Icons.search),color: AppColors.black),
              IconButton(onPressed: (){
                Get.to(() => noticemainpage());
              }, icon: const Icon(Icons.notifications_none_outlined),color: AppColors.black),
            ],
          ),
          body: SizedBox(
            child: Column(
              children: <Widget>[
                Container(
                  child : GestureDetector(
                    onTap: () {
                      for(int i = 0; i < bannerData.length; i++){
                        // print("$i : ${bannerData[i]['number']} ${bannerData[i]['title']}");
                        // print("_currentPage : $_currentPage");
                        if(_currentPage == i){
                          Navigator.push( context,
                              MaterialPageRoute(
                                  builder: (context) => bannerWidget(bannerData[i]['title'], bannerData[i]['link']))
                          );
                        }
                      }
                    },
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            CarouselSlider.builder(
                              itemCount: product.length,
                              itemBuilder: (ctx, index, realIdx) {
                                dotindex = index;
                                return Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Container(
                                            height: size.height / 9.5,
                                            width: size.width,
                                            child: product.isEmpty
                                                ? Lottie.asset( 'assets/lottie/searchdata.json', )
                                                : product[index]
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                              options: CarouselOptions(
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                height: size.height / 9.5,
                                autoPlay: true,
                                enlargeCenterPage: true,
                                viewportFraction: 1.0,
                                aspectRatio: 16 / 9,
                                initialPage: 0,
                              ),
                            ),
                            DotsIndicator(
                              position: dotindex + 0.1,
                              decorator: DotsDecorator(
                                // spacing: const EdgeInsets.all(5.0)
                                  color: AppColors.grey,
                                  activeColor: AppColors.white
                              ),
                              dotsCount: product.length == 0
                                  ? 2
                                  : product.length
                            )
                          ],
                        )
                      ],
                    )
                  ),
                ),
                SizedBox(
                  width: size.width / 1.05,
                  // padding: EdgeInsetsDirectional.all(2),
                  child: Row(
                    // mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ToggleButtons(
                        direction: Axis.horizontal,
                        isSelected: _selectedCenter,
                        onPressed: (int index) {
                          _pagingController.refresh();
                          setState(() {
                            for (int i = 0; i < _selectedCenter.length; i++) {
                              _selectedCenter[i] = i == index;
                            }
                            if(index == 0){
                              cuindex = 0;
                              defaultCenter = '전체';
                              getPostsData("${fnChecklocal(dropdownValue)?.first}_전체");
                            }else if(index == 1) {
                              cuindex = 1;
                              getPostsData('서울_전체');
                              SeouldefaultCenter = '전체';
                            }
                          });
                        },
                        fillColor: AppColors.background,
                        borderColor: AppColors.background,
                        selectedBorderColor: AppColors.background,
                        selectedColor: AppColors.primary,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        color: AppColors.black,
                        constraints: const BoxConstraints(
                          maxWidth: 80,
                          minWidth: 65,
                          minHeight: 20.0,
                        ),
                        children: CategoryCenter,
                      ),
                      SizedBox(width: size.width / 7),
                      cuindex == 0
                          ? DropdownButton2(
                              alignment: Alignment.center,
                              focusColor: AppColors.primary,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              isExpanded: false,
                              isDense: false,
                              underline: Container(),
                              value: defaultCenter,
                              items: centerCheck.map( (value) {
                                if(value == "전체"){
                                  return DropdownMenuItem (
                                    alignment: Alignment.center,
                                    value: value, child: Text("${value}"),
                                  );
                                }else{
                                  if(dropdownValue == '중구'){
                                    if(value == '구청'){
                                      return DropdownMenuItem (
                                        alignment: Alignment.center,
                                        value: value,
                                        child: Text("  중구청  "),
                                      );
                                    }
                                  }
                                  return DropdownMenuItem (
                                    alignment: Alignment.center,
                                    value: value,
                                    child: Text("   ${dropdownValue+value}   "),
                                  );
                                }
                              },
                              ).toList(),
                              onChanged: (value){
                                setState(() {
                                  listItems = [];
                                  centerLabel = value as String?;
                                  defaultCenter = value as String?;
                                  getPostsData(dropdownValue+"_"+defaultCenter!);
                                }
                                );
                              },
                              barrierColor: Colors.black.withOpacity(0.5),
                              iconOnClick: Icon(Icons.keyboard_arrow_up),
                              offset: const Offset(0, -3),
                              // buttonWidth: 150,
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )
                        // 서울소식 드롭다운
                        : DropdownButton2(
                            alignment: Alignment.center,
                            focusColor: AppColors.primary,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            isExpanded: false,
                            isDense: false,
                            underline: Container(),
                            value: SeouldefaultCenter,
                            items: SeoulCheck.map( (value) {
                            if(value == "전체"){
                              return DropdownMenuItem (
                                alignment: Alignment.center,
                                value: value, child: Text(value),
                              );
                            }else{
                              return DropdownMenuItem (
                                alignment: Alignment.center,
                                value: value,
                                child: value == '서울시청'
                                    ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/seoul.logo.png', width: size.width / 26),
                                    Text(value)
                                  ],
                                )
                                    : value == '서울시문화원'
                                    ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/culturewon.logo.png', width: size.width / 25),
                                    InkWell(
                                      onTap: () {
                                        final Uri url = Uri.parse('http://seoulccf.or.kr/introCulture/introCulture');
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen( url )));
                                      },
                                      child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(value)
                                      ),
                                    ),
                                  ],
                                )
                                    : value == '서울문화재단'
                                    ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/seoulCulture.png', width: size.width / 25),
                                    InkWell(
                                      onTap: () {
                                        final Uri url = Uri.parse('https://www.sfac.or.kr/opensquare/notice/notice_list.do');
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen( url )));
                                      },
                                      child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(value)
                                      ),
                                    ),
                                  ],
                                )
                                    : Text(value),
                                // value: value, child: Text(value),시
                              );
                            }
                          },
                          ).toList(),
                          onChanged: (value){
                            setState(() {
                              listItems = [];
                              seoulCenterLabel = value as String?;
                              centerLabel = value as String?;
                              SeouldefaultCenter = value as String?;
                              if(value == 'NPO지원센터'){
                                value = 'NPO';
                              }else if(value == '서울시청'){
                                value = '서울_전체';
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                          contentPadding: EdgeInsets.only(top: 0.0),
                                          content: Container(
                                              width: size.width,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  InkWell(
                                                    child: Container(
                                                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Image.asset('assets/images/seoul.logo.white.png', width: 20,height: 20,),
                                                          Text( " 서울시청", style: TextStyle( color: Colors.white,
                                                              fontWeight: FontWeight.bold),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child:AppTextButton( text: "분야별 새소식",
                                                        onPressed: () async {
                                                          final Uri url = Uri.parse('https://www.seoul.go.kr/realmnews/in/list.do');
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen( url )));
                                                        }), decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                  ),
                                                  Container(
                                                    child:AppTextButton( text: "이달의 행사 및 축제",
                                                        onPressed: () async {
                                                          final Uri url = Uri.parse('https://www.seoul.go.kr/thismteventfstvl/list.do');
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen( url )));
                                                        }), decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                  ),
                                                  Container(
                                                    child:AppTextButton( text: "이벤트 신청",
                                                        onPressed: () async {
                                                          final Uri url = Uri.parse('https://www.seoul.go.kr/eventreqst/list.do');
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen( url )));
                                                        }), decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                  ),
                                                  Container(
                                                    child:AppTextButton( text: "내 손안의 서울(공모전)",
                                                        onPressed: () async {
                                                          final Uri url = Uri.parse('https://mediahub.seoul.go.kr/competition/competitionList.do');
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen( url )));
                                                        }), decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        // Image.asset('assets/images/seoul.logo.white.png', width: 20,height: 20,),
                                                        Text( " 50플러스포털", style: TextStyle( color: Colors.white,
                                                            fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    child:AppTextButton( text: "행사소식",
                                                        onPressed: () async {
                                                          final Uri url = Uri.parse('https://50plus.or.kr/event.do');
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen( url )));
                                                        }), decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                  ),
                                                  Container(
                                                    child:AppTextButton( text: "모집공고",
                                                        onPressed: () async {
                                                          final Uri url = Uri.parse('https://www.50plus.or.kr/support.do');
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen( url )));
                                                        }), decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                  ),
                                                  Container(
                                                    child:AppTextButton( text: "교육신청",
                                                        onPressed: () async {
                                                          final Uri url = Uri.parse('https://50plus.or.kr/education.do?cost=ALL&state=JOIN&type=ALL');
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen( url )));
                                                        }), decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                  ),
                                                ],
                                              )
                                          )
                                      );
                                    }
                                );
                              }
                              getPostsData(value);
                            }
                            );
                          },
                          barrierColor: Colors.black.withOpacity(0.5),
                          iconOnClick: Icon(Icons.keyboard_arrow_up),
                          offset: const Offset(0, -3),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      ],
                    ),
                  ),
                listLength > 0
                  ? Expanded(
                    child: PagedListView<int, dynamic>(
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<dynamic>(
                        itemBuilder: (context, item, i){
                          double scale = 1.0;
                          if (topContainer > 0.5){
                            scale = i + 0.5 - topContainer;
                            if (scale < 0 ) { scale = 0;}
                            else if (scale > 1) { scale = 1; }
                          }
                          return Align(
                            heightFactor: 0.98,
                            alignment: Alignment.topCenter,
                            child: itemsData[i],
                          );
                        }
                      ),
                    )
                )
                : Expanded(
                  child: Lottie.asset(
                    'assets/lottie/searchdata.json',
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}


