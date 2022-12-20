import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class Space {
  late String uid;
  late String spaceName;
  late String? spaceImage; // 공간 사진
  late String address;
  late String markerImage; // 마커 아이콘
  late GeoPoint location;
  late Map<String, dynamic>? detailInfo; // accommInfo(수용인원정보), priceInfo(가격정보), timeInfo(시간정보)
  late String? pageLink;
  // late DocumentReference? reference;

  Space({
    required this.uid,
    required this.spaceName,
    this.spaceImage,
    required this.address,
    required this.markerImage,
    required this.location,
    this.detailInfo,
    this.pageLink,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'spaceName': spaceName,
      'spaceImage': spaceImage,
      'address': address,
      'markerImage': markerImage,
      'location': location,
      'detailInfo': detailInfo,
      'pageLink': pageLink,
    };
  }

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      uid: json['uid'],
      spaceName: json['spaceName'],
      spaceImage: json['spaceImage'],
      address: json['address'],
      markerImage: json['markerImage'],
      location: json['location'],
      detailInfo: json['detailInfo'],
      pageLink: json['pageLink'],
    );
  }

  Space.fromMap(Map<dynamic, dynamic>? map) {
    uid = map?['uid'];
    spaceName = map?['spaceName'];
    spaceImage = map?['spaceImage'];
    address = map?['address'];
    markerImage = map?['markerImage'];
    location = map?['location'];
    detailInfo = map?['detailInfo'];
    pageLink = map?['pageLink'];
  }

  @override
  String toString() {
    return 'Space ==> (uid: $uid, spaceName: $spaceName, spaceImage: $spaceImage, address: $address, markerImage: $markerImage, location: $location, detailInfo: $detailInfo, pageLink: $pageLink)';
  }

/*
  Space.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic> map = document.data() as Map<String, dynamic>;
    uid = map['uid'];
    spaceName = map['spaceName'];
    spaceImage = map['spaceImage'];
    address = map['address'];
    markerImage = map['markerImage'];
    location = map['location'];
    detailInfo = map['detailInfo'];
    maxPeople = map['maxPeople'];
    pageLink = map['pageLink'];
  }
 */
}
