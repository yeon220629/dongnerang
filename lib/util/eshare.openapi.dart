import 'dart:convert';

import 'package:dongnerang/models/space.model.dart';
import 'package:http/http.dart' as http;

// 공유누리 api
class EshareOpenApi {
  static String apiKey = 'e93e4874eec43b1eb0254c6d861393f1';
  static int limit = 100;
  static List<Space> eshareSpaces = [];

  static Future<List<Space>> getAllEshareApiSpaces(String areaCode) async {
    eshareSpaces = [];

    await getEshareApiSpacesByCate('010500', areaCode);
    await getEshareApiSpacesByCate('010100', areaCode);
    await getEshareApiSpacesByCate('010200', areaCode);
    await getEshareApiSpacesByCate('040000', areaCode);

    // print('esharespaces list >>> ${eshareSpaces.length}');

    return eshareSpaces;
  }

  static Future<void> getEshareApiSpacesByCate(String cateCode, String areaCode) async {
    late http.Response response;
    late Map<String, dynamic> data;
    String category = '';

    switch (cateCode) {
      case '010500': // 체육대관
        category = 'SR';
        break;
      case '010100':
      case '010200': // 시설대관(회의실, 강당)
        category = 'R';
        break;
      case '040000': // 교육
        category = 'E';
        break;
      default:
        return;
    }

    try {
      Uri apiAddr = Uri.parse("https://www.eshare.go.kr/eshare-openapi/rsrc/list/$cateCode/$apiKey");

      var bodyData = {"pageNo": 1, "numOfRows": limit, "sggCd": areaCode, "updBgngYmd": "20201001", "updEndYmd": "20231231"};
      var body = jsonEncode(bodyData);
      // print("$apiAddr >>> $limit, $areaCode");
      
      response = await http.post(apiAddr, headers: {"Content-Type": "application/json"}, body: body);
      data = jsonDecode(response.body);
      // print('openapi data $cateCode $category >>> ${data['data'].length}');
      
      dataRowToSpace(data['data'], category);
    } catch (e) {
      print(e);
    }
  }

  // response 내역 Space 객체로 변환 후 queue에 저장
  static dataRowToSpace(List<dynamic> data, String category) {
    for (var spaceData in data) {
      // 유효성 검사
      if (spaceData['rsrcNo'] == null || spaceData['rsrcNm'] == null || spaceData['lat'] == null || spaceData['lot'] == null) {
        return;
      }

      // 위도, 경도 유효성 검사
      double lat = spaceData['lat'];
      double long = spaceData['lot'];
      if ((lat > 33 && lat < 43) && (long > 124 && long < 132)) {
        lat = double.parse(lat.toStringAsFixed(6));
        long = double.parse(long.toStringAsFixed(6));
      } else {
        return;
      }

      Space space = Space(
        uid: spaceData['rsrcNo'],
        address: spaceData['addr'],
        spaceName: spaceData['rsrcNm'],
        category: category,
        latitude: lat,
        longitude: long,
        spaceImage: spaceData['imgFileUrlAddr'],
        pageLink: spaceData['instUrlAddr'],
      );

      // list에 저장
      eshareSpaces.add(space);
    }
  }
}

/*
{
    "rsrcNo": "DE31K3800449",
    "rsrcNm": "선우체육관",
    "zip": "08866",
    "addr": "서울 관악구 문성로16다길 133-70 (신림동)",
    "daddr": "선우체육관",
    "lot": 126.91261164171,
    "lat": 37.4674327752862,
    "instUrlAddr": "https://www.eshare.go.kr/UserPortal/Upv/UprResrcFacl/index.do?rsrc_no=DE31K3800449",
    "imgFileUrlAddr": "https://www.eshare.go.kr/UserPortal/Upv/109066/fileDetail.do?file_sn=1"
},
*/