import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let appGroupChannel = FlutterMethodChannel(name: "com.sajon.couple_app/app_group",
                                              binaryMessenger: controller.binaryMessenger)
    
    appGroupChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if (call.method == "getAppGroupPath") {
        let fileManager = FileManager.default
        let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.sajon.coupleApp")
        result(containerURL?.path)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
