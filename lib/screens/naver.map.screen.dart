import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

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
import 'package:flutter_html/style.dart';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:lottie/lottie.dart' as lottie;
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

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
  final SpaceDBHelper _spaceDBHelper = SpaceDBHelper();
  // 기본 설정 : 상도 창업지원센터
  mylocation.Location myLocation = mylocation.Location(latitude: 37.50475398269641, longitude: 126.95395829730329);

  Map<String, Space> spacesMap = {};
  Map<String, Marker> markersMap = {};

  bool isLoaded = false; // 로딩 보여주기 유무
  bool showBottomSheetBtn = false; // 리스트 보여주기 유무

  List<SpaceType> categoryList = SpaceType.values.toList(); // 카테고리 리스트
  final List<String> _selectedChoices = <String>[]; // 선택된 카테고리 리스트
  Map<String, bool> categoryVisibility = {}; // 카테고리 보여주기 속성

  // 로컬 db에 저장 : queue -> sqflite DB
  insertSpacesToSqflite() async {
    // queue에 저장
    SpacesQueue.clear();

    // 서울 공공시설 api 데이터
    await SeoulOpenApi.getOpenApiSeoulSpaces('ListPublicReservationSport'); // 체육대관
    await SeoulOpenApi.getOpenApiSeoulSpaces('ListPublicReservationInstitution'); // 시설대관
    await SeoulOpenApi.getOpenApiSeoulSpaces('ListPublicReservationCulture'); // 문화체험
    await SeoulOpenApi.getOpenApiSeoulSpaces('ListPublicReservationEducation'); // 교육강좌
    // firebase 데이터
    await getFirebaseSpaces();

    print(SpacesQueue.length);

    // sqflite 로컬 DB에 저장
    while (SpacesQueue.isNotEmpty) {
      Space s = SpacesQueue.removeFirst();
      try {
        await _spaceDBHelper.insertSpace(s);
      } catch (e) {
        print(s);
        print(e);
      }
    }
  }

  // firestore 데이터 queue에 저장
  getFirebaseSpaces() async {
    String value = 'SEOUL';

    DocumentReference<Map<String, dynamic>> docref = FirebaseFirestore.instance.collection("spaces").doc(value);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await docref.get();
    late Map<String, dynamic>? valueDoc = documentSnapshot.data();

    valueDoc?.forEach((key, value) {
      Space s = Space.fromJson(value);
      SpacesQueue.add(s);
    });
  }

  // 로컬 db에서 자치구로 리스트 조회
  getSpacesFromSqflite(String gu) async {
    print("getSpacesFromSqflite");
    Map<String, Space> spaces = {};
    List<Space> spacesByGu = await _spaceDBHelper.getSpaceListByGu(gu);

    print("spacesByGu.length: ${spacesByGu.length}");

    // 현위치와 거리계산
    for (var s in spacesByGu) {
      s.dist = getDistance(s.location["latitude"].toDouble(), s.location["longitude"].toDouble());
      spaces[s.uid] = s;
    }

    setState(() {
      spacesMap = Map.fromEntries(spaces.entries.toList()..sort((e1, e2) => e1.value.dist!.compareTo(e2.value.dist!))); // 거리순 정렬
    });
  }

  // marker 만들기
  makeMarkers() async {
    print("makeMarkers");
    Map<String, Marker> markers = {};
    List<Space> spaces = spacesMap.values.toList();

    for (var space in spaces) {
      Marker m = Marker(
        markerId: space.uid,
        position: LatLng(space.location["latitude"]!, space.location["longitude"]!),
        width: 32,
        height: 32,
        captionText: space.spaceName,
        captionMinZoom: 13,
        captionColor: Colors.black,
        captionHaloColor: Colors.white,
        captionRequestedWidth: 200,
        captionTextSize: 15,
        captionPerspectiveEnabled: true,
        icon: await OverlayImage.fromAssetImage(assetName: "assets/images/${SpaceType.getByCode(space.category!).offMarkImg}"),
        onMarkerTab: (marker, iconSize) async {
          // 마커 선택시 이벤트
          onMarkerTabEvent(marker!.markerId);
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
    // 구글드라이브 이미지는 이미지 주소 변경 필요 아래 참조
    // 변경 전 예시: 'https://drive.google.com/file/d/1y-CzrDCrJroPZD0wPmAuzB6JQntp0Uej';
    // 변경 후 예시: "https://drive.google.com/uc?export=view&id=1y-CzrDCrJroPZD0wPmAuzB6JQntp0Uej";
/*
    1. 장소명, 예약구분(기존 엑셀파일에서 상세정보 부분)
    2. 서비스명 (기존 엑셀파일 정보들은 주소 출력)
    3. 서비스대상 (제한없음이면 서비스 이용시간 출력 > 기존 엑셀파일 정보들은 출력안함? or 이용시간 추가 필요?)
    4. 거리 / 서비스상태 / 결제방법 (기존 엑셀파일정보들 출력안함? or 서비스 상태와 결제방법 추가 필요?)
*/
    String addrOrSvcNm = (thisSpace.address ?? '') == '' ? thisSpace.svcName ?? '' : thisSpace.address ?? '';
    String svcInfo = (thisSpace.useTarget ?? '').trim() == '' || (thisSpace.useTarget ?? '').trim() == '제한없음'
        ? ((thisSpace.svcTimeMin ?? '') == '' ? '' : '이용시간 : ${thisSpace.svcTimeMin} ~ ${thisSpace.svcTimeMax}')
        : '서비스 대상 : ${thisSpace.useTarget!.trim()}';
    String distStr = thisSpace.dist! >= 1000 ? "${(thisSpace.dist! / 1000).toStringAsFixed(1)}km" : "${(thisSpace.dist)!.round()}m";

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
                      Row(
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Text(
                              thisSpace.spaceName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            SpaceType.getByCode(thisSpace.category!).displayName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(addrOrSvcNm,
                          style: const TextStyle(
                            fontSize: 14,
                          )),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(svcInfo,
                          style: const TextStyle(
                            fontSize: 14,
                          )),
                      const SizedBox(
                        height: 8,
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            distStr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.red,
                            ),
                          ),
                          ((thisSpace.svcStat ?? '') != '')
                              ? Wrap(children: [
                                  const Text(
                                    ' / ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  Text(
                                    thisSpace.svcStat!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blue,
                                    ),
                                  )
                                ])
                              : Wrap(),
                          ((thisSpace.payInfo ?? '') != '')
                              ? Wrap(children: [
                                  const Text(
                                    ' / ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  Text(
                                    thisSpace.payInfo!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  )
                                ])
                              : Wrap(),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
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
  onMarkerTabEvent(String uid) async {
    Space? space = spacesMap[uid];

    // 같은 위치에 있는 공간 리스트
    List<Space> selectedSpaces = spacesMap.values
        .where((s) => s.location['latitude'] == space!.location['latitude'] && s.location['longitude'] == space!.location['longitude'])
        .toList();

    selectedSpaces.forEach((e) {
      print(e);
    });

    // 지도 카메라 이동
    moveMapCamera(space!.location["latitude"]!, space.location["longitude"]!);

    // 마커 이미지 및 크기 변경
    markersMap.forEach((markerUid, markerValue) async {
      if (markerUid == uid) {
        markerValue.icon = await OverlayImage.fromAssetImage(assetName: "assets/images/${SpaceType.getByCode(space.category!).onMarkImg}");
        markerValue.width = 48;
        markerValue.height = 69;
        // markerValue.width = 32;
        // markerValue.height = 46;
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
      useRootNavigator: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        print("selectedlength:: ${selectedSpace.length}");
        double widthSize = MediaQuery.of(context).size.width;
        double heightSize = selectedSpace.length > 1 ? 500 : 250;

        return SizedBox(
          height: heightSize + 38.0,
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
                        child: Container(
                          height: 250,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // const SizedBox(
                              //   height: 4,
                              // ),
                              makeSpaceWidget(thisSpace.uid, true),
                              ToggleButtons(
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
                                    String lat = thisSpace.location['latitude'].toStringAsFixed(5);
                                    String long = thisSpace.location['longitude'].toStringAsFixed(5);
                                    String addr = "";
                                    if ((thisSpace.address ?? '') == '') {
                                      addr = await ReverseGeo.getAddrByCoords(lat, long);
                                    } else {
                                      addr = thisSpace.address!;
                                    }
                                    // print("공유");
                                    final LocationTemplate defaultText = LocationTemplate(
                                      address: addr,
                                      content: Content(
                                        title: '''
                                        우리 동네의 모든 공공소식 \'동네랑\'\n\n
                                        [${thisSpace.spaceName}]\n\n
                                        $addr\n\n
                                        ${thisSpace.svcName ?? ''}\n\n
                                        ''',
                                        imageUrl: Uri.parse(thisSpace.spaceImage!.trim()),
                                        link: Link(
                                          webUrl: Uri.parse(thisSpace.pageLink!.trim()),
                                          mobileWebUrl: Uri.parse(thisSpace.pageLink!.trim()),
                                        ),
                                      ),
                                    );

                                    // 카카오톡 실행 가능 여부 확인
                                    bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
                                    if (isKakaoTalkSharingAvailable) {
                                      print('카카오톡으로 공유 가능');
                                      try {
                                        // Uri uri = await ShareClient.instance.shareScrap(url: firebasesUrl);
                                        // await ShareClient.instance.launchKakaoTalk(uri);
                                        Uri uri = await ShareClient.instance.shareDefault(template: defaultText);
                                        await ShareClient.instance.launchKakaoTalk(uri);
                                        // EasyLoading.showSuccess("공유 완료");
                                      } catch (e) {
                                        print('카카오톡 공유 실패 $e');
                                      }
                                    } else {
                                      print('카카오톡 미설치: 웹 공유 기능 사용 권장');
                                    }
                                  }
                                },
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
  getLocationData() async {
    await myLocation.getCurrentLocation();
    // print("getLocationData>> ${myLocation.latitude} ### ${myLocation.longitude}");
  }

  // 지도 카메라 이동하기
  void moveMapCamera(double lat, double long) async {
    await _ct?.moveCamera(CameraUpdate.scrollTo(LatLng(lat, long)));
  }

  // 좌표 사이 거리 구하기
  double getDistance(double x1, double y1) {
    latlong2.Distance distance = const latlong2.Distance();
    double distM = distance.as(latlong2.LengthUnit.Meter, latlong2.LatLng(x1, y1), latlong2.LatLng(myLocation.latitude, myLocation.longitude));

    return distM;
  }

  @override
  void initState() {
    super.initState();
    print("initState ======>");
    // 로컬 db에 저장 > 현위치 가져오기 > 현위치 자치구로 리스트 가져오기 > 마커만들기
    insertSpacesToSqflite().then((value) {
      getSpacesFromSqflite("동작구").then((value) => makeMarkers());

      setState(() {
        isLoaded = true;
      });
    });

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
              onMapCreated: ((NaverMapController ct) {
                _ct = ct;
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
            ),
            // 현 지도에서 검색 버튼
            Align(
              alignment: AlignmentDirectional.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 120.0),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        isLoaded = false;
                      });

                      CameraPosition? a = await _ct?.getCameraPosition();
                      String cameraLat = a!.target.latitude.toStringAsFixed(5);
                      String cameraLong = a.target.longitude.toStringAsFixed(5);
                      String gu = await ReverseGeo.getGuByCoords(cameraLat, cameraLong);
                      print("gu>> $gu");

                      await getSpacesFromSqflite(gu);
                      await makeMarkers();

                      setState(() {
                        markerInit();
                        isLoaded = true;
                      });
                    },
                    child: Container(
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
                        children: const [
                          Icon(
                            Icons.replay_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '현 지도에서 검색',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: AppColors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      moveMapCamera(myLocation.latitude, myLocation.longitude);
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
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: spacesMap.length + 1,
                                              itemBuilder: (BuildContext context, int index) {
                                                if (spacesMap.length == 0) {
                                                  return Column(
                                                    children: [
                                                      BannerAdMob(),
                                                      const Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 16.0),
                                                        child: Text(
                                                          '0건이 조회되었습니다.',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                }
                                                // 애드몹
                                                if (index == 0) {
                                                  return BannerAdMob();
                                                } else {
                                                  String uid = spacesMap.keys.toList()[index - 1];

                                                  return InkWell(
                                                    onTap: () {
                                                      onMarkerTabEvent(uid);
                                                    },
                                                    child: makeSpaceWidget(uid, false),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
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
            // 카테고리 선택 칩
            Container(
              width: width,
              padding: EdgeInsets.only(top: statusBarHeight, left: 16.0, right: 16.0),
              decoration: const BoxDecoration(color: AppColors.background),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    // showBottomSheetBtn
                    //     ? SizedBox(
                    //         child: Text(
                    //           '거리순',
                    //           style: TextStyle(
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: Theme.of(context)
                    //                 .textTheme
                    //                 .bodySmall
                    //                 ?.fontSize,
                    //           ),
                    //         ),
                    //       )
                    //     : SizedBox()
                  ],
                ),
              ),
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
