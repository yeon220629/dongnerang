import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'space.model.g.dart';

@HiveType(typeId: 0)
class Space extends HiveObject {
  @HiveField(0)
  late String uid; // 장소 id
  @HiveField(1)
  late String? gu; // 장소 자치구
  @HiveField(2)
  late String spaceName; // 장소명
  @HiveField(3)
  late String? spaceImage; // 장소 이미지
  @HiveField(4)
  late String? address; // 주소
  @HiveField(5)
  late String? category; // 카테고리
  @HiveField(6)
  late double latitude; // 위도
  @HiveField(7)
  late double longitude; // 경도
  @HiveField(8)
  late String? detailInfo; // 상세정보
  @HiveField(9)
  late String? pageLink; // 장소 예약 URL
  @HiveField(10)
  late String? phoneNum; // 번호
  @HiveField(11)
  late double? dist = 0; // 현위치와 공간 거리
  @HiveField(12)
  late String? svcName; // 서비스명
  @HiveField(13)
  late String? svcStat; // 서비스 상태
  @HiveField(14)
  late String? svcTimeMin; // 서비스 이용 시작 시간
  @HiveField(15)
  late String? svcTimeMax; // 서비스 이용 종료 시간
  @HiveField(16)
  late String? payInfo; // 서비스 결제 정보
  @HiveField(17)
  late String? useTarget; // 서비스 이용 대상
  @HiveField(18)
  late String? updated; // 업데이트 일자

  late DocumentReference? reference;

  Space(
      {required this.uid,
      this.gu,
      required this.spaceName,
      this.spaceImage,
      this.address,
      required this.category,
      required this.latitude,
      required this.longitude,
      this.detailInfo,
      this.pageLink,
      this.phoneNum,
      this.svcName,
      this.svcStat,
      this.svcTimeMin,
      this.svcTimeMax,
      this.payInfo,
      this.useTarget,
      this.updated});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'gu': gu,
      'spaceName': spaceName,
      'spaceImage': spaceImage,
      'address': address,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'detailInfo': detailInfo,
      'pageLink': pageLink,
      'phoneNum': phoneNum,
      'svcName': svcName,
      'svcStat': svcStat,
      'svcTimeMin': svcTimeMin,
      'svcTimeMax': svcTimeMax,
      'payInfo': payInfo,
      'useTarget': useTarget,
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
        latitude: json['latitude'],
        longitude: json['longitude'],
        detailInfo: json['detailInfo'],
        pageLink: json['pageLink'],
        phoneNum: json['phoneNum'],
        svcName: json['svcName'],
        svcStat: json['svcStat'],
        svcTimeMin: json['svcTimeMin'],
        svcTimeMax: json['svcTimeMax'],
        payInfo: json['payInfo'],
        useTarget: json['useTarget'],
        updated: json['updated']);
  }

  Space.fromMap(Map<dynamic, dynamic>? map) {
    uid = map?['uid'];
    gu = map?['gu'];
    spaceName = map?['spaceName'];
    spaceImage = map?['spaceImage'];
    address = map?['address'];
    category = map?['category'];
    latitude = map?['latitude'];
    longitude = map?['longitude'];
    detailInfo = map?['detailInfo'];
    pageLink = map?['pageLink'];
    phoneNum = map?['phoneNum'];
    svcName = map?['svcName'];
    svcStat = map?['svcStat'];
    svcTimeMin = map?['svcTimeMin'];
    svcTimeMax = map?['svcTimeMax'];
    payInfo = map?['payInfo'];
    useTarget = map?['useTarget'];
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
    latitude = map['latitude'];
    longitude = map['longitude'];
    detailInfo = map['detailInfo'];
    pageLink = map['pageLink'];
    phoneNum = map['phoneNum'];
    svcName = map['svcName'];
    svcStat = map['svcStat'];
    svcTimeMin = map['svcTimeMin'];
    svcTimeMax = map['svcTimeMax'];
    payInfo = map['payInfo'];
    useTarget = map['useTarget'];
    updated = map['updated'];
    reference = document.reference;
  }

  // 마커 중복 체크 (중복 조건 : 카테고리, 경도, 위도)
  @override
  bool operator ==(Object other) {
    return other is Space && category == other.category && latitude == other.latitude && longitude == other.longitude;
  }

  @override
  String toString() {
    return 'Space ==> (uid: $uid, gu: $gu, category: $category, location: ($latitude, $longitude), spaceName: $spaceName, spaceImage: $spaceImage, detailInfo: $detailInfo, pageLink: $pageLink, phoneNum: $phoneNum)';
  }

  @override
  int get hashCode => Object.hash(category, latitude, longitude);
}
