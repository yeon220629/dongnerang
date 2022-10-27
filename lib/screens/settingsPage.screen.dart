import 'dart:io';

import 'package:dongnerang/screens/login.screen.dart';
import 'package:dongnerang/screens/setting/introduce.screen.dart';
import 'package:flutter/material.dart';
import 'package:dongnerang/screens/setting/noticepage.screen.dart';
import 'package:dongnerang/screens/setting/notification.screen.dart';
import '../constants/colors.constants.dart';
import '../models/main_view_model.dart';
import '../services/kakao_login.dart';
import '../widgets/app_appbar_common.widget.dart';
import 'introduce.dart';
import 'setting/inquire.screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = MainViewModel(KakaoLogin());
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: fnCommnAppbarWidget(title: '설정',appBar: AppBar()),
      body: ListView(
        children: <Widget>[
     ListTile(
          leading: Icon(Icons.info_outline_rounded),
          title: Text('공지사항'),
          onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoticePage(),),);
            },
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
            leading:  Icon(Icons.notifications_none_outlined),
            title: Text('알림 설정'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen(),),);
              },
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
            leading:  Icon(Icons.mode_comment_outlined),
            title: Text('동네랑 문의'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Inquire(),),);
              },
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: Icon(Icons.perm_device_info),
              title: Text('동네랑 소개'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => introduceWidget(),),);
                },
                trailing:Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading:  Icon(Icons.star_border_outlined),
              title: Text('현재버전 1.1'),
            ),
          ListTile(
            leading:  Icon(Icons.logout),
            title: Text('로그아웃'),
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder:(context) {
                    return AlertDialog(
                      content: Text("로그아웃\n정말 로그아웃 하시겠습니까?"),
                      insetPadding: const  EdgeInsets.fromLTRB(20,40,20, 40),
                      actions: [
                        Column(
                          children: [
                            Container(
                              child: TextButton(
                                child: const Text('확인', style: TextStyle(
                                  color: AppColors.black,
                                ),),
                                onPressed: () async {
                                  await viewModel.logout();
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          LoginScreen()), (route) => false);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(
                                          MaterialState.pressed)) {
                                        return AppColors.skyBlue;
                                      } else {
                                        return AppColors.white;
                                      }
                                    }
                                  )
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              width: size.width,
                              height: size.height/ 17.5,
                            ),
                            SizedBox(height: 5,),
                            Container(
                              child: TextButton(
                                child: const Text('취소', style: TextStyle(
                                  color: AppColors.black,
                                ),),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(
                                          MaterialState.pressed)) {
                                        return AppColors.skyBlue;
                                      } else {
                                        return AppColors.white;
                                      }
                                    }
                                    )
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              width: size.width,
                              height: size.height/ 17.5,
                            ),
                          ],
                        )
                      ],
                    );
                  },
              );
            },
            trailing:Icon(Icons.arrow_forward_ios_outlined),
          ),
        ],
      )
    );
  }
}

