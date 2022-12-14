import 'dart:io';

import 'package:dongnerang/screens/mypage/mypage.screen.dart';
import 'package:dongnerang/screens/naver.map.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.constants.dart';
import '../controller/HomeController.dart';
import '../controller/NavigationController.dart';
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
          final _msg = '??? ??? ??? ?????? ??? ?????? ?????? ?????????.';
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
              child: Container(
                decoration: BoxDecoration(border: Border(
                  top: BorderSide( // POINT
                  color: AppColors.greylottie,
                  width: 0.3,
                ),)),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    BottomNavigationBar(
                      elevation: 0,
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
                          label: "???",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            navigationController.currentBottomMenuIndex.value == 1
                                ? CupertinoIcons.map_fill
                                : CupertinoIcons.map,
                          ),
                          label: "????????????",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            navigationController.currentBottomMenuIndex.value == 2
                                ? CupertinoIcons.person_fill
                                : CupertinoIcons.person,
                          ),
                          label: "???????????????",
                        ),
                        // BottomNavigationBarItem(
                        //   icon: Icon(
                        //     navigationController.currentBottomMenuIndex.value == 1
                        //         ? Icons.person
                        //         : Icons.person_outline_outlined,
                        //   ),
                        //   label: "??????????????????",
                        // ),
                      ],
                      onTap: (index) {
                        navigationController.currentBottomMenuIndex.value = index;
                        // ??????????????? ????????? ??????
                        if(index == 2){
                          mypageScreen(navigationController.currentBottomMenuIndex.value);
                          setState(() {});
                        }
                      },
                    )
                  ],
                ),
              ),
          )
      ),
      body: Obx(
              () => IndexedStack(
            index: navigationController.currentBottomMenuIndex.value,
            children: [
              freeComponent_viewpage(),
              naverMapScreen(),
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
