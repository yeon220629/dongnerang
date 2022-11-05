import 'package:dongnerang/screens/mypage/mypage.screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.constants.dart';
import '../controller/HomeController.dart';
import '../controller/NavigationController.dart';
import 'mainScreen.dart';
import 'login.screen.dart';

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
    // print(navigationController.currentBottomMenuIndex);
    return Scaffold(
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
                        // BottomNavigationBarItem(
                        //     icon: Icon(
                        //       Icons.login_outlined,
                        //       color:
                        //         navigationController.currentBottomMenuIndex.value == 2
                        //           ? AppColors.primary
                        //           : AppColors.grey,
                        //     ),
                        //     label: "로그인 스크린"
                        // ),
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
              // LoginScreen(),
              // SplashScreen()
            ],
          )
      ),
    );
  }
}
