import Flutter
import UIKit

public class SwiftFlutterStarPrntPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_star_prnt", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterStarPrntPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch (call.method) {
          case "portDiscovery":
              portDiscovery(call, result: result)
              break;
          default:
              result(FlutterMethodNotImplemented)
      }
      result("iOS " + UIDevice.current.systemVersion)
    }
    
    public func portDiscovery(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let type = arguments["type"] as! String
        do {
            var info = [Dictionary<String,String>]()
            if ( type == "Bluetooth" || type == "All") {
                let btPortInfoArray = try SMPort.searchPrinter(target: "BT:")
                for printer in btPortInfoArray {
                    info.append(portInfoToDictionary(portInfo: printer as! PortInfo))
                }
            }
            if ( type == "LAN" || type == "All") {
                let lanPortInfoArray = try SMPort.searchPrinter(target: "TCP:")
                for printer in lanPortInfoArray {
                    info.append(portInfoToDictionary(portInfo: printer as! PortInfo))
                }
            }
            if ( type == "USB" || type == "All") {
                let usbPortInfoArray = try SMPort.searchPrinter(target: "USB:")
                for printer in usbPortInfoArray {
                    info.append(portInfoToDictionary(portInfo: printer as! PortInfo))
                }
            }
            result(info)
        } catch {
            result(
                FlutterError.init(code: "PORT_DISCOVERY_ERROR", message: error.localizedDescription, details: nil)
            )
        }
    }

    public func portInfoToDictionary(portInfo: PortInfo) -> Dictionary<String,String>{
        return [
            "portName": portInfo.portName,
            "macAddress": portInfo.macAddress,
            "modelName": portInfo.modelName
        ]
    }
}
