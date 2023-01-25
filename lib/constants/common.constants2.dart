// 소스 내의 중복 함수 공통으로 정의 dart 파일
class commonConstant2{
  static List CustomKeyword = [];
  static List Privatekeyword = [];
  static List mypageCustomKeyword = [];
  static List mypageCustomlocal = [];
  static List PrivateLocalData = [];
  late Future<List> mypageUserSaveData;
  static List userUpdateData = [];

  static String? profileImage = '';
  static String? userName = '';
  static String? userUpdageName = '';

//키워드 알림 페이지의 키워드 설정 값 데이터 넘김 변수
//알림 키워드 설정으로 보낼 데이터
  static List keywordList = [];
  static List localList = [];
  static List selectLocal = [];

  @override
  String toString() {
    // TODO: implement toString
    return 'keywordList : ${keywordList} \localList : ${localList} \selectLocal : ${selectLocal} ';
  }
}

