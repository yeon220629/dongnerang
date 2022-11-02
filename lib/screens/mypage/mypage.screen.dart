import 'dart:math';
import 'dart:ui' as ui;

import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../widgets/user_profile_image.widget.dart';
import '../setting/introduce.screen.dart';
import 'settingsPage.screen.dart';
import 'mypage.inform.setting.screen.dart';

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
  List valueBox = [];
  List slideSendBox = [];

  bool closeTapContainer = false;
  double topContainer = 0;
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
    for(int i = 0; i< responseList[0].length; i++){
      // 문화재단 pri
      if(responseList[0][i][1].toString().contains("_")){
        colorindex = 1;
      }else{
        colorindex = 0;
      }

      DateTime dateTime = responseList[0][i][2].toDate();
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");

      listItems.add( GestureDetector(
          onTap: () async{
            final Uri url = Uri.parse('${responseList[0][i][0]}');
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
                url, responseList[0][i][3], responseList[0][i][1], dateTime, 1
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
                child: Slidable(
                  // Specify a key if the Slidable is dismissible.
                  key: UniqueKey(),

                  // The start action pane is the one at the left or the top side.
                  startActionPane: ActionPane(
                    // A motion is a widget used to control how the pane animates.
                    motion: const ScrollMotion(),

                    // A pane can dismiss the Slidable.
                    dismissible: DismissiblePane(onDismissed: () {}),

                    // All actions are defined in the children parameter.
                    children: const [
                      // A SlidableAction can have an icon and/or a label.
                      SlidableAction(
                        onPressed: doNothing,
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        icon: Icons.share,
                        label: '공유',
                      ),
                    ],
                  ),

                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: const ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: doNothing,
                        backgroundColor: AppColors.grey,
                        foregroundColor: AppColors.black,
                        icon: Icons.delete,
                        label: '삭제',
                      ),
                    ],
                  ),

                  // The child of the Slidable is what the user sees when the
                  // component is not dragged.
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
                                textDirection: ui.TextDirection.ltr,
                              )
                          ),
                          SizedBox(width: 8),
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
      // print("userSaveData 1 :  ${value[1]}");
      slideSendBox.add(value);
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
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => mypageInformSettingScreen()));

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
                  padding: EdgeInsets.all(10),
                  child: Text("나의 관심목록 (${itemsData.length})", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                )
            ),
            saveDataProfile(itemsData, topContainer, slideSendBox)
          ]
      ),
    );
  }
}

Widget saveDataProfile(List itemsData, topContainer, userSaveData) {
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

