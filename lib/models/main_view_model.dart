import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao ;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../services/firebase.service.dart';
import '../services/social_login.dart';

class MainViewModel {
  final SocialLogin _socialLogin;
  bool isLogined = false;
  kakao.User? user;

  MainViewModel(this._socialLogin);

  Future login() async {
    isLogined = await _socialLogin.login();
    if(isLogined){
      user = await kakao.UserApi.instance.me();
      final customToken = await FirebaseService().createCustomToken({
        'uid' : user!.id.toString(),
        'displayName' : user!.kakaoAccount?.profile?.nickname,
        'email' : user!.kakaoAccount!.email!,
        'photoURL' : user!.kakaoAccount!.profile!.profileImageUrl,
      });
      print("this is a customToken : , $customToken");
      await FirebaseAuth.instance.signInWithCustomToken(customToken);

    }
    Future logout() async {
      await _socialLogin.logout();
      isLogined = false;
      user = null;
    }
  }
}