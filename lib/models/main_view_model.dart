import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/setting/private.setting.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao ;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../screens/login.screen.dart';
import '../screens/mainScreenBar.dart';
import '../services/firebase.service.dart';
import '../services/social_login.dart';
import '../services/user.service.dart';

class MainViewModel {
  final SocialLogin _socialLogin;
  bool isLogined = false;
  kakao.User? user;

  MainViewModel(this._socialLogin);

  Future login() async {
    // await _socialLogin.login();
    bool isInstalled = await isKakaoTalkInstalled();
    OAuthToken token;
    if (await AuthApi.instance.hasToken()) {
        // try {
        //   AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        //   print('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
        //   Get.offAll(() => mainScreen());
        //   // Get.offAll(() => privateSettingScreen());
        // } catch (error) {
        //   if (error is KakaoException && error.isInvalidTokenError()) {
        //     print('토큰 만료 $error');
        //   } else {
        //     print('토큰 정보 조회 실패 $error');
        //   }
        // }
      try {
        // 카카오 계정으로 로그인
        if(isInstalled){
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          print('로그인 성공 ${token.accessToken}');
        }else{
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('로그인 성공 ${token.accessToken}');
        }
        // OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        // print('로그인 성공 ${token.accessToken}');

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
        print("currentUser : $currentUser");
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
      print('발급된 토큰 없음');
      try {
        if(isInstalled){
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          print('로그인 성공 ${token.accessToken}');
        }else{
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('로그인 성공 ${token.accessToken}');
        }
        // OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        // print('로그인 성공 ${token.accessToken}');
        // AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        // print("tokenInfo : $tokenInfo");
        // UserApi.instance.loginWithKakaoAccount();

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
        print("currentUserlogin : $currentUser");
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
          print("UserService.to.currentUser.value : ${UserService.to.currentUser.value}");
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
