import UIKit
import Flutter
import flutter_local_notifications
import FirebaseCore
import GoogleMaps
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAGRntaClccj2f-In9knfyGw_zYF7lx1Mk")
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 11.0, *) {
  
UNUserNotificationCenter.current().delegate = self

let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
UNUserNotificationCenter.current().requestAuthorization(
  options: authOptions,
  completionHandler: { _, _ in }
)
application.registerForRemoteNotifications()

  }
  FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
    GeneratedPluginRegistrant.register(with: registry)
  }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}