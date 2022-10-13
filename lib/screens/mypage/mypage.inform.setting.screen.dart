import 'package:dongnerang/constants/colors.constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mypage.keyword.setting.screen.dart';
import 'mypage.local.setting.screen.dart';
import 'mypage.profile.setting.screen.dart';

class mypageInformSettingScreen extends StatelessWidget {
  const mypageInformSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,//색변경
          ),
          backgroundColor: AppColors.white,
          centerTitle: true,
          elevation: 0.0,
          title: Text('내 정보 관리', style: TextStyle(color: AppColors.black),),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: Text('프로필 수정'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => mypageProfileSetting(),),);
              },
              trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              title: Text('지역 설정'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => mypageLocalSetting(),),);
              },
              trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              title: Text('관심 키워드 관리'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => mypageKeywordSetting()),);
              },
              trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
          ],
        )
    );
  }
}
