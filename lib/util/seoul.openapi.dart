import 'dart:convert';

import 'package:dongnerang/constants/common.constants.dart';
import 'package:dongnerang/models/space.model.dart';
import 'package:http/http.dart' as http;

class SeoulOpenApi {
  static String apiKey = "4b6e71576773647737344a616f444f";
  static int limit = 500;

  // 서울 공공서비스 api 데이터 queue에 저장
  static getOpenApiSeoulSpaces(String service) async {
    late http.Response response;
    late Map<String, dynamic> data;
    String category = '';
    switch (service) {
      case 'ListPublicReservationSport': // 체육대관
        category = 'sportsRental';
        break;
      case 'ListPublicReservationCulture': // 문화체험
        category = 'culture';
        break;
      case 'ListPublicReservationEducation': // 교육
        category = 'edu';
        break;
      case 'ListPublicReservationInstitution': // 시설대관
        category = 'rental';
        break;
      default:
        return;
    }

    try {
      Uri apiAddr = Uri.parse(
          "http://openAPI.seoul.go.kr:8088/$apiKey/json/$service/1/$limit/");
      response = await http.get(apiAddr);
      data = jsonDecode(response.body);

      int listTotalCount = data[service]['list_total_count'];
      if (listTotalCount == 0) {
        return;
      }
      int repeat = (listTotalCount / limit).ceil();

      // 처음 100개 이하는 여기서 처리
      dataRowToSpace(data, service, category);

      print("listTotalCount : $listTotalCount");

      // 100개 초과일 경우 반복 처리
      for (int i = 0; i < repeat - 1; i++) {
        try {
          Uri apiAddr = Uri.parse(
              "http://openAPI.seoul.go.kr:8088/$apiKey/json/$service/${100 * (i + 1) + 1}/${100 * (i + 2)}/");
          response = await http.get(apiAddr);
          data = jsonDecode(response.body);

          print("apiAddr >>>> $apiAddr");

          dataRowToSpace(data, service, category);
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      print(e);
    }

    // return data1;
  }

  // response 내역 Space 객체로 변환 후 queue에 저장
  static dataRowToSpace(
      Map<String, dynamic> data, String service, String category) {
    data[service]['row'].forEach((spaceData) {
      if (spaceData['SVCID'] == "" ||
          spaceData['AREANM'] == "" ||
          spaceData['PLACENM'] == "" ||
          spaceData['X'] == "" ||
          spaceData['Y'] == "") {
        return;
      }

      Space space = Space(
          uid: spaceData['SVCID'],
          gu: spaceData['AREANM'],
          spaceName: spaceData['PLACENM'],
          category: category,
          location: {
            'latitude': double.parse(spaceData['Y']),
            'longitude': double.parse(spaceData['X'])
          },
          spaceImage: spaceData['IMGURL'],
          detailInfo: spaceData['MAXCLASSNM'],
          pageLink: spaceData['SVCURL'],
          phoneNum: spaceData['TELNO'],
          svcName: spaceData['SVCNM'],
          svcStat: spaceData['SVCSTATNM'],
          svcTimeMin: spaceData['V_MIN'],
          svcTimeMax: spaceData['V_MAX'],
          payInfo: spaceData['PAYATNM'],
          useTarget: spaceData['USETGTINFO']);

      // queue에 저장
      SpacesQueue.add(space);
    });
  }
}

/* spaceData 예시
{
  "GUBUN": "자체",
  "SVCID": "S221108170805291184",
  "MAXCLASSNM": "체육시설",
  "MINCLASSNM": "다목적경기장",
  "SVCSTATNM": "접수중",
  "SVCNM": "다목적구장 - 응봉공원(2023년)",
  "PAYATNM": "무료",
  "PLACENM": "응봉공원",
  "USETGTINFO": " 제한없음",
  "SVCURL": "https://yeyak.seoul.go.kr/web/reservation/selectReservView.do?rsv_svc_id=S221108170805291184",
  "X": "127.02182026085195",
  "Y": "37.5569473910838",
  "SVCOPNBGNDT": "2022-12-01 00:00:00.0",
  "SVCOPNENDDT": "2023-12-31 00:00:00.0",
  "RCPTBGNDT": "2022-12-01 09:00:00.0",
  "RCPTENDDT": "2023-12-31 04:12:00.0",
  "AREANM": "성동구",
  "IMGURL": "https://yeyak.seoul.go.kr/web/common/file/FileDown.do?file_id=1667894998350BZ6XKFG3IPSTZJ5HHN7V0CEP3",
  "DTLCONT": "<p>1. 공공시설 예약서비스 이용시 필수 준수사항</p><p>모든 서비스의 이용은 담당 기관의 규정에 따릅니다. 각 시설의 규정 및 허가조건을 반드시 준수하여야 합니다.</p><p>각 관리기관의 시설물과 부대시설을 이용함에 있어 담당자들과 협의 후 사용합니다.</p><p>각 관리기관의 사고 발생시 서울시청에서는 어떠한 책임도 지지않습니다.</p><p>시설이용료 납부는 각 관리기관에서 규정에 준 합니다.</p><p>본 사이트와 각 관리기관의 규정을 위반할시에는 시설이용 취소 및 시설이용 불허의 조치를 취할 수 있습니다.</p><p>접수시간을 기준으로 브라우저에서 새로고침을 하면 변경된 정보를 볼 수 있습니다.</p><p>2. 시설예약</p><p>비회원일 경우에는 실명 확인을 통하여 사용하실 수 있으며 서울시 통합 회원에 가입 하시게 되면 서울시에서 제공하는 다양하고 많은 혜택을 받으실 수 있습니다.</p><p>3. 상세내용</p><p><strong><span style=\"color: rgb(0, 240, 0);\">* 당일 예약시 최대 4시간까지 이용가능합니다*</span></strong></p>\r\n\r\n<p>ㅇ 다목적구장 개요<br />\r\n- 규 격: 38m*20m<br />\r\n- 바 닥 면:인조잔디구장<br />\r\nㅇ 개방시간: 3~10월 07:00~19:00</p>\r\n\r\n<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;11~2월 08:00~17:00</p>\r\n\r\n<p>(일일 신청시 최대 사용가능시간 4시간)<br />\r\nㅇ 사 용 료:무료<br />\r\nㅇ 예약가능시기:이용일로부터 30일전~이용예정 1일전까지.<br />\r\nㅇ 인근에 주택가가 연접해 있는 만큼 소음 인한 민원이 발생되지 않도록 주의하여 주시기 바랍니다(음향시설 사용금지)<br />\r\n<br />\r\n*응봉공원 다목적구장의 독점사용으로 인한 불편사항을 해소하고자 부득이 인터넷 예약시스템을 다음과같이 시행할 예정입니다.<br />\r\n-사용시간 : 1회당 최대 4시간<br />\r\n-동일인이 일주일에 2회 이상 예약불가<br />\r\n※ 본 구장은 야구를 금합니다.<br />\r\n※ 골프 연습을 금합니다.<br />\r\n<br />\r\n&nbsp;</p>\r\n<p>4. 주의사항</p><p><span style=\"color: rgb(255, 0, 0);\"><strong>※ 체육시설 오픈시간</strong></span></p>\r\n\r\n<p><span style=\"color: rgb(255, 0, 0);\"><strong>&nbsp;&nbsp;&nbsp; 3~10월 07:00 ~ 19:00</strong></span></p>\r\n\r\n<p><span style=\"color: rgb(255, 0, 0);\"><strong>&nbsp; &nbsp; 11~2월 08:00 ~ 17:00</strong></span></p>\r\n",
  "TELNO": "02-2293-7646",
  "V_MIN": "07:00",
  "V_MAX": "19:00",
  "REVSTDDAYNM": "이용일",
  "REVSTDDAY": "1"
},
*/