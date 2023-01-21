import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dongnerang/constants/colors.constants.dart';
import 'package:dongnerang/constants/common.constants.dart';
import 'package:dongnerang/models/space.model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/seoul.url.screen.dart';
import 'package:dongnerang/util/admob.dart';
import 'package:dongnerang/util/location.dart' as mylocation;
import 'package:dongnerang/util/logger.service.dart';
import 'package:dongnerang/util/reverse.geocoding.dart';
import 'package:dongnerang/util/seoul.openapi.dart';
import 'package:dongnerang/services/sqflite.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:styled_text/styled_text.dart' as styledText;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:path/path.dart' as path;
import 'dart:math';

// 카테고리 설정
enum SpaceType {
  sports('sports', '체육강좌', '체육시설', 'sports_on.png', 'sports_off.png', 'sports_icon.png', MarkerColors.blue),
  sportsRental('sportsRental', '체육대관', '일반시설', 'sportsRental_on.png', 'sportsRental_off.png', 'sportsRental_icon.png', MarkerColors.purple),
  rental('rental', '시설대관', '대관시설', 'rental_on.png', 'rental_off.png', 'rental_icon.png', MarkerColors.lightGreen),
  culture('culture', '문화체험', '일반시설', 'culture_on.png', 'culture_off.png', 'culture_icon.png', MarkerColors.red),
  edu('edu', '교육강좌', '일반시설', 'edu_on.png', 'edu_off.png', 'edu_icon.png', MarkerColors.orange);

  const SpaceType(this.code, this.displayName, this.displaySubName, this.onMarkImg, this.offMarkImg, this.iconImg, this.iconColor);
  final String code; // Space.category와 같음
  final String displayName;
  final String displaySubName;
  final String onMarkImg;
  final String offMarkImg;
  final String iconImg;
  final int iconColor;

  factory SpaceType.getByCode(String code) {
    return SpaceType.values.firstWhere((value) => value.code == code, orElse: () => SpaceType.edu);
  }
}

class naverMapScreen extends StatefulWidget {
  const naverMapScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _naverMapScreenState();
}

class _naverMapScreenState extends State<naverMapScreen> {
  NaverMapController? _ct;

  // sqflite
  final SpaceDBHelper _spaceDBHelper = SpaceDBHelper.instance;

  // 기본 설정 : 상도역
  mylocation.Location myLocation = mylocation.Location(latitude: 37.494705, longitude: 126.959945);
  String myGu = '동작구';

  Map<String, Space> spacesMap = {};
  Map<String, Marker> markersMap = {};

  bool isLoaded = false; // 리스트 전체 로딩 보여주기 유무
  bool showBottomSheetBtn = false; // 리스트 보여주기 유무
  bool showReSearchBtn = true; // [현 동네에서 검색] 버튼 보여주기 유무

  List<SpaceType> categoryList = SpaceType.values.toList(); // 카테고리 리스트
  final List<String> _selectedChoices = <String>[]; // 선택된 카테고리 리스트
  Map<String, bool> categoryVisibility = {}; // 카테고리 보여주기 속성

  Map<String, int> categoryCount = {};
  int categoryCountSum = 0;

  // 데이터 조회 후 queue에 저장
  Future<int> makeSpacesQueue() async {
    SpacesQueue.clear();

    // 서울 공공시설 api 데이터
    await SeoulOpenApi.getOpenApiSeoulSpaces('ListPublicReservationSport'); // 체육대관
    await SeoulOpenApi.getOpenApiSeoulSpaces('ListPublicReservationInstitution'); // 시설대관
    await SeoulOpenApi.getOpenApiSeoulSpaces('ListPublicReservationCulture'); // 문화체험
    await SeoulOpenApi.getOpenApiSeoulSpaces('ListPublicReservationEducation'); // 교육강좌

    // firebase 데이터
    await getFirebaseSpaces();

    return SpacesQueue.length;
  }

  // 로컬 db에 저장 : queue -> sqflite
  Future<void> insertSpacesToLocalDB() async {
    String databasePath = await getDatabasesPath();
    String dbpath = path.join(databasePath, 'spacedatabase.db');

    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy.MM.dd');
    String strToday = formatter.format(now);

    bool isDBExists = await databaseExists(dbpath);

    if (isDBExists) {
      String upDtStr = await _spaceDBHelper.getUpdatedDate();
      // 데이터 받은 일자 체크
      if (upDtStr != '') {
        List<String> upDtStrL = upDtStr.split('.');
        int y = int.parse(upDtStrL[0]);
        int m = int.parse(upDtStrL[1]);
        int d = int.parse(upDtStrL[2]);
        DateTime upDt = DateTime(y, m, d);
        Duration duration = now.difference(upDt);

        if (duration.inDays < 31) {
          return;
        }
      }
    }

    int dataNum = await makeSpacesQueue();

    // sqflite 로컬 DB에 저장
    try {
      while (SpacesQueue.isNotEmpty) {
        Space s = SpacesQueue.removeFirst();

        // Sqflite
        await _spaceDBHelper.insertSpace(s, strToday);
      }
    } catch (e) {
      int deleteResult = await _spaceDBHelper.deleteDataAll();
      print("sqflite insert error ::: $e");
      // print("deleteResult :: $deleteResult");
    }
  }

  // firestore 데이터 queue에 저장
  Future<void> getFirebaseSpaces() async {
    String value = 'SEOUL';

    DocumentReference<Map<String, dynamic>> docref = FirebaseFirestore.instance.collection("spaces").doc(value);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await docref.get();
    late Map<String, dynamic>? valueDoc = documentSnapshot.data();
    List<String> categoryStrList = categoryList.map((e) => e.code.toString()).toList();

    valueDoc?.forEach((key, value) {
      if (value['gu'] == "" ||
          value['category'] == "" ||
          value['spaceName'] == "" ||
          value['location']['latitude'] == "" ||
          value['location']['longitude'] == "") {
        return;
      }

      // 위도, 경도 유효성 검사
      double lat = value['location']['latitude'];
      double long = value['location']['longitude'];
      if ((lat < 33 && lat > 43) || (long < 124 && long > 132)) {
        return;
      } else {
        value['location']['latitude'] = double.parse(lat.toStringAsFixed(6));
        value['location']['longitude'] = double.parse(long.toStringAsFixed(6));
      }

      // 카테고리 유효성 검사
      if (!categoryStrList.contains(value['category'])) {
        return;
      }

      Space s = Space.fromJson(value);
      SpacesQueue.add(s);
    });
  }

  // 로컬 db에서 자치구로 공간 리스트 조회
  getSpacesByGu(String gu) async {
    categoryCount.clear();

    Map<String, Space> spaces = {};

    // Sqflite
    List<Space> spacesByGu = await _spaceDBHelper.getSpaceListByGu(gu);

    try {
      // 현위치와 거리계산
      for (var s in spacesByGu) {
        categoryCount[s.category!] = (categoryCount[s.category] ?? 0) + 1;
        s.dist = getDistance(s.location["latitude"].toDouble(), s.location["longitude"].toDouble());
        spaces[s.uid] = s;
      }

      setState(() {
        spacesMap = Map.fromEntries(spaces.entries.toList()..sort((e1, e2) => e1.value.dist!.compareTo(e2.value.dist!))); // 거리순 정렬
        categoryCountSum = getCategoryCountSum();
      });
    } catch (e) {
      print("getSpacesByGu error ::: $e");
      print("getSpacesByGu error in gu ::: $gu");
    }
  }

  // marker 만들기
  makeMarkers() async {
    Map<String, Marker> markers = {};
    List<Space> spaces = spacesMap.values.toList();

    for (var space in spaces.toSet()) {
      Marker m = Marker(
        markerId: space.uid,
        position: LatLng(space.location["latitude"]!, space.location["longitude"]!),
        width: 32,
        height: 32,
        captionText: space.spaceName,
        captionMinZoom: 14,
        captionColor: Colors.black,
        captionHaloColor: Colors.white,
        captionRequestedWidth: 200,
        captionTextSize: 13,
        captionPerspectiveEnabled: true,
        icon: await OverlayImage.fromAssetImage(assetName: "assets/images/${SpaceType.getByCode(space.category!).offMarkImg}"),
        onMarkerTab: (marker, iconSize) async {
          // 마커 선택시 이벤트
          onMarkerTabEvent(marker!.markerId, false);
        },
      );

      markers[m.markerId] = m;
    }

    setState(() {
      markersMap = markers;
    });
  }

  // 전체 마커 이미지 초기화
  markerInit() {
    markersMap.forEach((mUid, mValue) async {
      Space tempSpace = spacesMap[mUid]!;

      mValue.width = 32;
      mValue.height = 32;
      mValue.icon = await OverlayImage.fromAssetImage(
          assetName: categoryVisibility[tempSpace.category] == true ? "assets/images/${SpaceType.getByCode(tempSpace.category!).offMarkImg}" : "");
    });
  }

  // 공간 한 개 위젯
  Widget makeSpaceWidget(String uid, bool isLast) {
    double width = MediaQuery.of(context).size.width;
    Space thisSpace = spacesMap[uid]!;
    String? imgurl = thisSpace.spaceImage;
    /*
    1. 장소명
    2. 이용시간 (or 주소)
    3. 카테고리명 / 거리 / [서비스상태] / [결제방법]
    4. [서비스명]
    */
    String distStr = thisSpace.dist! >= 1000 ? "${(thisSpace.dist! / 1000).toStringAsFixed(1)}km" : "${(thisSpace.dist)!.round()}m";
    String addrOrTimeInfoStr = (thisSpace.address ?? '') == ''
        ? ((thisSpace.svcTimeMin ?? '') == '' ? '' : '이용시간 | ${thisSpace.svcTimeMin} ~ ${thisSpace.svcTimeMax}')
        : thisSpace.address ?? '';
    List<String> thirdStrList = ['<black>${SpaceType.getByCode(thisSpace.category!).displayName}</black>', '<red>$distStr</red>'];
    if ((thisSpace.svcStat ?? '').trim() != '') {
      thirdStrList.add('${thisSpace.svcStat == '접수중' ? '<blue>' : ''}${thisSpace.svcStat!}${thisSpace.svcStat == '접수중' ? '</blue>' : ''}');
    }
    if ((thisSpace.payInfo ?? '').trim() != '') thirdStrList.add('<black>${thisSpace.payInfo!}</black>');

    return Visibility(
      visible: categoryVisibility[thisSpace.category]!,
      child: SizedBox(
        width: width - 26,
        child: Column(
          children: [
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. 장소명
                      AutoSizeText(
                        thisSpace.spaceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                          fontSize: 16,
                        ),
                        minFontSize: 12,
                        maxFontSize: 16,
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      // 2. 이용시간 (or 주소)
                      AutoSizeText(
                        addrOrTimeInfoStr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      // 3. 카테고리명 / 거리 / [서비스상태] / [결제방법]
                      styledText.StyledText(
                        text: thirdStrList.join(' / '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                        tags: {
                          'black': styledText.StyledTextTag(
                            style: const TextStyle(color: AppColors.black),
                          ),
                          'blue': styledText.StyledTextTag(
                            style: const TextStyle(color: AppColors.blue),
                          ),
                          'red': styledText.StyledTextTag(
                            style: const TextStyle(color: AppColors.red),
                          ),
                        },
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      // 4. [서비스명] or 업데이트일
                      (thisSpace.uid.startsWith('S'))
                          ? styledText.StyledText(
                              text: (thisSpace.svcName ?? '').replaceAll('&#39', '&apos').replaceAll('&middot;', '•'),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.info,
                                  size: 14,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                styledText.StyledText(
                                  text: "업데이트일 ${thisSpace.updated ?? ''}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CachedNetworkImage(
                    imageUrl: imgurl!,
                    imageBuilder: ((context, imageProvider) => Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              )),
                        )),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/firstLogo.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Container(child: isLast ? null : const Divider()),
          ],
        ),
      ),
    );
  }

  // 마커 선택시 이벤트
  onMarkerTabEvent(String uid, bool cameraMove) async {
    Space? space = spacesMap[uid];

    // 같은 위치에 있는 공간 리스트
    List<Space> selectedSpaces = spacesMap.values
        .where((s) => s.location['latitude'] == space!.location['latitude'] && s.location['longitude'] == space!.location['longitude'])
        .toList();
    // selectedSpace uid 리스트
    List<String> selectedUids = selectedSpaces.map((e) => e.uid).toList();

    // 지도 카메라 이동
    if (cameraMove) {
      await moveMapCamera(space!.location["latitude"]!, space.location["longitude"]!);
    }

    // 마커 이미지 및 크기 변경
    markersMap.forEach((markerUid, markerValue) async {
      if (selectedUids.contains(markerUid)) {
        markerValue.icon = await OverlayImage.fromAssetImage(assetName: "assets/images/${SpaceType.getByCode(space!.category!).onMarkImg}");
        markerValue.width = 48;
        markerValue.height = 69;
      } else {
        markerValue.width = 32;
        markerValue.height = 32;
      }
    });

    setState(() {
      showBottomSheetBtn = false;
    });

    // 공간 상세 모달
    showSpaceBottomSheet(selectedSpaces);
  }

  // 공간 상세 모달
  showSpaceBottomSheet(List<Space> selectedSpace) {
    showModalBottomSheet<void>(
      barrierColor: AppColors.black.withOpacity(0.08),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        double widthSize = MediaQuery.of(context).size.width;
        double heightSize = selectedSpace.length > 1 ? 420 : 240;

        return SizedBox(
          height: heightSize,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedSpace.length,
                  itemBuilder: (context, index) {
                    Space thisSpace = selectedSpace[index];

                    return Visibility(
                      visible: categoryVisibility[thisSpace.category]!,
                      child: InkWell(
                        onTap: (() {
                          final Uri url = Uri.parse('${thisSpace.pageLink}'.trim());
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => seoulUrlLoadScreen(url)));
                        }),
                        child: SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              makeSpaceWidget(thisSpace.uid, true),
                              ToggleButtons(
                                borderRadius: BorderRadius.circular(5),
                                direction: Axis.horizontal,
                                onPressed: (int index) async {
                                  if (index == 0) {
                                    // print("전화");
                                    launchUrl(Uri.parse("tel:${thisSpace.phoneNum}"));
                                  }
                                  if (index == 1) {
                                    // print("지도 앱");
                                    Get.dialog(ShareDialog(
                                      place: thisSpace,
                                    ));
                                  }
                                  if (index == 2) {
                                    // print("공유");
                                    String lat = thisSpace.location['latitude'].toStringAsFixed(5);
                                    String long = thisSpace.location['longitude'].toStringAsFixed(5);
                                    String addr = "";
                                    if ((thisSpace.address ?? '') == '') {
                                      addr = await ReverseGeo.getAddrByCoords(lat, long);
                                    } else {
                                      addr = thisSpace.address!;
                                    }
                                    final LocationTemplate defaultText = LocationTemplate(
                                      address: addr,
                                      content: Content(
                                          title: '우리 동네의 모든 공공소식 \'동네랑\'',
                                          description: '[${thisSpace.spaceName}]\n${thisSpace.svcName ?? addr}',
                                          imageUrl: Uri.parse(thisSpace.spaceImage!.trim()),
                                          link: Link(
                                            webUrl: Uri.parse(thisSpace.pageLink!.trim()),
                                            mobileWebUrl: Uri.parse(thisSpace.pageLink!.trim()),
                                          ),
                                          imageHeight: 50),
                                    );

                                    // 카카오톡 실행 가능 여부 확인
                                    bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
                                    if (isKakaoTalkSharingAvailable) {
                                      // print('카카오톡으로 공유 가능');
                                      try {
                                        Uri uri = await ShareClient.instance.shareDefault(template: defaultText);
                                        await ShareClient.instance.launchKakaoTalk(uri);
                                      } catch (e) {
                                        print('카카오톡 공유 실패 $e');
                                      }
                                    } else {
                                      EasyLoading.showError("카카오톡이 설치되지 않았습니다.");
                                    }
                                  }
                                },
                                borderColor: AppColors.greylottie,
                                color: AppColors.grey,
                                constraints: BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: (widthSize - 36) / 3,
                                ),
                                isSelected: const [false, false, false],
                                children: const <Widget>[Icon(CupertinoIcons.phone), Icon(Icons.location_on_outlined), Icon(Icons.share_outlined)],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() async {
      setState(() {
        markerInit();
      });
    });
  }

  // 현위치 구하기
  Future<String> getLocationData() async {
    await myLocation.getCurrentLocation(); // 시뮬레이터에서는 주석처리
    String gu = await ReverseGeo.getGuByCoords(myLocation.latitude.toString(), myLocation.longitude.toString());

    return gu;
  }

  // 지도 카메라 이동하기
  Future<void> moveMapCamera(double lat, double long) async {
    await _ct?.moveCamera(CameraUpdate.scrollTo(LatLng(lat, long + 0.002)));
  }

  // 좌표 사이 거리 구하기
  double getDistance(double x1, double y1) {
    latlong2.Distance distance = const latlong2.Distance();
    double distM = distance.as(latlong2.LengthUnit.Meter, latlong2.LatLng(x1, y1), latlong2.LatLng(myLocation.latitude, myLocation.longitude));

    return distM;
  }

  // 공간 개수 합 구하기
  int getCategoryCountSum() {
    int sum = 0;

    categoryCount.forEach((key, value) {
      sum += categoryVisibility[key] == true ? (value) : 0;
    });

    return sum;
  }

  Future<void> _asyncInitState() async {
    String gu = await getLocationData();
    await insertSpacesToLocalDB();
    await getSpacesByGu(gu);
    await makeMarkers();

    setState(() {
      isLoaded = true;
      myGu = gu;
    });
  }

  @override
  void initState() {
    super.initState();

    // 현위치 가져오기 > 로컬 DB에 저장 > 현위치 자치구로 리스트 가져오기 > 마커만들기
    _asyncInitState();

    setState(() {
      // 카테고리
      for (var element in categoryList) {
        _selectedChoices.add(element.displayName);
        categoryVisibility[element.code] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    //모바일 상단 상태 바 높이 값
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: [
            // 네이버 지도
            NaverMap(
              useSurface: kReleaseMode,
              contentPadding: const EdgeInsets.only(left: 60.0),
              minZoom: 7,
              onMapCreated: ((NaverMapController ct) async {
                _ct = ct;
                await _ct!.moveCamera(CameraUpdate.zoomOut());
                moveMapCamera(myLocation.latitude, myLocation.longitude);
              }),
              markers: markersMap.values.toList(),
              scrollGestureEnable: true,
              zoomGestureEnable: true,
              tiltGestureEnable: true,
              rotationGestureEnable: false,
              forceGesture: true,
              onMapTap: (cameraLatLng) async {
                setState(() {
                  markerInit();
                });
              },
              onCameraChange: ((latLng, reason, isAnimated) {
                setState(() {
                  showReSearchBtn = true;
                });
              }),
            ),
            // 현 동네에서 검색 버튼
            Align(
              alignment: AlignmentDirectional.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 120.0),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () async {
                      if (isLoaded) {
                        setState(() {
                          isLoaded = false;
                        });

                        CameraPosition? cp = await _ct?.getCameraPosition();
                        String gu = await ReverseGeo.getGuByCoords(cp!.target.latitude.toString(), cp.target.longitude.toString());

                        Future.delayed(const Duration(milliseconds: 500), () async {
                          await getSpacesByGu(gu);
                          await makeMarkers();
                          setState(() {
                            isLoaded = true;
                            showReSearchBtn = false;
                            markerInit();
                            myGu = gu;
                          });
                        });

                        if (gu == '') {
                          const snackBar = SnackBar(content: Text('동네시설을 찾기 위해 위치를 조정해주세요.'));

                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      } else {
                        print("로딩 중");
                      }
                    },
                    child: showReSearchBtn
                        ? Container(
                            alignment: Alignment.center,
                            width: 140,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                !isLoaded
                                    ? LoadingAnimationWidget.inkDrop(
                                        color: AppColors.primary,
                                        size: 15,
                                      )
                                    : Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.rotationY(pi),
                                        child: const Icon(
                                          CupertinoIcons.arrow_counterclockwise,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  '현 동네에서 검색',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.blue,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
            ),
            // 현위치 버튼
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 14.0),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () async {
                      await moveMapCamera(myLocation.latitude, myLocation.longitude);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 목록보기 버튼
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 14.0),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showBottomSheetBtn = true;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: const [
                          Icon(
                            Icons.menu,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '목록보기',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 목록보기 버튼 눌렀을 시 : 리스트 보임
            Align(
              alignment: Alignment.bottomLeft,
              child: GestureDetector(
                child: SizedBox(
                  width: double.infinity,
                  height: height,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: showBottomSheetBtn
                        ? Stack(
                            children: [
                              // 리스트 전체
                              Container(
                                padding: EdgeInsets.only(top: statusBarHeight, left: 16.0, right: 16.0),
                                decoration: const BoxDecoration(
                                  color: AppColors.background,
                                ),
                                child: isLoaded
                                    ? Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 40.0),
                                            child: SizedBox(
                                              width: width,
                                              height: 50,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '총 $categoryCountSum개의 공간이 검색되었습니다.',
                                                  ),
                                                  const Text('거리순'),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: MediaQuery.removePadding(
                                              context: context,
                                              removeTop: true,
                                              child: ListView.builder(
                                                itemCount: spacesMap.length + 1,
                                                itemBuilder: (BuildContext context, int index) {
                                                  // 애드몹
                                                  if (index == 0) {
                                                    return BannerAdMob();
                                                  } else {
                                                    String uid = spacesMap.keys.toList()[index - 1];

                                                    return InkWell(
                                                      onTap: () {
                                                        onMarkerTabEvent(uid, true);
                                                      },
                                                      child: makeSpaceWidget(uid, false),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(
                                        width: width,
                                        height: height,
                                        child: lottie.Lottie.asset('assets/lottie/searchdata.json'),
                                      ),
                              ),
                              // 지도보기 버튼
                              Align(
                                alignment: AlignmentDirectional.bottomEnd,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0, bottom: 14.0),
                                  child: Material(
                                    elevation: 1,
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          showBottomSheetBtn = false;
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 100,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: const [
                                            Icon(
                                              CupertinoIcons.map,
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '지도보기',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : Container(),
                  ),
                ),
              ),
            ),
            // 상단 :: 카테고리 선택 칩
            Stack(
              children: [
                Container(
                  width: width,
                  padding: EdgeInsets.only(
                    top: statusBarHeight,
                  ),
                  decoration: const BoxDecoration(color: AppColors.background),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 90),
                          child: Wrap(
                            spacing: 5.0,
                            children: categoryList.map((SpaceType choice) {
                              return FilterChip(
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                avatar: CircleAvatar(
                                  radius: 12,
                                  child: Image.asset("assets/images/${choice.iconImg}"),
                                ),
                                label: SizedBox(
                                  child: Text(
                                    choice.displayName,
                                  ),
                                ),
                                labelStyle: _selectedChoices.contains(choice.displayName)
                                    ? TextStyle(color: Colors.white, fontSize: Theme.of(context).textTheme.bodySmall?.fontSize)
                                    : TextStyle(color: Colors.grey, fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
                                selectedColor: Color(choice.iconColor),
                                showCheckmark: false,
                                selected: _selectedChoices.contains(choice.displayName),
                                onSelected: (bool value) {
                                  setState(() {
                                    if (value) {
                                      if (!_selectedChoices.contains(choice.displayName)) {
                                        _selectedChoices.add(choice.displayName);
                                        categoryVisibility[choice.code.toString()] = true;
                                      }
                                    } else if (_selectedChoices.length > 1) {
                                      _selectedChoices.removeWhere((String name) {
                                        return name == choice.displayName;
                                      });
                                      categoryVisibility[choice.code.toString()] = false;
                                    }
                                  });
                                  markerInit();
                                  categoryCountSum = getCategoryCountSum();
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 상단 :: 자치구 칩
                Positioned(
                  left: -20,
                  child: Container(
                    padding: EdgeInsets.only(top: statusBarHeight, right: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Wrap(
                        spacing: 5.0,
                        children: [
                          FilterChip(
                            pressElevation: 0,
                            backgroundColor: AppColors.background,
                            shape: const StadiumBorder(side: BorderSide(color: AppColors.ligthGrey)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            label: SizedBox(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  const Icon(
                                    CupertinoIcons.location_solid,
                                    size: 14,
                                    color: Color(0xff4D4D4D),
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: styledText.StyledText(
                                      text: ((myGu) == '') ? '⎯' : myGu,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff4D4D4D),
                                      ),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onSelected: (bool value) {},
                            showCheckmark: null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 네이버 지도 앱, 카카오 지도 앱, 구글 지도 앱 연동 팝업
class ShareDialog extends StatelessWidget {
  const ShareDialog({
    Key? key,
    required this.place,
    // this.shareLocationType = ShareLocationType.latlng,
  }) : super(key: key);
  final Space place;
  // final ShareLocationType shareLocationType;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.only(left: 31.7, right: 31.7),
      titlePadding: const EdgeInsets.only(top: 30, left: 24, bottom: 15),
      contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 25),
      buttonPadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.only(left: 17, right: 17, bottom: 20, top: 0),
      title: const Text("응용프로그램 이동",
          style: TextStyle(
            // color: AppColors.dark,
            fontWeight: FontWeight.bold,
            fontSize: 23.3,
          ),
          textAlign: TextAlign.left),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: () async {
                try {
                  await launchUrl(Uri.parse(
                      "nmap://place?lat=${place.location['latitude']}&lng=${place.location["longitude"]}&name=${place.spaceName}&zoom=16&appname=com.dongnerang.com.dongnerang"));
                  Get.back();
                } catch (e) {
                  EasyLoading.showError("네이버 지도가 설치되지 않았습니다.");
                  logger.e(e);
                }
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              leading: Image.asset(
                "assets/images/naver.png",
                width: 40,
                height: 40,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("네이버 지도"),
                ],
              ),
            ),
            ListTile(
              onTap: () async {
                try {
                  await launchUrl(Uri.parse("kakaomap://look?p=${place.location["latitude"]},${place.location["longitude"]}"));
                  Get.back();
                } catch (e) {
                  EasyLoading.showError("카카오맵이 설치되지 않았습니다.");
                  logger.e(e);
                }
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              leading: Image.asset(
                "assets/images/kakao.png",
                width: 40,
                height: 40,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("카카오 지도"),
                  // SizedBox(height: 4),
                  // Text("이 응용 프로그램의 아이콘 위치를 엽니다"),
                ],
              ),
            ),
            ListTile(
              onTap: () async {
                await launchUrl(
                    Uri.parse("https://www.google.com/maps/search/?api=1&query=${place.location["latitude"]},${place.location["longitude"]}&zoom=12"));
                Get.back();
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              leading: Image.asset(
                "assets/images/google.png",
                width: 40,
                height: 40,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("구글 지도"),
                  // SizedBox(height: 4),
                  // Text("이 응용 프로그램의 아이콘 위치를 엽니다"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
