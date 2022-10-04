import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/mainScreen.dart';
import 'package:dongnerang/screens/private.setting.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao ;
import '../services/firebase.service.dart';
import '../services/social_login.dart';
import '../services/user.service.dart';

class MainViewModel {
  final SocialLogin _socialLogin;
  bool isLogined = false;
  kakao.User? user;

  MainViewModel(this._socialLogin);

  Future login() async {
    isLogined = await _socialLogin.login();
    print("isLogined : $isLogined");
    if(isLogined) {
      user = await kakao.UserApi.instance.me();
      print("user : ${user!.kakaoAccount!.birthday}");

      final customToken = await FirebaseService().createCustomToken({
        'uid': user!.id.toString(),
        'displayName': user!.kakaoAccount?.profile?.nickname,
        'email': user!.kakaoAccount!.email!,
        'photoURL': user!.kakaoAccount!.profile!.profileImageUrl,
      });
      await FirebaseAuth.instance.signInWithCustomToken(customToken);

      var currentUser = await FirebaseService.findUserByEmail(
          user!.kakaoAccount!.email!);
      if (currentUser == null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.kakaoAccount!.email!)
            .set({
          "email": user!.kakaoAccount!.email!,
          "provider": "kakao",
          "createdAt": DateTime.now(),
          "loggedAt": DateTime.now(),
          "name": user!.kakaoAccount!.profile!.nickname,
          "profileImage": user!.kakaoAccount!.profile!.profileImageUrl,
        });
        currentUser =
        await FirebaseService.findUserByEmail(user!.kakaoAccount!.email!);
        if (currentUser == null) {
          EasyLoading.showError("회원가입 진행 필요");
        }
      }
      UserService.to.currentUser.value = currentUser;
      Get.offAll(() => privateSettingScreen());
    }
    Future logout() async {
      await _socialLogin.logout();
      isLogined = false;
      user = null;
    }
  }
}
