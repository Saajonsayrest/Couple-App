import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // UIScene lifecycle (required from iOS 27): the root view controller is not
  // ready at launch, so channels and plugins are set up once the engine exists.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let appGroupChannel = FlutterMethodChannel(
      name: "com.sajon.couple_app/app_group",
      binaryMessenger: engineBridge.applicationRegistrar.messenger())

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
  }
}
