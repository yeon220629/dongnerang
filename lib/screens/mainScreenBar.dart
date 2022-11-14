import 'package:dongnerang/screens/mypage/mypage.screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.constants.dart';
import '../controller/HomeController.dart';
import '../controller/NavigationController.dart';
import 'mainScreen.dart';

class mainScreen extends StatefulWidget {
  const mainScreen({Key? key}) : super(key: key);

  @override
  State<mainScreen> createState() => mainScreenState();
}

class mainScreenState extends State<mainScreen> {
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

    return WillPopScope(
      onWillPop: () async {
        DateTime currentTime = DateTime.now();
        if(currentBackPressTime == null || currentTime.difference(currentBackPressTime!) > Duration(seconds: 2)){
          print(navigationController.currentBottomMenuIndex.value);
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
      },
      child: Scaffold(
        bottomNavigationBar: Obx(
                () => Offstage(
              offstage:HomeController.to.hideBottomMenu.value,
              child: ListView(
                shrinkWrap: true,
                children: [
                  BottomNavigationBar(
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: AppColors.grey,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home,
                          color:
                          navigationController.currentBottomMenuIndex.value == 0
                              ? AppColors.primary
                              : AppColors.grey,
                        ),
                        label: "홈",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.account_circle,
                          color:
                          navigationController.currentBottomMenuIndex.value == 1
                              ? AppColors.primary
                              : AppColors.grey,
                        ),
                        label: "마이페이지",
                      ),
                    ],
                    onTap: (index) {
                      navigationController.currentBottomMenuIndex.value = index;
                      setState(() {});
                    },
                  )
                ],
              ),
            )
        ),
        body: Obx(
              () => IndexedStack(
            index: navigationController.currentBottomMenuIndex.value,
            children: [
              freeComponent_viewpage(),
              mypageScreen(),
              // LoginScreen(),
              // SplashScreen()
            ],
          )
        ),
      ),
    );
  }
}
