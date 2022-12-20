import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/models/space.model.dart';
import 'package:dongnerang/services/naver.map.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class naverMapScreen extends StatefulWidget {
  const naverMapScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _naverMapScreenState();
}

class _naverMapScreenState extends State<naverMapScreen> {
  double height = 300;
  List<Space> spaces = [];
  List<Marker> markers = [];
  bool isMarkerSelected = false;
  late Marker selectedMarker;

  List<Widget> spacesWidget = [];
  late Widget spaceWidget;
  Widget bottomWidget = Column();

  // firestore에서 자치구 정보 가져가서, spaces 가져오는 메서드
  Future<void> getSpaces(guStr) async {
    DocumentReference<Map<String, dynamic>> spacesRef =
        FirebaseFirestore.instance.collection("spaces").doc(guStr);
    DocumentSnapshot<Map<String, dynamic>> spacesSnapshot =
        await spacesRef.get();
    Map<String, dynamic>? spacesData = spacesSnapshot.data();

    spacesData?.forEach(((key, value) {
      Space s = Space.fromJson(value);
      spaces.add(s);
    }));

    print(spacesData);
    print(spaces);

    List<Widget> a = makeSpacesWidget();
    makeMarkers();

    setState(() {
      bottomWidget = Column(children: a);
    });
  }

  // spaces에서 가져온 것을 markers 리스트로 만들어주는 메서드
  makeMarkers() {
    markers = [];

    spaces.forEach((space) {
      Marker m = Marker(
        markerId: space.uid,
        position: LatLng(space.location.latitude, space.location.longitude),
        // icon: OverlayImage(OverlayImage: ),
        onMarkerTab: (marker, iconSize) {
          print("marker>>>>>");
          // print(marker);
          // print(space);
          // makeSpaceWidget(space);

          setState(() {
            isMarkerSelected = true;
            // spaceWidget = makeSpaceWidget(space);
            bottomWidget = Column(children: [makeSpaceWidget(space)],);
          });
        },
      );

      markers.add(m);
    });
  }

  // markers의 것들을 리스트로 빌드해주는 메서드
  makeSpacesWidget() {
    spacesWidget = []; // 초기화

    spaces.forEach((space) {
      spacesWidget.add(InkWell(
        onTap: () {
          print("object");
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${space.spaceName}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          // Icon(Ico)
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ));
    });

    print("spacesWidget>>>");
    print(spacesWidget);
  }

  // marker 선택 시, 선택 uid 받으면 해당 marker정보 빌드해주는 메서드
  makeSpaceWidget(Space space) {
    print("A space Widget");
    print(space);

    spaceWidget = InkWell(
      onTap: () {
        print("object");
      },
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${space.spaceName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        // Icon(Ico)
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 초기화
  @override
  void initState() {
    getSpaces('영등포구');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    height = MediaQuery.of(context).size.height - 200;

    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: CustomScrollView(
            // floatHeaderSlivers: true,
            // headerSliverBuilder: (context, innerBoxIsScrolled) {
            // return <Widget>[
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                flexibleSpace: Stack(
                  children: [
                    Column(
                      children: [
                        // 네이버 지도
                        Expanded(
                            child: NaverMap(
                          useSurface: kReleaseMode,
                          // initLocationTrackingMode:
                          // widget.mapProvider.trackingMode,
                          // initialCameraPosition: CameraPosition(
                          // target: widget.mapProvider.initLocation,
                          // zoom: 17),
                          locationButtonEnable: true,
                          maxZoom: 17,
                          minZoom: 12,
                          onMapCreated: ((NaverMapController ct) {
                            // _ct = ct;
                          }),
                          markers: markers,
                          scrollGestureEnable: true,
                          zoomGestureEnable: true,
                          tiltGestureEnable: true,
                          rotationGestureEnable: true,
                          forceGesture: true,
                          onMapTap: (cameraLatLng) async {
                            print(cameraLatLng);
                            String lat = cameraLatLng.latitude.toString();
                            String lng = cameraLatLng.longitude.toString();

                            setState(() {
                              isMarkerSelected = false;
                            });
                          },
                        )),
                        // const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
                expandedHeight: height,
                // forceElevated: innerBoxIsScrolled,
                // elevation: 0,
              ),
              // ];
              // },
              // body:
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // return isMarkerSelected
                    //     ? Column(
                    //         children: [spaceWidget],
                    //       )
                    //     : Column(
                    //         children: spacesWidget,
                    //       );
                    return bottomWidget;
                  },
                  childCount: 1,
                ),
              ),
            ],
          ),
        )
      ],
    ));
  }
}
