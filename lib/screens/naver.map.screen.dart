import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dongnerang/constants/colors.constants.dart';
import 'package:dongnerang/models/space.model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/seoul.url.screen.dart';
import 'package:dongnerang/util/admob.dart';
import 'package:dongnerang/util/location.dart' as mylocation;
import 'package:dongnerang/util/logger.service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class naverMapScreen extends StatefulWidget {
  const naverMapScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _naverMapScreenState();
}

class _naverMapScreenState extends State<naverMapScreen> {
  NaverMapController? _ct;

  // 기본 설정 : 상도 창업지원센터
  mylocation.Location myLocation = mylocation.Location(
      latitude: 37.50475398269641, longitude: 126.95395829730329);

  Map<String, Space> spacesMap = {};
  Map<String, Marker> markersMap = {};

  bool showBottomSheetBtn = false; // 리스트 보여주기 유무

  // 마커 이미지
  // A: 일반시설
  // B: 체육시설
  Map<String, String> onMarkImg = {
    "A": "A_on.png",
    "B": "B_on.png",
  };
  Map<String, String> offMarkImg = {
    "A": "A_off.png",
    "B": "B_off.png",
  };

  final List<String> items = ['전체', '체육시설', '동네시설']; // 카테고리
  final List<String> itemsList = ['체육시설', '동네시설']; // 목록보기
  String selectedValue = ''; // 선택된 카테고리
  String centerValue = "";

  Map<String, bool> spaceVisibility = <String, bool>{
    "A": true,
    "B": true
  }; // 카테고리 설정에 따라 보여줌 설정 리스트

  // firestore에서 전체 space 가져오기
  Future<List<Space>> getSpacesAll() async {
    Map<String, Space> spaces = {};

    getLocationData(); // 현위치 가져오기

    await FirebaseFirestore.instance
        .collection('spaces')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Space s = Space.fromSnapshot(doc);
        s.dist = getDistance(s.location["latitude"], s.location["longitude"]);
        spaces[s.uid] = s;
      });
    });

    setState(() {
      spacesMap = Map.fromEntries(spaces.entries.toList()
        ..sort((e1, e2) => e1.value.dist!.compareTo(e2.value.dist!))); // 거리순 정렬
    });

    return spaces.values.toList();
  }

  // marker 만들기
  Future<List<Marker>> makeMarkers(List<Space> spaces) async {
    Map<String, Marker> markers = {};

    for (var space in spaces) {
      Marker m = Marker(
        markerId: space.uid,
        position:
            LatLng(space.location["latitude"]!, space.location["longitude"]!),
        width: 32,
        height: 46,
        captionText: space.spaceName,
        captionMinZoom: 14,
        captionColor: Colors.black,
        // captionColor: Colors.blueAccent[700],
        //글씨 밑줄
        captionHaloColor: Colors.white,
        captionRequestedWidth: 200,
        captionTextSize: 15,
        captionPerspectiveEnabled: true,
        icon: await OverlayImage.fromAssetImage(
            assetName: "assets/images/${offMarkImg[space.category]}"),
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

    return markers.values.toList();
  }

  // 전체 마커 이미지 초기화
  markerInit() {
    markersMap.forEach((mUid, mValue) async {
      Space? tempSpace = spacesMap[mUid];
      String? tempCate = tempSpace?.category;

      mValue.width = 32;
      mValue.height = 46;
      mValue.icon = await OverlayImage.fromAssetImage(
          assetName: spaceVisibility[tempCate] == true
              ? "assets/images/${offMarkImg[tempCate]}"
              : "");
    });
  }

  // 공간 한 개 위젯
  Widget makeSpaceWidget(String uid) {
    double width = MediaQuery.of(context).size.width;
    Space? thisSpace = spacesMap[uid];
    String? imgurl = thisSpace?.spaceImage;
    // 구글드라이브 이미지는 이미지 주소 변경 필요 아래 참조
    // 변경 전 예시: 'https://drive.google.com/file/d/1y-CzrDCrJroPZD0wPmAuzB6JQntp0Uej';
    // 변경 후 예시: "https://drive.google.com/uc?export=view&id=1y-CzrDCrJroPZD0wPmAuzB6JQntp0Uej";
    String? cate = thisSpace?.category;
    String cateStr = "";
    switch (cate) {
      case "A":
        cateStr = "일반시설";
        break;
      case "B":
        cateStr = "체육시설";
        break;
      default:
        break;
    }
    String distStr = thisSpace!.dist! >= 1000
        ? "${(thisSpace.dist! / 1000).toStringAsFixed(1)}km"
        : "${(thisSpace.dist)!.round()}m";

    return Visibility(
      visible: spaceVisibility[cate]!,
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
                  flex: 2,
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
                            cateStr,
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
                      Text(
                          thisSpace.address,
                          style: TextStyle(
                            fontSize: 14,
                          )),
                      const SizedBox(
                        height: 8,
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.red,
                          ),
                          Text(
                            distStr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 12,
                            color: Colors.grey,
                          ),
                          Text(
                            ' 업데이트일 ${thisSpace.updated.replaceAll('-', '.')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  // fit: FlexFit.loose,
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
            // const Divider(),
          ],
        ),
      ),
    );
  }

  // 마커 선택시 이벤트
  onMarkerTabEvent(String uid) async {
    Space? space = spacesMap[uid];

    // 지도 카메라 이동
    moveMapCamera(space!.location["latitude"]!, space.location["longitude"]!);

    // 마커 이미지 및 크기 변경
    // markersMap.forEach((markerUid, markerValue) async {
    //   if (markerUid == uid) {
    //     markerValue.icon = await OverlayImage.fromAssetImage(
    //         assetName: "assets/images/${onMarkImg[space?.category]}");
    //     markerValue.width = 48;
    //     markerValue.height = 69;
    //     // markerValue.width = 32;
    //     // markerValue.height = 46;
    //   } else {
    //     markerValue.width = 32;
    //     markerValue.height = 46;
    //   }
    // });

    setState(() {
      showBottomSheetBtn = false;
    });

    // 공간 상세 모달
    showMarkerBottomSheet(space!);
  }

  // 공간 상세 모달
  showMarkerBottomSheet(Space space) {
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
        double widthSize = MediaQuery.of(context).size.width;
        Space thisSpace = space;

        return InkWell(
          onTap: (() {
            final Uri url = Uri.parse('${thisSpace.pageLink}');
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => seoulUrlLoadScreen(url)));
          }),
          child: Container(
            height: 250,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                makeSpaceWidget(thisSpace.uid),
                // makeSpaceWidget(thisSpace.uid),
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
                      // print("공유");
                      final LocationTemplate defaultText = LocationTemplate(
                        address: thisSpace.address,
                        content: Content(
                          title:
                              '우리 동네의 모든 공공소식 \'동네랑\'\n\n[${thisSpace.spaceName}]\n\n',
                          imageUrl: Uri.parse(thisSpace.spaceImage!),
                          link: Link(
                            webUrl: Uri.parse(thisSpace.pageLink!),
                            mobileWebUrl: Uri.parse(thisSpace.pageLink!),
                          ),
                        ),
                      );

                      // 카카오톡 실행 가능 여부 확인
                      bool isKakaoTalkSharingAvailable = await ShareClient
                          .instance
                          .isKakaoTalkSharingAvailable();
                      if (isKakaoTalkSharingAvailable) {
                        print('카카오톡으로 공유 가능');
                        try {
                          // Uri uri = await ShareClient.instance.shareScrap(url: firebasesUrl);
                          // await ShareClient.instance.launchKakaoTalk(uri);
                          Uri uri = await ShareClient.instance
                              .shareDefault(template: defaultText);
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
                  children: const <Widget>[
                    Icon(CupertinoIcons.phone),
                    Icon(Icons.location_on_outlined),
                    Icon(Icons.share_outlined)
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() async {
      markerInit();
    });
  }

  // 현위치 구하기
  getLocationData() async {
    await myLocation.getCurrentLocation();

    print(
        "getLocationData>> ${myLocation.latitude} ### ${myLocation.longitude}");
  }

  // 지도 카메라 이동하기
  void moveMapCamera(double lat, double long) async {
    await _ct?.moveCamera(CameraUpdate.scrollTo(LatLng(lat, long)));
  }

  // 좌표 사이 거리 구하기
  double getDistance(double x1, double y1) {
    latlong2.Distance distance = const latlong2.Distance();
    double distM = distance.as(
        latlong2.LengthUnit.Meter,
        latlong2.LatLng(x1, y1),
        latlong2.LatLng(myLocation.latitude, myLocation.longitude));

    return distM;
  }

  @override
  void initState() {
    super.initState();
    print("initState ======>");

    getLocationData().then((value) {
      getSpacesAll().then((value) {
        makeMarkers(value);
      });
    });

    setState(() {
      selectedValue = items.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    //모바일 상단 상태 바 높이 값
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // background widget
          Scaffold(
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
                      markerInit();
                    },
                  ),
                  // 카테고리 드롭다운
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, left: 16.0),
                    child: Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          items: items
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: selectedValue,
                          onChanged: (value) {
                            bool aVisibility = true;
                            bool bVisibility = true;

                            if (value == items[1]) {
                              // 체육시설만
                              aVisibility = false;
                              bVisibility = true;
                            } else if (value == items[2]) {
                              // 일반시설만
                              aVisibility = true;
                              bVisibility = false;
                            } else {
                              // 전체
                              aVisibility = true;
                              bVisibility = true;
                            }

                            markersMap.forEach((key, value) async {
                              Space? s = spacesMap[key];

                              // visibility에 따라 마커 안보임 처리
                              if (s?.category == "A" && !aVisibility) {
                                value.icon = await OverlayImage.fromAssetImage(
                                    assetName: "");
                              } else if (s?.category == "B" && !bVisibility) {
                                value.icon = await OverlayImage.fromAssetImage(
                                    assetName: "");
                              } else {
                                value.icon = await OverlayImage.fromAssetImage(
                                    assetName:
                                        "assets/images/${offMarkImg[s?.category]}");
                              }
                            });

                            setState(() {
                              selectedValue = value as String;
                              spaceVisibility["A"] = aVisibility;
                              spaceVisibility["B"] = bVisibility;
                            });
                          },
                          buttonHeight: 30,
                          buttonWidth: 100,
                          itemHeight: 30,
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          buttonPadding:
                              const EdgeInsets.only(left: 14, right: 5),
                          barrierColor: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, -3),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
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
                            moveMapCamera(
                                myLocation.latitude, myLocation.longitude);
                            // await _ct?.moveCamera(CameraUpdate.scrollTo(LatLng(
                                // myLocation.latitude, myLocation.longitude)));
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
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              child: SizedBox(
                width: double.infinity,
                height: height,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: double.infinity, maxHeight: height),
                  child: showBottomSheetBtn
                      ?
                  // 목록보기 버튼 눌렀을 시 : 리스트 보임
                  Stack(
                    children: [
                      // 리스트 전체
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: statusBarHeight),
                          child: Column(
                            children: <Widget>[
                              // 애드몹
                              BannerAdMob(),
                              //chip
                              //     ChoiceChip(
                              //     selected: _selected,
                              //     label: Text('Woolha'),
                              //     onSelected: (bool selected) {
                              //       setState(() {
                              //         _selected = !_selected;
                              //       });
                              //     }
                              // ),
                              // 리스트
                              Expanded(
                                child: ListView.builder(
                                  itemCount: spacesMap.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String uid =
                                    spacesMap.keys.toList()[index];

                                    return InkWell(
                                      onTap: () {
                                        onMarkerTabEvent(uid);
                                      },
                                      child: makeSpaceWidget(uid),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 지도보기 버튼
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 16.0, bottom: 14.0),
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
                                  crossAxisAlignment:
                                  WrapCrossAlignment.center,
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
          )
        ],
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
      actionsPadding:
          const EdgeInsets.only(left: 17, right: 17, bottom: 20, top: 0),
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
                  await launchUrl(Uri.parse(
                      "kakaomap://look?p=${place.location["latitude"]},${place.location["longitude"]}"));
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
                await launchUrl(Uri.parse(
                    "https://www.google.com/maps/search/?api=1&query=${place.location["latitude"]},${place.location["longitude"]}&zoom=12"));
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
