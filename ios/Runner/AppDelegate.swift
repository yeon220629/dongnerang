import UIKit
import Flutter
import FirebaseCore
import CoreLocation
// import KakaoSDKCommon

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//     KakaoSDK.initSDK(appKey: "kakaod7eaa723a1b0bbd17635330c5c561a5e")
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)

    // NaverMap - 위치 추적
    if (CLLocationManager.locationServicesEnabled()) {
      switch CLLocationManager.authorizationStatus() {
      case .denied, .notDetermined, .restricted:
          CLLocationManager().requestAlwaysAuthorization()
          break
      default:
          break
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
