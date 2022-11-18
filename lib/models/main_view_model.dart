import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/setting/private.setting.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao ;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../screens/intro.screen.dart';
import '../screens/login.screen.dart';
import '../screens/mainScreenBar.dart';
import '../services/firebase.service.dart';
import '../services/social_login.dart';
import '../services/user.service.dart';

class MainViewModel {
  final SocialLogin _socialLogin;
  MainViewModel(this._socialLogin);
  bool isLogined = false;
  kakao.User? user;

  Future login() async {
    bool isInstalled = await isKakaoTalkInstalled();
    if (await AuthApi.instance.hasToken()) {
      try {
        print("token 있음");
        if(isInstalled){
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          print('로그인 성공 ${token.accessToken}');
          Get.offAll(IntroScreen());
        }else{
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('로그인 성공 ${token.accessToken}');
          Get.offAll(IntroScreen());
        }
        user = await kakao.UserApi.instance.me();
        final customToken = await FirebaseService().createCustomToken({
          'uid': user!.id.toString(),
          'displayName': user!.kakaoAccount?.profile?.nickname,
          'email': user!.kakaoAccount!.email!,
          'photoURL' : user?.kakaoAccount?.profile?.isDefaultImage == null
                        ? null
                        : user?.kakaoAccount?.profile?.profileImageUrl,
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
          currentUser = await FirebaseService.findUserByEmail(user!.kakaoAccount!.email!);
          if (currentUser == null) {
            EasyLoading.showError("회원가입 진행 필요");
            Get.offAll(() => privateSettingScreen());
          }
        }
        UserService.to.currentUser.value = currentUser;
        Get.offAll(() => mainScreen());
      } catch (error) {
        print('로그인 실패 $error');
        Get.offAll(() => LoginScreen());
      }
  } else {
      try {
        print("token 없음");
        if(isInstalled){
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          print('로그인 성공 ${token.accessToken}');
          Get.offAll(IntroScreen());
        }else{
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('로그인 성공 ${token.accessToken}');
          Get.offAll(IntroScreen());
        }

        user = await kakao.UserApi.instance.me();
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
          await FirebaseAuth.instance.signInWithCustomToken(customToken);
          EasyLoading.showInfo("회원가입 진행 필요");
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
          currentUser = await FirebaseService.findUserByEmail(user!.kakaoAccount!.email!);

          Get.offAll(() => privateSettingScreen());
        }else{
          // EasyLoading.showInfo("현재 사용자가 있습니다");
          UserService.to.currentUser.value = currentUser;
          Get.offAll(() => mainScreen());
        }
      } catch (error) {
        print('로그인 실패 $error');
        Get.offAll(() => LoginScreen());
      }
    }
  }
  Future logout() async {
    await UserApi.instance.unlink();
    FirebaseAuth.instance.signOut();
    UserApi.instance.logout();
  }
}
