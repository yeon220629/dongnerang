import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import '../services/firebase.service.dart';
import '../services/social_login.dart';

class MainViewModel {
  final SocialLogin _socialLogin;
  bool isLogined = false;
  kakao.User? user;

  MainViewModel(this._socialLogin);

  Future login() async {

    isLogined = await _socialLogin.login();
    if(isLogined) {
      user = await kakao.UserApi.instance.me();

      final customToken = await FirebaseService().createCustomToken({
        'uid' : user!.id.toString(),
        'displayName' : user!.kakaoAccount?.profile?.nickname,
        'email' : user!.kakaoAccount!.email!,
        'photoURL' : user!.kakaoAccount!.profile!.profileImageUrl,
      });

      await FirebaseAuth.instance.signInWithCustomToken(customToken)
    }

    // if (await isKakaoTalkInstalled()) {
    //   try {
    //     await UserApi.instance.loginWithKakaoTalk();
    //     print('카카오톡으로 로그인 성공');
    //   } catch (error) {
    //     print('카카오톡으로 로그인 실패 $error');
    //
    //     // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
    //     // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
    //     if (error is PlatformException && error.code == 'CANCELED') {
    //       return;
    //     }
    //     // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
    //     try {
    //       await UserApi.instance.loginWithKakaoAccount();
    //       print('카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인 로그인 성공');
    //     } catch (error) {
    //       print('카카오계정으로 로그인 실패 $error');
    //     }
    //   }
    // } else {
    //   try {
    //     await UserApi.instance.loginWithKakaoAccount();
    //   } catch (error) {
    //     print('카카오계정으로 로그인 실패 $error');
    //   }
    //
    //
    // }
    Future logout() async {
      await _socialLogin.logout();
      isLogined = false;
      user = null;
    }
  }
}