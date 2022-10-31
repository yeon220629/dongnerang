import 'dart:math';

import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../widgets/user_profile_image.widget.dart';
import 'settingsPage.screen.dart';
import 'mypage.inform.setting.screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class mypageScreen extends StatefulWidget {
  const mypageScreen({Key? key}) : super(key: key);
  @override
  State<mypageScreen> createState() => _mypageScreenState();

}

class _mypageScreenState extends State<mypageScreen> {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String? profileImage = '';
  String? userName = '';
  late Future<List> userSaveData;
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  final _random = Random();
  bool closeTapContainer = false;
  double topContainer = 0;
  List valueBox = [];
  int colorindex = 0;


  Future<void> getPostsData(value) async {
    valueBox.add(value);
    listItems = [];
    List<dynamic> valueData = [];
    List<dynamic> responseList = [];

    valueBox.forEach((element) {
        valueData.add(value);
    });

    responseList = valueData;
    // print(responseList[0].length);
    for(int i = 0; i< responseList[0].length; i++){
      // print("$i 번호 : ${responseList[0][i]}");
      // 문화재단 pri
      if(responseList[0][i][1].toString().contains("_")){
        colorindex = 1;
      }else{
        colorindex = 0;
      }
      listItems.add( GestureDetector(
          onTap: () async{
            final Uri url = Uri.parse('${responseList[0][i][0]}');
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
                url, responseList[0][i][3], responseList[0][i][1], responseList[0][i][2], 1
            )));
          },
          child: Container(
              width: 500,
              height: 110,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), //모서리를 둥글게
                  border: Border.all(color: Colors.black12, width: 1)), //테두리
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
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
                        Container(
                            padding: EdgeInsets.all(3),
                            color: colorindex == 1
                                ? AppColors.blue
                                : AppColors.green,
                            child: Text(
                              '${responseList[0][i][1]}',
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                              textDirection: TextDirection.ltr,
                            )
                        ),
                        SizedBox(width: 8),
                        Text(
                          '시작일 | ${responseList[0][i][2].toString().trim()}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    )
                  ],
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
    print("새로고침 테스트");
    // my page 데이터 적용 진행 중
    userSaveData = FirebaseService.getUserPrivacyProfile(userEmail!);
    userSaveData.then((value){
      // print("userSaveData 1 :  ${value[1]}");
      setState(() {
        value[0]?.forEach((element) {
          print(element);
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
                mypageCustomKeyword = [];
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => mypageInformSettingScreen()));
                FirebaseService.getUserLocalData(userEmail!, 'keyword').then((value){
                  int ListData = value.length;
                  for(int i = 0; i < ListData; i++){
                    mypageCustomKeyword.add(value[i]);
                  }
                });
              },
              child:
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                    child: UserProfileCircleImage(imageUrl: profileImage,),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${userName}', style: TextStyle(
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
                    SizedBox(width: 80,),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      child: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: AppColors.primary,
                        size: 23,
                      ),
                    ),
                  ],
                ),
                // SizedBox(width: 80),
              ],
            ),),),
            // SizedBox(height: 5,),
            Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text("나의 관심목록 (${itemsData.length})", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                )
            ),
            saveDataProfile(itemsData, topContainer),
          ]
        ),
    );
  }
}

Widget saveDataProfile(List itemsData, topContainer) {
  return Expanded(
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
            return Opacity(
              opacity: scale,
              child: Transform(
                transform: Matrix4.identity()..scale(scale, scale),
                alignment: Alignment.bottomCenter,
                child: Align(
                  heightFactor: 0.95,
                  alignment: Alignment.topCenter,
                  child: itemsData[i],
                ),
              ),
            );
          }
      )
  );
}