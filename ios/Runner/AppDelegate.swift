import UIKit
import Flutter
import FirebaseCore
import CoreLocation
import GoogleMaps
import flutter_downloader
// import KakaoSDKCommon

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//     KakaoSDK.initSDK(appKey: "kakaod7eaa723a1b0bbd17635330c5c561a5e")
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyDYRks2VmSMhM_5Ee3K8aTXVRqBCZXtXZ4")
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    func registerPlugins(registry: FlutterPluginRegistry) {
        if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
         FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
      }
    }
    //Ios Push 설정
    if #available(iOS 10.0, *) { UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate }

    // 위치 추적
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
