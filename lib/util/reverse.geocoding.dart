import 'dart:convert';

import 'package:http/http.dart' as http;

class ReverseGeo {
  static String APIKEYID = "ikyjlcscfy";
  static String APIKEY = "4ESm2upE4mgEG5Sff1aBbBwfhYL1Q6ml4h0yoFUT";

  static Map<String, String> headers = {"X-NCP-APIGW-API-KEY-ID": APIKEYID, "X-NCP-APIGW-API-KEY": APIKEY};

  static Future<String> getGuByCoords(String lat, String long) async {
    late http.Response response;
    late Map<String, dynamic> data;

    // https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=127.0518537,37.4770471&output=json
    try {
      Uri apiAddr = Uri.parse("https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=$long,$lat&orders=roadaddr&output=json");
      response = await http.get(apiAddr, headers: headers);
      data = jsonDecode(response.body);

      return data['results'][0]['region']['area2']['name'] ?? '';
    } catch (e) {
      print(e);
      return '';
    }
  }

  static Future<String> getAddrByCoords(String lat, String long) async {
    late http.Response response;
    late Map<String, dynamic> data;

    // https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=127.0518537,37.4770471&output=json
    try {
      Uri apiAddr = Uri.parse("https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=$long,$lat&orders=roadaddr&output=json");
      response = await http.get(apiAddr, headers: headers);
      data = jsonDecode(response.body);
      Map<String, dynamic> roadAddrRegion = data['results'][0]['region'];
      Map<String, dynamic> roadAddrLand = data['results'][0]['land'];
      List<String> addrList = [];

      // 시,도
      String si = roadAddrRegion['area1']['name'] ?? '';
      if (si != '') addrList.add(si);
      // 시,군,구
      String gu = roadAddrRegion['area2']['name'] ?? '';
      if (gu != '') addrList.add(gu);
      // 읍,면,동
      String dong = roadAddrRegion['area3']['name'] ?? '';
      if (dong != '') addrList.add(dong);
      // 리
      String ri = roadAddrRegion['area4']['name'] ?? '';
      if (ri != '') addrList.add(ri);
      // 도로명
      String roadName = roadAddrLand['name'] ?? '';
      if (roadName != '') addrList.add(roadName);
      // 도로명 상세주소
      String roadNumber = roadAddrLand['number1'] ?? '';
      if (roadNumber != '') addrList.add(roadNumber);

      return addrList.join(' ');
    } catch (e) {
      print(e);
      return '';
    }
  }
}

/* response 예시
{
  "status": {
      "code": 0,
      "name": "ok",
      "message": "done"
  },
  "results": [
    {
      "name": "roadaddr",
      "code": {
          "id": "1168010300",
          "type": "L",
          "mappingId": "09680103"
      },
      "region": {
        "area0": {
            "name": "kr",
            "coords": {
                "center": {
                    "crs": "",
                    "x": 0.0,
                    "y": 0.0
                }
            }
        },
        "area1": { // 시, 도
            "name": "서울특별시",
            "coords": {
                "center": {
                    "crs": "EPSG:4326",
                    "x": 126.9783882,
                    "y": 37.5666103
                }
            },
            "alias": "서울"
        },
        "area2": { // 시, 군, 구
            "name": "강남구",
            "coords": {
                "center": {
                    "crs": "EPSG:4326",
                    "x": 127.047502,
                    "y": 37.517305
                }
            }
        },
        "area3": { // 읍, 면, 동
            "name": "개포동",
            "coords": {
                "center": {
                    "crs": "EPSG:4326",
                    "x": 127.055737,
                    "y": 37.4827409
                }
            }
        },
        "area4": { // 리
            "name": "",
            "coords": {
                "center": {
                    "crs": "",
                    "x": 0.0,
                    "y": 0.0
                }
            }
        }
      },
      "land": {
        "type": "",
        "number1": "47", // 상세주소 1
        "number2": "", // 도로명 주소인 경우 reserved
        "addition0": { // 건물정보
            "type": "building",
            "value": "구민체육관" // 건물명
        },
        "addition1": { // 우편번호
            "type": "zipcode",
            "value": "06311"
        },
        "addition2": { // 도로코드
            "type": "roadGroupCode",
            "value": "116804166059"
        },
        "addition3": {
            "type": "",
            "value": ""
        },
        "addition4": {
            "type": "",
            "value": ""
        },
        "name": "개포로28길", // 도로명
        "coords": {
            "center": {
                "crs": "",
                "x": 0.0,
                "y": 0.0
            }
        }
      }
    }
  ]
}
*/
