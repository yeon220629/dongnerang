import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dongnerang/constants/colors.constants.dart';
import 'package:dongnerang/constants/common.constants.dart';
import 'package:dongnerang/models/space.model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/seoul.url.screen.dart';
import 'package:dongnerang/services/hive.service.dart';
import 'package:dongnerang/util/admob.dart';
import 'package:dongnerang/util/eshare.openapi.dart';
import 'package:dongnerang/util/location.dart' as mylocation;
import 'package:dongnerang/util/logger.service.dart';
import 'package:dongnerang/util/reverse.geocoding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math';

import 'package:http/http.dart' as http;

// 카테고리 설정
enum SpaceType {
  sports('S', '체육강좌', '체육시설', 'sports_on.png', 'sports_off.png', 'sports_icon.png', MarkerColors.blue),
  sportsRental('SR', '체육대관', '일반시설', 'sportsRental_on.png', 'sportsRental_off.png', 'sportsRental_icon.png', MarkerColors.purple),
  rental('R', '시설대관', '대관시설', 'rental_on.png', 'rental_off.png', 'rental_icon.png', MarkerColors.lightGreen),
  culture('C', '문화체험', '일반시설', 'culture_on.png', 'culture_off.png', 'culture_icon.png', MarkerColors.red),
  edu('E', '교육강좌', '일반시설', 'edu_on.png', 'edu_off.png', 'edu_icon.png', MarkerColors.orange);

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

class googleMapScreen extends StatefulWidget {
  final StatusNumber;
  googleMapScreen(this.StatusNumber);

  @override
  State<StatefulWidget> createState() => _googleMapScreenState();
}

class _googleMapScreenState extends State<googleMapScreen> {
  bool WidgetfirstOpen = true;

  // Google Map controller
  late final GoogleMapController _ct;
  CameraPosition position = const CameraPosition(target: LatLng(37.494705, 126.959945), zoom: 14);

  // Hive
  final Box<Space> _spaceBox = HiveBoxes.getHiveSpace();

  // 기본 현위치, 자치구 설정 : 상도역, 동작구
  mylocation.Location myLocation = mylocation.Location(latitude: 37.494705, longitude: 126.959945);
  String myGu = '동작구';

  // Map<String, Space> spacesMap = {};
  Map<String, Marker> markersMap = {};

  // 위젯 관련 변수
  bool isLoaded = false; // 리스트 전체 로딩 보여주기 유무
  bool showBottomSheetBtn = false; // 리스트 보여주기 유무
  bool showReSearchBtn = true; // [현 동네에서 검색] 버튼 보여주기 유무

  // 카테고리 관련 변수
  List<SpaceType> categoryList = SpaceType.values.toList(); // 카테고리 리스트
  final List<String> _selectedChoices = <String>[]; // 선택된 카테고리 리스트
  Map<String, bool> categoryVisibility = {}; // 카테고리 보여주기 속성
  Map<String, int> categoryCount = {}; // 카테고리별 공간 개수
  int categoryCountSum = 0; // 카테고리별 공간 개수 총 합

  // ListView paging 관련 변수
  final int _pageSize = 10;
  final PagingController<int, Space> _pagingController = PagingController(firstPageKey: 0);

  // firestore 데이터 가져와 queue에 저장하는 함수
  Future<void> getFirebaseSpaces(String docName, String subCollectionName, String gu) async {
    List<String> categoryStrList = categoryList.map((e) => e.code.toString()).toList();

    DocumentReference<Map<String, dynamic>> docref = FirebaseFirestore.instance.collection("spaces").doc(docName).collection(subCollectionName).doc(gu);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await docref.get();
    late Map<String, dynamic>? valueDoc = documentSnapshot.data(); // JSON 파일(updated, spaces)

    if (valueDoc != null) {
      for (var space in valueDoc['spaces']) {
        if (space['gu'] == "" || space['category'] == "" || space['spaceName'] == "" || space['latitude'] == "" || space['longitude'] == "") {
          break;
        }

        // 위도, 경도 유효성 검사
        double lat = space['latitude'];
        double long = space['longitude'];
        if ((lat > 33 && lat < 43) && (long > 124 && long < 132)) {
          space['latitude'] = double.parse(lat.toStringAsFixed(6));
          space['longitude'] = double.parse(long.toStringAsFixed(6));
        } else {
          break;
        }

        // 카테고리 유효성 검사
        if (!categoryStrList.contains(space['category'])) {
          break;
        }

        Space s = Space.fromJson(space);
        SpacesQueue.add(s);
      }
    }
  }

  // 자치구로 공간 리스트 조회하는 함수
  Future<void> getSpacesByGu(Map<String, String> area) async {
    categoryCount.clear();
    await _spaceBox.clear();

    // Firestore 공간 데이터 -> SpacesQueue에 저장
    await getFirebaseSpaces("dongnerangSpaces", "dongnerangSpacesByGu", area['gu']!);
    await getFirebaseSpaces("seoulApiSpaces", "seoulApiSpacesByGu", area['gu']!);
    // 공유누리 공간 api 호출 -> SpacesQueue에 저장
    await EshareOpenApi.getAllEshareApiSpaces(area['areaCode']!);

    try {
      while (SpacesQueue.isNotEmpty) {
        Space s = SpacesQueue.removeFirst();

        categoryCount[s.category!] = (categoryCount[s.category] ?? 0) + 1; // 카테고리별 개수 추가
        s.dist = getDistance(s.latitude.toDouble(), s.longitude.toDouble()); // 현위치와 거리계산

        // hive 저장
        await _spaceBox.put(s.uid, s);
      }

      setState(() {
        // spacesMap = Map.fromEntries(spaces.entries.toList()..sort((e1, e2) => e1.value.dist!.compareTo(e2.value.dist!))); // 거리순 정렬
        categoryCountSum = getCategoryCountSum();
      });
    } catch (e) {
      print("getSpacesByGu error ::: $e");
    }
  }

  // 마커 아이콘 byte로 변환하는 함수
  Future<Uint8List> getBytesFromMarkerIconAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();

    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  // marker 만들기 함수
  Future<void> makeMarkers() async {
    markersMap.clear();

    for (var space in _spaceBox.values.toSet()) {
      Uint8List markerIconByte = await getBytesFromMarkerIconAsset("assets/images/${SpaceType.getByCode(space.category!).offMarkImg}", 100);

      Marker m = Marker(
        markerId: MarkerId(space.uid),
        position: LatLng(space.latitude, space.longitude),
        icon: BitmapDescriptor.fromBytes(markerIconByte),
        onTap: () => onMarkerTabEvent(space.uid, false),
        consumeTapEvents: true,
        visible: categoryVisibility[space.category] ?? true,
      );

      markersMap[space.uid] = m;
    }
  }

  // 전체 마커 이미지 초기화 함수
  void markerInit() {
    markersMap.forEach((markerUid, markerValue) async {
      String cate = _spaceBox.get(markerUid)!.category!;
      Uint8List markerIconByte = await getBytesFromMarkerIconAsset("assets/images/${SpaceType.getByCode(cate).offMarkImg}", 100);

      setState(() {
        markersMap.update(
          markerUid,
          (value) => value.copyWith(
            iconParam: BitmapDescriptor.fromBytes(markerIconByte),
            visibleParam: categoryVisibility[cate],
          ),
        );
      });
    });
  }

  String replaceEscapedChar(String org) {
    String newStr = org
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', '\'')
        .replaceAll('&#39;', '\'')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&space;', ' ')
        .replaceAll('&middot;', '•');

    return newStr;
  }

  // 공간 한 개 위젯
  Widget makeSpaceWidget(String uid, bool isLast) {
    double width = MediaQuery.of(context).size.width;
    Space thisSpace = _spaceBox.get(uid)!;
    String? imgurl = thisSpace.spaceImage;
    /*
    1. 장소명
    2. 이용시간 (or 주소)
    3. 카테고리명 / 거리 / [서비스상태] / [결제방법]
    4. [서비스명]
    */
    String distStr = thisSpace.dist! >= 1000 ? "${(thisSpace.dist! / 1000).toStringAsFixed(1)}km" : "${(thisSpace.dist)!.round()}m";
    String updatedStr = thisSpace.updated == null ? getToday().replaceAll('-', '.') : ((thisSpace.updated!).split(' ')[0].replaceAll('-', '.'));
    String addrOrTimeInfoStr = (thisSpace.address ?? '') == ''
        ? ((thisSpace.svcTimeMin ?? '') == '' ? '이용시간 | ' : '이용시간 | ${thisSpace.svcTimeMin} ~ ${thisSpace.svcTimeMax}')
        : thisSpace.address ?? '';
    List<String> thirdStrList = [(SpaceType.getByCode(thisSpace.category!).displayName), distStr, thisSpace.svcStat ?? '', thisSpace.payInfo ?? ''];

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
                        thisSpace.spaceName.replaceAll('&amp;', '&'),
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
                      Wrap(
                        children: [
                          // 카테고리명
                          Text(
                            '${thirdStrList[0]} / ',
                            style: const TextStyle(fontSize: 14, color: AppColors.grey),
                          ),
                          // 거리
                          Text(
                            thirdStrList[1],
                            style: const TextStyle(fontSize: 14, color: AppColors.grey),
                          ),
                          // [서비스상태]
                          thirdStrList[2] != ''
                              ? Wrap(
                                  children: [
                                    const Text(
                                      ' / ',
                                      style: TextStyle(fontSize: 14, color: AppColors.grey),
                                    ),
                                    Text(
                                      thirdStrList[2],
                                      style: TextStyle(fontSize: 14, color: thirdStrList[2] == '접수중' ? AppColors.blue : AppColors.grey),
                                    ),
                                  ],
                                )
                              : Wrap(),
                          // [결제방법]
                          thirdStrList[3] != ''
                              ? Wrap(
                                  children: [
                                    const Text(
                                      ' / ',
                                      style: TextStyle(fontSize: 14, color: AppColors.grey),
                                    ),
                                    Text(
                                      thirdStrList[3],
                                      style: const TextStyle(fontSize: 14, color: AppColors.black),
                                    ),
                                  ],
                                )
                              : Wrap(),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      // 4. [서비스명] or 업데이트일
                      (thisSpace.uid.startsWith('S'))
                          ? Text(
                              replaceEscapedChar(thisSpace.svcName ?? ''),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.black,
                              ),
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
                                Text(
                                  "업데이트일 $updatedStr",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey,
                                  ),
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
                  child: (!(thisSpace.uid.startsWith('S') || thisSpace.uid.startsWith('DONG')))
                      ? loadImage(imgurl!) // 공유누리 데이터 이미지
                      : CachedNetworkImage(
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

  // 공유누리 데이터 이미지 > byte로 받기
  Future<Uint8List?> urlLoadByte(String imageUrl) async {
    try {
      Uri imageUri = Uri.parse(imageUrl);
      http.Response response = await http.get(imageUri);

      switch (response.statusCode) {
        case 201:
          return response.bodyBytes;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  // 공유누리 데이터 이미지 위젯
  Widget loadImage(String url) {
    Uint8List? imageBytes;

    return FutureBuilder(
      future: urlLoadByte(url),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          imageBytes = snapshot.data as Uint8List?;
          Image img = Image.memory(imageBytes!);

          return Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: img.image,
                  fit: BoxFit.cover,
                )),
          );
        } else if (snapshot.hasError) {
          print(snapshot.hasError);
        }
        return Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: AssetImage("assets/images/firstLogo.png"),
              fit: BoxFit.cover,
            ),
          ),
        );
      }),
    );
  }

  // 마커 선택시 이벤트
  Future<void> onMarkerTabEvent(String uid, bool cameraMove) async {
    Space space = _spaceBox.get(uid)!;

    // 같은 위치에 있는 공간 리스트
    List<Space> selectedSpaces =
        _spaceBox.values.where((s) => _selectedChoices.contains(s.category) && s.latitude == space.latitude && s.longitude == space.longitude).toList();

    // 지도 카메라 이동 - 리스트에서 클릭시에만
    if (cameraMove) {
      await moveMapCamera(space.latitude, space.longitude);
    }

    // 마커 아이콘 변경
    Uint8List markerIconByte = await getBytesFromMarkerIconAsset("assets/images/${SpaceType.getByCode(space.category!).onMarkImg}", 150);

    setState(() {
      for (var s in selectedSpaces) {
        if (markersMap.containsKey(s.uid)) {
          markersMap.update(
            s.uid,
            (value) => value.copyWith(
              iconParam: BitmapDescriptor.fromBytes(markerIconByte),
            ),
          );
        }
      }

      showBottomSheetBtn = false;
    });

    // 공간 상세 모달
    showSpaceBottomSheet(uid, selectedSpaces);
  }

  // 공간 상세 모달
  void showSpaceBottomSheet(String uid, List<Space> selectedSpace) {
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
                                    String lat = thisSpace.latitude.toStringAsFixed(5);
                                    String long = thisSpace.longitude.toStringAsFixed(5);
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
      Space space = _spaceBox.get(uid)!;

      // 마커 아이콘 변경
      Uint8List markerIconByte = await getBytesFromMarkerIconAsset("assets/images/${SpaceType.getByCode(space.category!).offMarkImg}", 100);

      setState(() {
        for (var s in selectedSpace) {
          if (markersMap.containsKey(s.uid)) {
            markersMap.update(
              s.uid,
              (value) => value.copyWith(
                iconParam: BitmapDescriptor.fromBytes(markerIconByte),
              ),
            );
          }
        }
      });
    });
  }

  // 현위치 구하기
  Future<Map<String, String>> getLocationData() async {
    await myLocation.getCurrentLocation();

    return await ReverseGeo.getGuByCoords(myLocation.latitude.toString(), myLocation.longitude.toString());
  }

  // 지도 카메라 이동하기
  Future<void> moveMapCamera(double lat, double long) async {
    await _ct.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, long),
          zoom: 14,
        ),
      ),
    );
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

  // 리스트 페이징 함수
  Future<void> _fetchPage(int pageKey) async {
    try {
      Future.delayed(Duration(milliseconds: pageKey == 0 ? 0 : 500), () {
        int lastIdx = _spaceBox.values.where((s) => _selectedChoices.contains(s.category)).toList().length;

        // 카테고리 필터, 거리순, _pageSize개수 만큼 불러오기
        List<Space> newItems = (_spaceBox.values.where((s) => _selectedChoices.contains(s.category)).toList()..sort(((a, b) => a.dist!.compareTo(b.dist!))))
            .sublist(pageKey, (pageKey + _pageSize < lastIdx ? pageKey + _pageSize : lastIdx));

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

  Future<void> _asyncInitState() async {
    Map<String, String> area = await getLocationData(); // 현위치 구하기

    await getSpacesByGu(area); // 자치구별 공간 데이터 가져오기
    await makeMarkers(); // 마커 만들기
    await moveMapCamera(myLocation.latitude, myLocation.longitude);

    setState(() {
      isLoaded = true;
      myGu = area['gu']!;
    });
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();

    setState(() {
      // 카테고리
      for (var element in categoryList) {
        _selectedChoices.add(element.code);
        categoryVisibility[element.code] = true;
      }
    });
  }

  @override
  void didUpdateWidget(covariant googleMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (WidgetfirstOpen && widget.StatusNumber == 1) {
      setState(() {
        WidgetfirstOpen = false;
      });
      _asyncInitState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    // 모바일 상단 상태 바 높이 값
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SizedBox(
        child: Stack(
          children: [
            // 구글 지도
            GoogleMap(
              mapType: MapType.normal,
              markers: Set.from(markersMap.values),
              initialCameraPosition: position,
              onMapCreated: (GoogleMapController ct) async {
                setState(() {
                  _ct = ct;
                });
                await moveMapCamera(myLocation.latitude, myLocation.longitude);
              },
              onCameraMove: (_) {
                setState(() {
                  showReSearchBtn = true;
                });
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            // 현 동네에서 검색 버튼
            Align(
              alignment: AlignmentDirectional.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () async {
                      if (isLoaded) {
                        setState(() {
                          isLoaded = false;
                        });

                        LatLngBounds visibleRegion = await _ct.getVisibleRegion();
                        LatLng cp = LatLng((visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
                            (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2);

                        String lat = cp.latitude.toStringAsFixed(6);
                        String long = cp.longitude.toStringAsFixed(6);

                        Map<String, String> area = await ReverseGeo.getGuByCoords(lat, long);

                        Future.delayed(const Duration(milliseconds: 0), () async {
                          await getSpacesByGu(area);
                          await makeMarkers();
                          _pagingController.refresh();

                          setState(() {
                            isLoaded = true;
                            showReSearchBtn = false;
                            myGu = area['gu']!;
                          });
                        });

                        if (myGu == '') {
                          const snackBar = SnackBar(content: Text('동네시설을 찾기 위해 위치를 조정해주세요.'));

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
                      setState(() {
                        showReSearchBtn = true;
                      });
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
                                              child: PagedListView<int, Space>(
                                                pagingController: _pagingController,
                                                builderDelegate: PagedChildBuilderDelegate<Space>(
                                                  itemBuilder: ((context, item, index) {
                                                    if (index == 0) {
                                                      return Column(children: [
                                                        BannerAdMob(),
                                                        InkWell(
                                                          onTap: () {
                                                            onMarkerTabEvent(item.uid, true);
                                                          },
                                                          child: makeSpaceWidget(item.uid, false),
                                                        )
                                                      ]);
                                                    } else {
                                                      return InkWell(
                                                        onTap: () {
                                                          onMarkerTabEvent(item.uid, true);
                                                        },
                                                        child: makeSpaceWidget(item.uid, false),
                                                      );
                                                    }
                                                  }),
                                                  firstPageProgressIndicatorBuilder: (_) => const SizedBox(),
                                                ),
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
                                labelStyle: _selectedChoices.contains(choice.code)
                                    ? TextStyle(color: Colors.white, fontSize: Theme.of(context).textTheme.bodySmall?.fontSize)
                                    : TextStyle(color: Colors.grey, fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
                                selectedColor: Color(choice.iconColor),
                                showCheckmark: false,
                                selected: _selectedChoices.contains(choice.code),
                                onSelected: (bool value) {
                                  setState(() {
                                    if (value) {
                                      if (!_selectedChoices.contains(choice.code)) {
                                        _selectedChoices.add(choice.code);
                                        categoryVisibility[choice.code.toString()] = true;
                                      }
                                    } else if (_selectedChoices.length > 1) {
                                      _selectedChoices.removeWhere((String name) {
                                        return name == choice.code;
                                      });
                                      categoryVisibility[choice.code.toString()] = false;
                                    }
                                  });
                                  markerInit();
                                  _pagingController.refresh();
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
                                    width: 15,
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
                                    width: 45,
                                    child: AutoSizeText(
                                      ((myGu) == '') ? '⎯' : myGu,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff4D4D4D),
                                      ),
                                      minFontSize: 12,
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

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
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
                      "nmap://place?lat=${place.latitude}&lng=${place.longitude}&name=${place.spaceName}&zoom=16&appname=com.dongnerang.com.dongnerang"));
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
                  await launchUrl(Uri.parse("kakaomap://look?p=${place.latitude},${place.longitude}"));
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
                await launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}&zoom=12"));
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
