import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dongnerang/screens/setting/noticepage.screen.dart';
import 'package:dongnerang/screens/setting/notification.screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../constants/colors.constants.dart';
import '../../models/main_view_model.dart';
import '../../services/kakao_login.dart';
import '../../services/user.service.dart';
import '../../widgets/app_appbar_common.widget.dart';
import '../introduce.dart';
import '../setting/inquire.screen.dart';
import '../splash.screen.dart';
import '../../services/firebase.service.dart';

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
            title: Text('알림설정'),
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
                    MaterialPageRoute(builder: (context) => introduceWidget(),),); //Introduce
                },
                trailing:Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading:  Icon(Icons.star_border_outlined),
              title: Text('현재버전 v1.0.0'),
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
                      content: Text("정말 로그아웃 하시겠습니까?"),
                      insetPadding: const  EdgeInsets.fromLTRB(20,40,20,40),
                      actions: [
                        Column(
                          children: [
                            Container(
                              child: TextButton(
                                child: const Text('확인', style: TextStyle(
                                  // background: ,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),),
                                onPressed: () async {
                                  if(Platform.isAndroid){
                                    await viewModel.logout();
                                  }else if(Platform.isIOS){
                                    await viewModel.AppleLogout();
                                  }
                                  Get.offAll(() => const SplashScreen());
                                  UserService.to.currentUser.value = null;
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(
                                          MaterialState.pressed)) {
                                        return AppColors.white;
                                      } else {
                                        return AppColors.primary;
                                      }
                                    }
                                  )
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(width: 0.5, color: AppColors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              width: size.width,
                              height: size.height/ 17.5,
                            ),
                            SizedBox(height: 5,),
                            Container(
                              child: TextButton(
                                child: const Text('취소', style: TextStyle(
                                  fontWeight: FontWeight.bold,
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
                                        return AppColors.primary;
                                      } else {
                                        return AppColors.white;
                                      }
                                    }
                                    )
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(width: 0.5, color: AppColors.grey),
                                borderRadius: BorderRadius.circular(8),
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
          ),
          ListTile(
            leading:  Icon(Icons.no_accounts),
            title: Text('계정탈퇴'),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder:(context) {
                  return AlertDialog(
                    content: Text("정말 계정탈퇴 하시겠습니까?"),
                    insetPadding: const  EdgeInsets.fromLTRB(20,40,20,40),
                    actions: [
                      Column(
                        children: [
                          Container(
                            child: TextButton(
                              child: const Text('확인', style: TextStyle(
                                // background: ,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),),
                              onPressed: () async {
                                FirebaseService.deleteUser(UserService.to.currentUser.value?.email.toString(), UserService.to.currentUser.value?.provider);
                                // if(Platform.isAndroid){
                                // }else if(Platform.isIOS){
                                // }
                                UserService.to.currentUser.value = null;
                                Get.offAll(() => const SplashScreen());
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                    if (states.contains(
                                        MaterialState.pressed)) {
                                      return AppColors.white;
                                    } else {
                                      return AppColors.primary;
                                    }
                                  }
                                  )
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(width: 0.5, color: AppColors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            width: size.width,
                            height: size.height/ 17.5,
                          ),
                          SizedBox(height: 5,),
                          Container(
                            child: TextButton(
                              child: const Text('취소', style: TextStyle(
                                fontWeight: FontWeight.bold,
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
                                      return AppColors.primary;
                                    } else {
                                      return AppColors.white;
                                    }
                                  }
                                  )
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(width: 0.5, color: AppColors.grey),
                              borderRadius: BorderRadius.circular(8),
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
          ),
        ],
      )
    );
  }
}

