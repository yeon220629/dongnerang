import 'package:geolocator/geolocator.dart';

class Location {
  // 기본 설정 : 상도 창업지원센터
  // double latitude = 37.50475398269641;
  // double longitude = 126.95395829730329;
  late double latitude;
  late double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    print("Location Class >>> permission ::: $permission");

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print(e);
    }
  }
}
