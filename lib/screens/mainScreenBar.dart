import 'package:dongnerang/screens/private.setting.screen.dart';
import 'package:dongnerang/screens/search.screen.dart';
import 'package:dongnerang/screens/splash.screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.constants.dart';
import '../controller/HomeController.dart';
import '../controller/NavigationController.dart';
import 'mainScreen.dart';
import 'intro.screen.dart';
import 'login.screen.dart';
import 'mypage.screen.dart';

class mainScreen extends StatefulWidget {
  const mainScreen({Key? key}) : super(key: key);

  @override
  State<mainScreen> createState() => mainScreenState();
}

class mainScreenState extends State<mainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(NavigationController());
    Get.put(HomeController());
    final navigationController = Get.find<NavigationController>();
    print(navigationController.currentBottomMenuIndex);
    return Scaffold(
      bottomNavigationBar: Obx(
              () => Offstage(
                offstage:HomeController.to.hideBottomMenu.value,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    BottomNavigationBar(
                      showUnselectedLabels: true,
                      showSelectedLabels: true,
                      // selectedLabelStyle: const TextStyle(color: Colors.red),
                      selectedItemColor: AppColors.primary,
                      unselectedItemColor: AppColors.grey,
                      // currentIndex: _selectedIndex,
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
                          label: "마이페이지"
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(
                              Icons.ac_unit,
                              color:
                                navigationController.currentBottomMenuIndex.value == 2
                                  ? AppColors.primary
                                  : AppColors.grey,
                            ),
                            label: "로그인 스크린"
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(
                              Icons.ac_unit,
                              color:
                                navigationController.currentBottomMenuIndex.value == 3
                                  ? AppColors.primary
                                  : AppColors.grey,
                            ),
                            label: "세팅 스크린"
                        ),
                      ],
                      onTap: (index) {
                        // print(index);
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
              // privateSettingScreen(),
              LoginScreen(),
              // SplashScreen()
            ],
          )
      ),
    );
  }
}
