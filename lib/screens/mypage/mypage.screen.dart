import 'dart:io';
import 'dart:ui' as ui;

import 'package:dongnerang/screens/mainScreenBar.dart';
import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../widgets/user_profile_image.widget.dart';
import 'settingsPage.screen.dart';
import 'mypage.inform.setting.screen.dart';

class mypageScreen extends StatefulWidget {
  const mypageScreen({Key? key}) : super(key: key);
  @override
  State<mypageScreen> createState() => _mypageScreenState();

}

class _mypageScreenState extends State<mypageScreen> {
  //애드몹 테스트 ID
  final String iOSTestId = 'ca-app-pub-3940256099942544/2934735716';
  final String androidTestId = 'ca-app-pub-3940256099942544/6300978111';

  //애드몹 ID ca-app-pub-3415104781631988/9379594822
  // final String androidRealId = 'ca-app-pub-3415104781631988/9379594822';


  BannerAd? banner;

  late final SlidableController slidableController;
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String? profileImage = '';
  String? userName = '';
  String? delListSting = '';

  late Future<List> userSaveData;
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  List valueBox = [];

  bool closeTapContainer = false;
  double topContainer = 0;
  int reloadindex = 0;
  int colorindex = 0;
  int groupTagNumber = 0;

  Future<void> getPostsData(value) async {
    valueBox.add(value);
    listItems = [];
    List<dynamic> valueData = [];
    List<dynamic> responseList = [];

    valueBox.forEach((element) {
      valueData.add(value);
    });
    responseList = valueData;
    for(int i = 0; i< responseList[0].length; i++){
      // 문화재단 pri
      if(responseList[0][i][1].toString().contains("_")){
        colorindex = 1;
      }else{
        colorindex = 0;
      }

      DateTime dateTime = responseList[0][i][2].toDate();
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      colorindex = fnCnterCheck(responseList[0][i][1]);
      listItems.add( GestureDetector(
          onTap: () async{
            final Uri url = Uri.parse('${responseList[0][i][0]}');
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
                url, responseList[0][i][3], responseList[0][i][1], dateTime, 1
            )));
          },
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: 90,
              // decoration: BoxDecoration(
              //   border: Border.all(width: 1)
              // ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                child: Slidable(
                  groupTag: 0,
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        autoClose: true,
                        onPressed: (value) async {
                          final TextTemplate defaultText = TextTemplate(
                            text:
                            '우리 동네의 모든 공공소식 \'동네랑\'\n\n[${responseList[0][i][1]}]\n${responseList[0][i][3]}\n\n',
                            link: Link(
                              webUrl: Uri.parse('${responseList[0][i][0]}'),
                              mobileWebUrl: Uri.parse('${responseList[0][i][0]}'),
                            ),
                          );
                          bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
                          if (isKakaoTalkSharingAvailable) {
                            print('카카오톡으로 공유 가능');
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
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        icon: Icons.share,
                        label: '공유',
                      ),
                      SlidableAction(
                        autoClose: true,
                        onPressed: (value){
                          delPostsData(responseList[0][i][3],context);
                        },
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        icon: Icons.delete,
                        label: '삭제',
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,8,0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${responseList[0][i][3]}',
                          style: const TextStyle(fontSize: 14),
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
                                        : AppColors.black,
                                  ),
                                  child: Text(
                                    ' ${responseList[0][i][1]} ',
                                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                    textDirection: ui.TextDirection.ltr,
                                  )
                              ),
                            ),
                            SizedBox(width: 7),
                            Text(
                              // '시작일 | ${responseList[0][i][2].toString().trim()}',
                              '시작일 | ${dateFormat.format(dateTime)}',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                              textDirection: ui.TextDirection.ltr,
                            ),
                          ],
                        )
                      ],
                    ),
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

  Future<void> delPostsData(value, BuildContext context) async {
    setState(() {
      FirebaseService.deleteMypageUserPrivacyData(userEmail!, value!, context);
    });
  }

  @override
  void initState() {
    super.initState();

    //애드몹
    banner = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: Platform.isIOS ? iOSTestId : androidTestId,
      listener: BannerAdListener(),
      request: AdRequest(),
    )..load();

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
        value[0]?.forEach((element) {
          if(element.toString().contains('/')){
            profileImage = element.toString();
          }else{
            userName = element.toString();
          }
        });
        getPostsData(value[1]);
      });
    });

    controllers.addListener(() {
      double value = controllers.offset/119;

      setState(() {
        topContainer = value;
        closeTapContainer = controllers.offset > 50;
      });
    });

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
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SettingsPage())
              );
            },
          )
        ],
        title: Text('내 정보 관리', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body:

      Column(
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
                            // child: Text("프로필 수정", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: AppColors.grey,),
                            // ),
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
                ),),),
            // SizedBox(height: 5,),
            Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("나의 관심목록 (${itemsData.length})", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                )
            ),
            saveDataProfile(itemsData, topContainer),
            Container(height: 60,
            width: size.width,
            child: this.banner == null
                ? Container()
                : AdWidget(
                    ad: this.banner!,
            ),),
          ]
      ),
    );
  }
}

Widget saveDataProfile(List itemsData, topContainer) {
  return Expanded(
    child : SlidableAutoCloseBehavior(
      closeWhenOpened: true,
      closeWhenTapped: false,
      child: ListView.builder(
        itemCount: itemsData.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (c, i){
          double scale = 1.0;
          if (topContainer > 0.5){
            scale = i + 0.5 - topContainer;
            if (scale < 0 ) { scale = 0;}
            else if (scale > 1) { scale = 1; }
          }
          return Align(
            heightFactor: 1.1,
            alignment: Alignment.topCenter,
            child: itemsData[i],
          );
        },
        // separatorBuilder: (BuildContext ctx, int idx) {
        //   return Divider();
        // },
      ),
    )
  );
}


// final BannerAd myBanner = BannerAd(
//   adUnitId: 'ca-app-pub-3940256099942544/6300978111',
//   size: AdSize.banner,
//   request: AdRequest(),
//   listener: BannerAdListener(),
// );

// final AdWidget adWidget = AdWidget(ad: myBanner);
//
// final Container adContainer = Container(
//   alignment: Alignment.center,
//   child: adWidget,
//   width: myBanner.size.width.toDouble(),
//   height: myBanner.size.height.toDouble(),
// );

// myBanner.load();

// final String iOSTestId = 'ca-app-pub-3940256099942544/2934735716';
// final String androidTestId = 'ca-app-pub-3940256099942544/6300978111';
//

