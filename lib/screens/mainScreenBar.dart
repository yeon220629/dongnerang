import 'dart:io';

import 'package:dongnerang/screens/google.map.screen.dart';
import 'package:dongnerang/screens/mypage/mypage.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.constants.dart';
import '../controller/HomeController.dart';
import '../controller/NavigationController.dart';
import 'community/community.screen.dart';
import 'mainScreen.dart';
import 'splash.screen.dart';

class mainScreen extends StatefulWidget {
  const mainScreen({Key? key}) : super(key: key);

  @override
  State<mainScreen> createState() => mainScreenState();
}

class mainScreenState extends State<mainScreen>{
  DateTime? currentBackPressTime;
  bool isQuit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(NavigationController());
    Get.put(HomeController());
    final navigationController = Get.find<NavigationController>();
    // if(Platform.isIOS){
    //   return GestureDetector(
    //     onPanUpdate: (details){
    //       if (details.delta.dx > 0) {
    //         DateTime currentTime = DateTime.now();
    //         if(currentBackPressTime == null || currentTime.difference(currentBackPressTime!) > Duration(seconds: 1)){
    //           // print(navigationController.currentBottomMenuIndex.value);
    //           if(navigationController.currentBottomMenuIndex.value != 0){
    //             navigationController.currentBottomMenuIndex.value -= 1;
    //           }
    //         }
    //       }
    //     },
    //     child: CheckPlatform(navigationController),
    //   );
    // }
    return WillPopScope(
      onWillPop: () async {
        DateTime currentTime = DateTime.now();
        if(currentBackPressTime == null || currentTime.difference(currentBackPressTime!) > Duration(seconds: 1)){
          // print(navigationController.currentBottomMenuIndex.value);
          if(navigationController.currentBottomMenuIndex.value != 0){
            navigationController.currentBottomMenuIndex.value -= 1;
            return false;
          }
          currentBackPressTime = currentTime;
          final _msg = '한 번 더 클릭 시 앱이 종료 됩니다.';
          final snackBar = SnackBar(content: Text(_msg));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return false;
        }else{
          return true;
        }
      }, child: CheckPlatform(navigationController),
    );
  }
  Widget CheckPlatform(navigationController){
    return Scaffold(
      bottomNavigationBar: Obx(
              () => Offstage(
            offstage:HomeController.to.hideBottomMenu.value,
              child:
                BottomNavigationBar(
                  // elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.grey,
                  currentIndex: navigationController.currentBottomMenuIndex.value,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(
                        navigationController.currentBottomMenuIndex.value == 0
                            ? CupertinoIcons.doc_text_search
                            : CupertinoIcons.doc_text,
                      ),
                      label: "홈",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        navigationController.currentBottomMenuIndex.value == 1
                            ? CupertinoIcons.map_fill
                            : CupertinoIcons.map,
                      ),
                      label: "동네지도",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        navigationController.currentBottomMenuIndex.value == 2
                            ? CupertinoIcons.chat_bubble_2_fill
                            : CupertinoIcons.chat_bubble_2,
                      ),
                      label: "커뮤니티",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        navigationController.currentBottomMenuIndex.value == 3
                            ? CupertinoIcons.person_fill
                            : CupertinoIcons.person,
                      ),
                      label: "마이페이지",
                    ),
                    // BottomNavigationBarItem(
                    //   icon: Icon(
                    //     navigationController.currentBottomMenuIndex.value == 3
                    //         ? Icons.person
                    //         : Icons.person_outline_outlined,
                    //   ),
                    //   label: "테스트페이지",
                    // ),
                  ],
                  onTap: (index) {
                    if (navigationController.currentBottomMenuIndex.value == 0) {
                      // print("index : $index");
                      // print("navigationController : ${navigationController.currentBottomMenuIndex.value}");
                      var navi = PrimaryScrollController.of(context);
                      navi?.jumpTo(0);
                    }
                    navigationController.currentBottomMenuIndex.value = index;
                    // 마이페이지 리스트 출력
                    if (index == 2) {
                      mypageScreen(navigationController.currentBottomMenuIndex.value);
                      setState(() {});
                    }
                  },
                ),
              ),
              ),
      body: Obx(
              () => IndexedStack(
            index: navigationController.currentBottomMenuIndex.value,
            children: [
              freeComponent_viewpage(),
              googleMapScreen(navigationController.currentBottomMenuIndex.value),
              commnunityMainScreen(navigationController.currentBottomMenuIndex.value),
              mypageScreen(navigationController.currentBottomMenuIndex.value),
              // privateSettingScreen(),
              // LoginScreen(),
              // SplashScreen()
            ],
          )
      ),
    );
  }
}
