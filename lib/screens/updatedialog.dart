import 'package:dongnerang/constants/colors.constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'login.screen.dart';
import 'mainScreenBar.dart';

class UpdateDialog extends StatefulWidget {
  final String version;
  final String description;
  late String appLink;
  final bool allowDismissal;

  UpdateDialog({Key? key,
    this.version = " ",
    required this.description,
    required this.appLink,
    required this.allowDismissal
  }) : super(key: key);

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  double screenHeight = 0;
  double screenWidth = 0;
  bool checkPageRout = false;

  @override
  void dispose() {
    if(!widget.allowDismissal) {
      print("EXIT APP");
      // SystemNavigator.pop(); this will close the app
    }
    super.dispose();
  }

  Future<void> checkPermissions() async {
    Future.delayed(const Duration(milliseconds: 1000), () {
      FirebaseAuth.instance.currentUser != null
          ? Get.offAll(() => const mainScreen())
          : Get.offAll(() => const LoginScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastLinearToSlowEaseIn,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: content(context),
      ),
    );
  }

  Widget content(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: screenHeight / 8,
          width: screenWidth / 1.5,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
            color: AppColors.primary,
          ),
          child: const Center(
            child: Icon(
              Icons.error_outline_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        Container(
          height: screenHeight / 3,
          width: screenWidth / 1.5,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "ABOUT UPDATE",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  widget.version,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12,),
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(
                            child: Text(
                              // widget.description,
                              // "문구 테스트"
                              "${widget.version} 버전이 업데이트 되었습니다. \n\n버그 수정 및 앱 안정성이 향상된 최신 버전을 이용하시기 바랍니다."
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        widget.allowDismissal ? Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.pop(context);
                              // setState(() {
                              //   checkPageRout = true;
                              //   if(checkPageRout){
                              //     checkPermissions();
                              //   }
                              // });
                              SystemNavigator.pop();
                            },
                            child: Container(
                              height: 30,
                              width: 120,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primary,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Center(
                                child: Text(
                                  "다음에",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ) : const SizedBox(),
                        SizedBox(width: widget.allowDismissal ? 16 : 0,),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              // String relaceLink = widget.appLink;
                              // if(widget.appLink.contains('&hl=en')){
                              //   relaceLink = widget.appLink.replaceAll('&hl=en', '');
                              // }
                              final appId = Platform.isAndroid ? 'com.dongnerang.com.dongnerang' : '6444590791';
                              final url = Uri.parse(
                                Platform.isAndroid
                                    ? "market://details?id=$appId"
                                    : "https://apps.apple.com/app/id/$appId",
                              );
                              launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                              // await launchUrl(Uri.parse(relaceLink));
                              // await launchUrl(Uri.https("play.google.com", "/store/apps/details", {"id": "com.dongnerang.com.dongnerang"}));
                            },
                            child: Container(
                              height: 30,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColors.primary,
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.primary,
                                    blurRadius: 10,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "업데이트",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}