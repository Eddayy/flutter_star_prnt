import Flutter
import UIKit
import StarIO
import StarIO_Extension

public class SwiftFlutterStarPrntPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_star_prnt", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterStarPrntPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {

    }
    result("iOS " + UIDevice.current.systemVersion)
  }
}
