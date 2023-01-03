import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class Space {
  late String uid;
  late String gu;
  late String spaceName;
  late String? spaceImage; // 공간 사진
  late String address;
  late String? category; // 공간 분류 (A: 일반, B: 체육)
  late Map<String, dynamic> location;
  late String? detailInfo; // 상세정보
  late String? pageLink;
  late String? phoneNum;
  late String updated;
  late double? dist; // 현위치와 공간 거리
  late DocumentReference? reference;

  Space({
    required this.uid,
    required this.gu,
    required this.spaceName,
    this.spaceImage,
    required this.address,
    this.category,
    required this.location,
    this.detailInfo,
    this.pageLink,
    this.phoneNum,
    required this.updated,
  });

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
      'updated': updated
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
    );
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
    reference = document.reference;
  }

  @override
  String toString() {
    return 'Space ==> (uid: $uid, spaceName: $spaceName, spaceImage: $spaceImage, address: $address, category: $category, location: $location, detailInfo: $detailInfo, pageLink: $pageLink, phoneNum: $phoneNum)';
  }
}
