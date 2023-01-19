import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class Space {
  late String uid;
  late String gu;
  late String spaceName;
  late String? spaceImage; // 공간 사진
  late String? address;
  late String? category; // 공간 분류 (A: 일반, B: 체육)
  late Map<String, dynamic> location;
  late String? detailInfo; // 상세정보
  late String? pageLink;
  late String? phoneNum;
  late String? updated;
  late double? dist = 0; // 현위치와 공간 거리

  // 서울 공공서비스에서만 사용
  late String? svcName;
  late String? svcStat;
  late String? svcTimeMin;
  late String? svcTimeMax;
  late String? payInfo;
  late String? useTarget;

  late DocumentReference? reference;

  Space(
      {required this.uid,
      required this.gu,
      required this.spaceName,
      this.spaceImage,
      this.address,
      required this.category,
      required this.location,
      this.detailInfo,
      this.pageLink,
      this.phoneNum,
      this.updated,
      this.svcName,
      this.svcStat,
      this.svcTimeMin,
      this.svcTimeMax,
      this.payInfo,
      this.useTarget});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'gu': gu,
      'spaceName': spaceName,
      'spaceImage': spaceImage,
      'address': address,
      'category': category,
      'location': location,
      'detailInfo': detailInfo,
      'pageLink': pageLink,
      'phoneNum': phoneNum,
      'updated': updated,
      'svcName': svcName,
      'svcStat': svcStat,
      'svcTimeMin': svcTimeMin,
      'svcTimeMax': svcTimeMax,
      'payInfo': payInfo,
      'useTarget': useTarget
    };
  }

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
        uid: json['uid'],
        gu: json['gu'],
        spaceName: json['spaceName'],
        spaceImage: json['spaceImage'],
        address: json['address'],
        category: json['category'],
        location: json['location'],
        detailInfo: json['detailInfo'],
        pageLink: json['pageLink'],
        phoneNum: json['phoneNum'],
        updated: json['updated'],
        svcName: json['svcName'],
        svcStat: json['svcStat'],
        svcTimeMin: json['svcTimeMin'],
        svcTimeMax: json['svcTimeMax'],
        payInfo: json['payInfo'],
        useTarget: json['useTarget']);
  }

  Space.fromMap(Map<dynamic, dynamic>? map) {
    uid = map?['uid'];
    gu = map?['gu'];
    spaceName = map?['spaceName'];
    spaceImage = map?['spaceImage'];
    address = map?['address'];
    category = map?['category'];
    location = map?['location'];
    detailInfo = map?['detailInfo'];
    pageLink = map?['pageLink'];
    phoneNum = map?['phoneNum'];
    updated = map?['updated'];
    svcName = map?['svcName'];
    svcStat = map?['svcStat'];
    svcTimeMin = map?['svcTimeMin'];
    svcTimeMax = map?['svcTimeMax'];
    payInfo = map?['payInfo'];
    useTarget = map?['useTarget'];
  }

  Space.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic> map = document.data() as Map<String, dynamic>;
    uid = map['uid'];
    gu = map['gu'];
    spaceName = map['spaceName'];
    spaceImage = map['spaceImage'];
    address = map['address'];
    category = map['category'];
    location = map['location'];
    detailInfo = map['detailInfo'];
    pageLink = map['pageLink'];
    phoneNum = map['phoneNum'];
    updated = map['updated'];
    svcName = map['svcName'];
    svcStat = map['svcStat'];
    svcTimeMin = map['svcTimeMin'];
    svcTimeMax = map['svcTimeMax'];
    payInfo = map['payInfo'];
    useTarget = map['useTarget'];
    reference = document.reference;
  }

  // 마커 중복 체크 (중복 조건 : 카테고리, 경도, 위도)
  @override
  bool operator ==(Object other) {
    return other is Space &&
        category == other.category &&
        location['latitude'] == other.location['latitude'] &&
        location['longitude'] == other.location['longitude'];
  }

  @override
  String toString() {
    return 'Space ==> (uid: $uid, gu: $gu, category: $category, location: $location, spaceName: $spaceName, spaceImage: $spaceImage, detailInfo: $detailInfo, pageLink: $pageLink, phoneNum: $phoneNum)';
  }

  @override
  int get hashCode => Object.hash(category, location['latitude'], location['longitude']);
}
