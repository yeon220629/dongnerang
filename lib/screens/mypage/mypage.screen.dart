import 'dart:ui' as ui;
import 'package:dongnerang/constants/common.constants2.dart';
import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:dongnerang/util/admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../widgets/user_profile_image.widget.dart';
import '../notice.main.screen.dart';
import '../setting/notice.main.screen.alarm.dart';
import 'mysite.dart';
import 'settingsPage.screen.dart';
import 'mypage.inform.setting.screen.dart';

class mypageScreen extends StatefulWidget {
  final StatusNumber;
  mypageScreen(this.StatusNumber);

  @override
  State<mypageScreen> createState() => _mypageScreenState();

}

class _mypageScreenState extends State<mypageScreen> {
  late final SlidableController slidableController;
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String? profileImage = '';
  String? userName = '';
  String? delListSting = '';

  late Future<List> userSaveData;
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  List valueBox2 = [];
  List<dynamic> responseListBox = [];

  bool closeTapContainer = false;
  double topContainer = 0;
  int colorindex = 0;
  int groupTagNumber = 0;

  Future<void> getPostsData(value1, value2) async {
    valueBox2 = [];
    listItems = [];
    itemsData = [];
    responseListBox = [];
    List<dynamic> valueData = [];
    List<dynamic> responseList = [];
    List defatulNumber = [];

    var defaultString = 'userSaveData';
    for(int i = 0; i < value2.length; i++){
      valueBox2 = value2[i].toString().split("Data");
      defatulNumber.add(int.parse(valueBox2[1]));
    }
    defatulNumber.sort((a,b) {
      var adate = a; //before -> var adate = a.expiry;
      var bdate = b; //before -> var bdate = b.expiry;
      return bdate.compareTo(adate); //to get the order other way just switch `adate & bdate`
    });
    for(int i = 0; i < defatulNumber.length; i++){
      valueData.add(value1[defaultString+'${defatulNumber[i]}']);
    }

    responseListBox.add(valueData);
    responseList = valueData;
    for(int i = 0; i< responseList.length; i++){
      // 문화재단 pri
      if(responseList[i][1].toString().contains("_")){
        colorindex = 1;
      }else{
        colorindex = 0;
      }

      DateTime dateTime = responseList[i][2].toDate();
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      colorindex = fnSeoulCnterCheck(responseList[i][1]);
      listItems.add( GestureDetector(
          onTap: () async{
            final Uri url = Uri.parse('${responseList[i][0]}');
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
                url, responseList[i][3], responseList[i][1], dateTime, 1
            )));
          },
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: 90,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,8,0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        '${responseList[i][3]}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                        maxLines: 2,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: colorindex == 1
                                      ? Color(0xff5496D2)
                                      : colorindex == 0
                                      ? Color(0xff3CC181)
                                      : colorindex == 2
                                      ? AppColors.darkgreen
                                      : colorindex == 3
                                      ? AppColors.primary
                                      : colorindex == 4
                                      ? AppColors.orange
                                      : colorindex == 5
                                      ? AppColors.red
                                      : Color(0xffEE6D01),
                                ),
                                child: Text(
                                  ' ${responseList[i][1]} ',
                                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                  textDirection: ui.TextDirection.ltr,
                                )
                            ),
                          ),
                          SizedBox(width: 7),
                          Text(
                            // '시작일 | ${responseList[i][2].toString().trim()}',
                            '등록일 | ${dateFormat.format(dateTime)}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                            textDirection: ui.TextDirection.ltr,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
          ))
      );
    }
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    super.initState();

    mypageCustomKeyword = [];
    FirebaseService.getUserLocalData(userEmail!, 'keyword').then((value){
      int ListData = value.length;
      for(int i = 0; i < ListData; i++){
        mypageCustomKeyword.add(value[i]);
      }
    });
    // my page 데이터 적용 진행 중
    userSaveData = FirebaseService.getUserPrivacyProfile(userEmail!);
    userSaveData.then((value){
      setState(() {
        profileImage = value[0]['profileImage'];
        userName = value[0]['name'];
        getPostsData(value[2],value[3]);
      });
    });

    controllers.addListener(() {
      double value = controllers.offset/119;
      setState(() {
        topContainer = value;
        closeTapContainer = controllers.offset > 50;
      });
    });
    // print("chekc : ${commonConstant2().toString()}");
    // 키워드 설정으로 바로 보내기 위한 변수 세팅
    FirebaseService.getUserLocalData(userEmail!, 'keyword').then((value) {
      value.forEach((element) {
        commonConstant2.keywordList.add(element);
      });
    });
    FirebaseService.getUserLocalData(userEmail!, 'local').then((value) {
      value.forEach((element) {
        commonConstant2.localList.add(element);
        commonConstant2.selectLocal.add(element);
      });
      commonConstant2.localList.add('서울시');
    });

    // local exist Check
    FirebaseService.getUserKeyExist(userEmail!).then((value) {
      if(value == true){
        commonConstant2.selectLocal = [];
        FirebaseService.getUserLocalData(userEmail!, 'alramlocal').then((value) {
          value.forEach((element) {
            commonConstant2.selectLocal.add(element);
          });
        });
      }
    });
  }
  @override
  void didUpdateWidget(covariant mypageScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    // 마이페이지 리스트 출력
    if(widget.StatusNumber == 2){
      userSaveData = FirebaseService.getUserPrivacyProfile(userEmail!);
      userSaveData.then((value) {
        getPostsData(value[2],value[3]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () async {
              // final newVersion = NewVersion(
              //   androidId: 'com.dongnerang.com.dongnerang',
              //   iOSId: 'com.dongnerang.com.dongnerang',
              // );
              //
              // final status = await newVersion.getVersionStatus();

              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SettingsPage()),
              );
            },
          )
        ],
        title: Text('마이 페이지', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Column(
          children: <Widget>[
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => mypageInformSettingScreen()));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      child: UserProfileCircleImage(imageUrl: profileImage,),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width/2.3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$userName', style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold,
                                fontSize: 17
                            )),
                            SizedBox(height: 5),
                            Text('프로필 수정', style: TextStyle(
                                fontWeight: FontWeight.w100,
                                color: AppColors.grey,
                                fontSize: 14
                            )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            // padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                            child: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: AppColors.primary,
                              size: 23,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5,),
            SizedBox(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: (){
                          // print(commonConstant2().toString());
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => noticemainAlarmpage(commonConstant2.keywordList, commonConstant2.localList,commonConstant2.selectLocal)));
                              // builder: (_) => noticemainpage()));
                        },
                        child: Column(
                          children: [
                            Image.asset('assets/mypage/keyword.png',
                              width:MediaQuery.of(context).size.width/13),
                            SizedBox(height: 3,),
                            Text(
                              '관심 키워드', style: TextStyle(color: AppColors.black),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => mysite()));
                          //mysite.dart 만들어 놓음, 여기에 지역만 빼서 넣어야함 1.22
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset('assets/mypage/mysite.png',
                                width:MediaQuery.of(context).size.width/13),
                            SizedBox(height: 3,),
                            Text(
                                '나의 지역', style: TextStyle(color: AppColors.black),
                            ),
                          ],
                        ),
                      ),
                    ]
                  ),
                ],
              ),
            ),
            SizedBox(height: 5,),
            Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("  나의 관심목록 (${itemsData.length})", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                )
            ),
            saveDataProfile(itemsData, topContainer, responseListBox, userEmail!,getPostsData),
            //애드몹
            BannerAdMob(),
          ]
      ),
    );
  }
}

class saveDataProfile extends StatefulWidget {
  final itemsData; final topContainer; final responseListBox; final userEmail; final getPostsData;
  saveDataProfile(this.itemsData, this.topContainer, this.responseListBox, this.userEmail,this.getPostsData);

  @override
  State<saveDataProfile> createState() => _saveDataProfileState();
}

class _saveDataProfileState extends State<saveDataProfile> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child : SlidableAutoCloseBehavior(
          closeWhenOpened: true,
          closeWhenTapped: false,
          child: ListView.builder(
            itemCount: widget.itemsData.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (c, i){
              double scale = 1.0;
              if (widget.topContainer > 0.5){
                scale = i + 0.5 - widget.topContainer;
                if (scale < 0 ) { scale = 0;}
                else if (scale > 1) { scale = 1; }
              }
              return Align(
                heightFactor: 1.1,
                alignment: Alignment.topCenter,
                // child: itemsData[i],
                child: Slidable(
                  child: widget.itemsData[i],
                  key: ValueKey(1),
                  groupTag: 0,
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        autoClose: true,
                        onPressed: (value) async {
                          final TextTemplate defaultText = TextTemplate(
                            text:
                            '우리 동네의 모든 공공소식 \'동네랑\'\n\n[${widget.responseListBox[0][i][1]}]\n${widget.responseListBox[0][i][3]}\n\n',
                            link: Link(
                              webUrl: Uri.parse('${widget.responseListBox[0][i][0]}'),
                              mobileWebUrl: Uri.parse('${widget.responseListBox[0][i][0]}'),
                            ),
                          );
                          bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
                          if (isKakaoTalkSharingAvailable) {
                            try{
                              Uri uri =
                              await ShareClient.instance.shareDefault(template: defaultText);
                              await ShareClient.instance.launchKakaoTalk(uri);
                              // EasyLoading.showSuccess("공유 완료");
                            }catch (e){
                              print('카카오톡 공유 실패 $e');
                            }
                          } else {
                            print('카카오톡 미설치: 웹 공유 기능 사용 권장');
                          }
                        },
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        icon: Icons.share,
                        label: '공유',
                      ),
                      SlidableAction(
                        autoClose: true,
                        onPressed: (context){
                          FirebaseService.deleteMypageUserPrivacyData(widget.userEmail!, widget.responseListBox[0][i][3]!,widget.getPostsData);
                        },
                        backgroundColor: AppColors.grey,
                        foregroundColor: AppColors.white,
                        icon: Icons.delete,
                        label: '삭제',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
    );
  }
}


