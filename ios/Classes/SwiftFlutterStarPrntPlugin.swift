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
            case "portDiscovery":
                portDiscovery(call, result: result)
                break;
            case "checkStatus":
                checkStatus(call, result: result)
                break;
            case "print":
                print(call, result: result)
            default:
                result(FlutterMethodNotImplemented)
      }
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

    public func checkStatus (_ call: FlutterMethodCall, result: @escaping FlutterResult){
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let portName = arguments["portName"] as! String
        let emulation = arguments["emulation"] as! String
        var port:SMPort
        var status: StarPrinterStatus_2 = StarPrinterStatus_2()
        do {
            port = try SMPort.getPort(portName: portName, portSettings: getPortSettingsOption(emulation), ioTimeoutMillis: 10000)
            defer {
                SMPort.release(port)
            }
            if #available(iOS 11.0, *){
                if(portName.uppercased().hasPrefix("BT:")) {
                    usleep(200000) //sleep 0.2 seconds
                }
            }
            try port.getParsedStatus(starPrinterStatus: &status, level: 2)
            var firmwareInformation: Dictionary =  [AnyHashable:Any]()
            var errorMsg:String?
            
            do {
                firmwareInformation = try port.getFirmwareInformation()
            } catch {
                errorMsg = error.localizedDescription
            }
            result(portStatusToDictionary(status: status,firmwareInformation: firmwareInformation,errorMsg: errorMsg))
        } catch {
            result(
                 FlutterError.init(code: "CHECK_STATUS_ERROR", message: error.localizedDescription, details: nil)
             )
        }
    }
    
    public func print(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let portName = arguments["portName"] as! String
        let emulation = arguments["emulation"] as! String
        let printCommands = arguments["printCommands"] as! Array<Dictionary<String,Any>>

        
        let portSettings :String = getPortSettingsOption(emulation)
        let starEmulation :StarIoExtEmulation = getEmulation(emulation)
        let builder:ISCBBuilder = StarIoExt.createCommandBuilder(starEmulation)
        builder.beginDocument()
        appendCommands(builder: builder, printCommands: printCommands)
        builder.endDocument()
        sendCommand(portName: portName, portSetting: portSettings, command: [UInt8](builder.commands.copy() as! Data),result: result)
        
    }
    
    func portInfoToDictionary(portInfo: PortInfo) -> Dictionary<String,String>{
        return [
            "portName": portInfo.portName,
            "macAddress": portInfo.macAddress,
            "modelName": portInfo.modelName
        ]
    }
    
    func getPortSettingsOption(_ emulation:String) ->String {
        switch (emulation) {
            case "EscPosMobile": return "mini"
            case "EscPos": return "escpos"
            case "StarPRNT","StarPRNTL" : return "Portable;l"
            default: return emulation
        }
    }
    func portStatusToDictionary(status: StarPrinterStatus_2,firmwareInformation:Dictionary<AnyHashable,Any>,errorMsg:String?) ->Dictionary<AnyHashable,Any> {
        let SM_TRUE =  SM_TRUESHARED
        let dict: Dictionary<AnyHashable,Any> =  [
            "coverOpen" :status.coverOpen == SM_TRUE,
            "offline": status.offline == SM_TRUE,
            "overTemp": status.overTemp == SM_TRUE,
            "cutterError" :status.cutterError == SM_TRUE,
            "receiptPaperEmpty": status.receiptPaperEmpty == SM_TRUE,
            "is_success": true,
            "error_message" :errorMsg ?? "",
        ]
        return dict.merging(firmwareInformation){ (current, _) in current }
    }
    func getEmulation(_ emulation: String) -> StarIoExtEmulation {
        if (emulation == "StarPRNT") {
            return StarIoExtEmulation.starPRNT
        } else if (emulation == "StarPRNTL") {
            return StarIoExtEmulation.starPRNTL
        } else if (emulation == "StarLine") {
            return StarIoExtEmulation.starLine
        } else if (emulation == "StarGraphic") {
            return StarIoExtEmulation.starGraphic
        } else if (emulation == "EscPos") {
            return StarIoExtEmulation.escPos
        } else if (emulation == "EscPosMobile") {
            return StarIoExtEmulation.escPosMobile
        } else if (emulation == "StarDotImpact") {
            return StarIoExtEmulation.starDotImpact
        } else {
            return StarIoExtEmulation.starLine
        }
    }
    func appendCommands(builder: ISCBBuilder,printCommands: Array<Dictionary<AnyHashable,Any>>) {
        var encoding:String.Encoding = .ascii
        for command in printCommands {
            if (command["appendInternational"] != nil) {
                builder.append(getInternational(command["appendInternational"] as? String))
            } else if (command["appendCharacterSpace"] != nil) {
                builder.appendCharacterSpace(command["appendCharacterSpace"] as! Int)
            } else if (command["appendEncoding"] != nil) {
                encoding = getEncoding(command["appendEncoding"] as? String)
            } else if (command["appendCodePage"] != nil) {
                builder.append(getCodePageType(command["appendCodePage"] as? String))
            } else if (command["append"] != nil) {
                builder.append((command["append"] as! String).data(using: encoding))
            } else if (command["appendRaw"] != nil) {
                builder.appendRawData((command["appendRaw"] as! String).data(using: encoding))
            } else if (command["appendEmphasis"] != nil) {
                builder.appendData(withEmphasis: (command["appendEmphasis"] as! String).data(using: encoding))
            } else if (command["enableEmphasis"] != nil) {
                builder.appendEmphasis(command["enableEmphasis"] as! Bool)
            } else if (command["appendInvert"] != nil) {
                builder.appendData(withInvert: (command["appendInvert"] as! String).data(using: encoding))
            } else if (command["enableInvert"] != nil) {
                builder.appendInvert(command["enableInvert"] as! Bool)
            } else if (command["appendUnderline"] != nil) {
                builder.appendData(withUnderLine: (command["appendUnderline"] as! String).data(using: encoding))
            } else if (command["enableUnderline"] != nil) {
                builder.appendUnderLine(command["enableUnderline"] as! Bool)
            } else if (command["appendLineFeed"] != nil) {
                builder.appendLineFeed(command["appendLineFeed"] as! Int)
            } else if (command["appendUnitFeed"] != nil) {
                builder.appendUnitFeed(command["appendUnitFeed"] as! Int)
            } else if (command["appendLineSpace"] != nil) {
                builder.appendUnitFeed(command["appendLineSpace"] as! Int)
            } else if (command["appendFontStyle"] != nil) {
                builder.append(getFont(command["appendFontStyle"] as? String))
            } else if (command["appendCutPaper"] != nil) {
                builder.appendCutPaper(getCutPaperAction(command["appendCutPaper"] as? String))
            } else if (command["openCashDrawer"] != nil) {
                builder.appendPeripheral(getPeripheralChannel(command["openCashDrawer"] as? NSNumber))
            } else if (command["appendBlackMark"] != nil) {
                builder.append(getBlackMarkType(command["appendBlackMark"] as? String))
            } else if (command["appendBytes"] != nil) {
                let byteArray = Data((command["appendBytes"] as! FlutterStandardTypedData).data)
                builder.appendBytes([UInt8](byteArray), length: UInt([UInt8](byteArray).count))
            } else if (command["appendRawBytes"] != nil) {
                let byteArray = Data((command["appendRawBytes"] as! FlutterStandardTypedData).data)
                builder.appendRawBytes([UInt8](byteArray), length: UInt([UInt8](byteArray).count))
            } else if (command["appendAbsolutePosition"] != nil) {
                if (command["data"] != nil) {
                    builder.appendData(withAbsolutePosition: (command["data"] as! String).data(using: encoding), position: command["appendAbsolutePosition"] as! Int)
                } else {
                    builder.appendAbsolutePosition(command["appendAbsolutePosition"] as! Int)
                }
            } else if (command["appendAlignment"] != nil) {
                if (command["data"] != nil) {
                    builder.appendData(withAlignment: (command["data"] as! String).data(using: encoding), position: getAlignment(command["appendAlignment"] as? String))
                } else {
                    builder.appendAlignment(getAlignment(command["appendAlignment"] as? String))
                }
            } else if (command["appendHorizontalTabPosition"] != nil) {
                builder.appendHorizontalTabPosition(command["appendHorizontalTabPosition"] as? Array<NSNumber>)
            } else if (command["appendMultiple"] != nil) {
                let width = command["width"] != nil ? command["width"] as! Int : 2
                let height = command["height"] != nil ? command["height"] as! Int : 2
                builder.appendData(withMultiple: (command["appendMultiple"] as! String).data(using: encoding), width: width, height: height)
            } else if (command["enableMultiple"] != nil) {
                let width = command["width"] != nil ? command["width"] as! Int : 1
                let height = command["height"] != nil ? command["height"] as! Int : 1
                if ( command["enableMultiple"] as! Bool) == true {
                    builder.appendMultiple(width, height: height)
                } else {
                    builder.appendMultiple(1, height: 1)
                }
            } else if (command["appendLogo"] != nil) {
                if (command["logoSize"] != nil) {
                    builder.appendLogo(getLogoSize(command["logoSize"] as? String), number: command["appendLogo"] as! Int)
                } else {
                    builder.appendLogo(SCBLogoSize.normal, number: command["appendLogo"] as! Int)
                }
            } else if (command["appendBarcode"] != nil) {
                let barcodeSymbology :SCBBarcodeSymbology = getBarcodeSymbology(command["BarcodeSymbology"] as? String)
                let barcodeWidth :SCBBarcodeWidth = getBarcodeWidth(command["BarcodeWidth"] as? String)
                let height = command["height"] != nil ? command["height"] as! Int : 40
                let hri = command["hri"] != nil ? command["hri"] as! Bool : true

                if (command["absolutePosition"] != nil) {
                    builder.appendBarcodeData(withAbsolutePosition: (command["appendBarcode"] as! String).data(using: encoding), symbology: barcodeSymbology, width: barcodeWidth, height: height, hri: hri, position: command["absolutePosition"] as! Int)
                } else if (command["alignment"] != nil) {
                    builder.appendBarcodeData(withAlignment: (command["appendBarcode"] as! String).data(using: encoding), symbology: barcodeSymbology, width: barcodeWidth, height: height, hri: hri, position: getAlignment(command["alignment"] as? String))
                } else {
                    builder.appendBarcodeData((command["appendBarcode"] as! String).data(using: encoding), symbology: barcodeSymbology, width: barcodeWidth, height: height, hri: hri)
                }
            } else if (command["appendQrCode"] != nil) {
                let qrCodeModel = getQrCodeModel(command["QrCodeModel"] as? String)
                let qrCodeLevel = getQrCodeLevel(command["QrCodeLevel"] as? String)
                let cell = command["cell"] != nil ? command["cell"] as! Int : 4
                if (command["absolutePosition"] != nil) {
                    builder.appendQrCodeData(withAbsolutePosition: (command["appendQrCode"] as! String).data(using: encoding), model: qrCodeModel, level: qrCodeLevel, cell: cell, position: command["absolutePosition"] as! Int)
                } else if (command["alignment"] != nil){
                    builder.appendQrCodeData(withAlignment: (command["appendQrCode"] as! String).data(using: encoding), model: qrCodeModel, level: qrCodeLevel, cell: cell, position: getAlignment(command["alignment"] as? String))
                } else {
                    builder.appendQrCodeData((command["appendQrCode"] as! String).data(using: encoding), model: qrCodeModel, level: qrCodeLevel, cell: cell)
                }
            }else if (command["appendBitmap"] != nil) {
                let urlString = command["appendBitmap"] as? String
                let width = command["width"] != nil ? (command["width"] as? NSNumber)?.intValue ?? 0 : 576
                let diffusion = ((command["diffusion"] as? NSNumber)?.boolValue ?? false == false) ? false : true
                let bothScale = ((command["bothScale"] as? NSNumber)?.boolValue ?? false == false) ? false : true
                let rotation = getBitmapConverterRotation(command["rotation"] as? String)
                let error: Error? = nil
                let imageURL = URL(string: urlString ?? "")
                var imageData: Data? = nil
                do {
                    if let imageURL = imageURL {
                        imageData = try Data(contentsOf: imageURL, options: .uncached)
                    }
                } catch {
                    let fileImageURL = URL(fileURLWithPath: urlString ?? "")
                    do {
                        imageData = try Data(contentsOf: fileImageURL)
                    } catch {
                    }
                }
                if imageData != nil {
                    let image = UIImage(data: imageData!)
                    if command["absolutePosition"] != nil {
                        let position = ((command["absolutePosition"] as? NSNumber)?.intValue ?? 0) != 0 ? (command["absolutePosition"] as? NSNumber)?.intValue ?? 0 : 40
                        builder.appendBitmap(withAbsolutePosition: image, diffusion: diffusion, width: width, bothScale: bothScale, rotation: rotation, position: position)
                    } else if command["alignment"] != nil {
                        let alignment = getAlignment(command["alignment"] as?  String)
                        builder.appendBitmap(withAlignment: image, diffusion: diffusion, width: width, bothScale: bothScale, rotation: rotation, position: alignment)
                    } else {
                        builder.appendBitmap(image, diffusion: diffusion, width: width, bothScale: bothScale, rotation: rotation)
                    }
                }
            } else if (command["appendBitmapText"] != nil) {
                let text:String = command["appendBitmapText"] as! String
                let width = command["width"] != nil ? command["width"] as! Int : 576
                let fontName = command["font"] != nil ? command["font"] as! String : "Menlo"
                let fontSize = command["fontSize"] != nil ? command["fontSize"] as! Int : 12
                let bothScale = command["bothScale"] != nil ? command["bothScale"] as! Bool : true
                let rotation = SCBBitmapConverterRotation.normal;
                let font:UIFont = UIFont(name:fontName,size:CGFloat(fontSize*2))!
                let image = imageWithString(string: text, font: font, width: CGFloat(width))
                if (command["alignment"] != nil) {
                    builder.appendBitmap(withAlignment: image, diffusion: false, width: width, bothScale: bothScale, rotation: rotation, position: getAlignment(command["alignment"] as? String))
                } else {
                    builder.appendBitmap(image, diffusion: false)
                }
            } else if (command["appendBitmapByteArray"] != nil) {
                let data:FlutterStandardTypedData = command["appendBitmapByteArray"] as! FlutterStandardTypedData
                let image = UIImage(data: data.data)!
                let width = command["width"] != nil ? (command["width"] as? NSNumber)?.intValue ?? 0 : 576
                let bothScale = command["bothScale"] != nil ? command["bothScale"] as! Bool : true
                let diffusion = command["diffusion"] != nil ? command["diffusion"] as! Bool : true
                let rotation = getBitmapConverterRotation(command["rotation"] as? String)
                if command["absolutePosition"] != nil {
                    let position = ((command["absolutePosition"] as? NSNumber)?.intValue ?? 0) != 0 ? (command["absolutePosition"] as? NSNumber)?.intValue ?? 0 : 40
                    builder.appendBitmap(withAbsolutePosition: image, diffusion: diffusion, width: width, bothScale: bothScale, rotation: rotation, position: position)
                } else if command["alignment"] != nil {
                    let alignment = getAlignment(command["alignment"] as?  String)
                    builder.appendBitmap(withAlignment: image, diffusion: diffusion, width: width, bothScale: bothScale, rotation: rotation, position: alignment)
                } else {
                    builder.appendBitmap(image, diffusion: diffusion, width: width, bothScale: bothScale, rotation: rotation)
                }
            }
        }
    }
    func getInternational(_ internationl: String?) -> SCBInternationalType {
        if !(internationl ?? "").isEmpty {
            if (internationl == "US") || (internationl == "USA") {
                return SCBInternationalType.USA
            } else if (internationl == "FR") || (internationl == "France") {
                return SCBInternationalType.france
            } else if (internationl == "UK") {
                return SCBInternationalType.UK
            } else if (internationl == "Germany") {
                return SCBInternationalType.germany
            } else if (internationl == "Denmark") {
                return SCBInternationalType.denmark
            } else if (internationl == "Sweden") {
                return SCBInternationalType.sweden
            } else if (internationl == "Italy") {
                return SCBInternationalType.italy
            } else if (internationl == "Spain") {
                return SCBInternationalType.spain
            } else if (internationl == "Japan") {
                return SCBInternationalType.japan
            } else if (internationl == "Norway") {
                return SCBInternationalType.norway
            } else if (internationl == "Denmark2") {
                return SCBInternationalType.denmark2
            } else if (internationl == "Spain2") {
                return SCBInternationalType.spain2
            } else if (internationl == "LatinAmerica") {
                return SCBInternationalType.latinAmerica
            } else if (internationl == "Korea") {
                return SCBInternationalType.korea
            } else if (internationl == "Ireland") {
                return SCBInternationalType.ireland
            } else if (internationl == "Legal") {
                return SCBInternationalType.legal
            } else {
                return SCBInternationalType.USA
            }
        } else {
            return SCBInternationalType.USA
        }
    }
    func getEncoding(_ encoding: String?) -> String.Encoding {
        if !(encoding ?? "").isEmpty {
            if (encoding == "US-ASCII") {
                return .ascii //English
            } else if (encoding == "Windows-1252") {
                return .windowsCP1252 //French, German, Portuguese, Spanish
            } else if (encoding == "Shift-JIS") {
                return .shiftJIS //Japanese
            } else if (encoding == "Windows-1251") {
                return .windowsCP1251 //Russian
            } else if (encoding == "GB2312") {
                return  String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))) // Simplified Chinese
            } else if (encoding == "Big5") {
                return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue))) // Traditional Chinese
            } else if (encoding == "UTF-8") {
                return .utf8 // UTF-8
            }
            return .windowsCP1252
        } else {
            return .ascii
        }
    }
    func getCodePageType(_ codePageType: String?) -> SCBCodePageType {
        if !(codePageType ?? "").isEmpty {
            if (codePageType == "CP437") {
                return SCBCodePageType.CP437
            } else if (codePageType == "CP737") {
                return SCBCodePageType.CP737
            } else if (codePageType == "CP772") {
                return SCBCodePageType.CP772
            } else if (codePageType == "CP774") {
                return SCBCodePageType.CP774
            } else if (codePageType == "CP851") {
                return SCBCodePageType.CP851
            } else if (codePageType == "CP852") {
                return SCBCodePageType.CP852
            } else if (codePageType == "CP855") {
                return SCBCodePageType.CP855
            } else if (codePageType == "CP857") {
                return SCBCodePageType.CP857
            } else if (codePageType == "CP858") {
                return SCBCodePageType.CP858
            } else if (codePageType == "CP860") {
                return SCBCodePageType.CP860
            } else if (codePageType == "CP861") {
                return SCBCodePageType.CP861
            } else if (codePageType == "CP862") {
                return SCBCodePageType.CP862
            } else if (codePageType == "CP863") {
                return SCBCodePageType.CP863
            } else if (codePageType == "CP864") {
                return SCBCodePageType.CP864
            } else if (codePageType == "CP865") {
                return SCBCodePageType.CP866
            } else if (codePageType == "CP869") {
                return SCBCodePageType.CP869
            } else if (codePageType == "CP874") {
                return SCBCodePageType.CP874
            } else if (codePageType == "CP928") {
                return SCBCodePageType.CP928
            } else if (codePageType == "CP932") {
                return SCBCodePageType.CP932
            } else if (codePageType == "CP999") {
                return SCBCodePageType.CP999
            } else if (codePageType == "CP1001") {
                return SCBCodePageType.CP1001
            } else if (codePageType == "CP1250") {
                return SCBCodePageType.CP1250
            } else if (codePageType == "CP1251") {
                return SCBCodePageType.CP1251
            } else if (codePageType == "CP1252") {
                return SCBCodePageType.CP1252
            } else if (codePageType == "CP2001") {
                return SCBCodePageType.CP2001
            } else if (codePageType == "CP3001") {
                return SCBCodePageType.CP3001
            } else if (codePageType == "CP3002") {
                return SCBCodePageType.CP3002
            } else if (codePageType == "CP3011") {
                return SCBCodePageType.CP3011
            } else if (codePageType == "CP3012") {
                return SCBCodePageType.CP3012
            } else if (codePageType == "CP3021") {
                return SCBCodePageType.CP3021
            } else if (codePageType == "CP3041") {
                return SCBCodePageType.CP3041
            } else if (codePageType == "CP3840") {
                return SCBCodePageType.CP3840
            } else if (codePageType == "CP3841") {
                return SCBCodePageType.CP3841
            } else if (codePageType == "CP3843") {
                return SCBCodePageType.CP3843
            } else if (codePageType == "CP3845") {
                return SCBCodePageType.CP3845
            } else if (codePageType == "CP3846") {
                return SCBCodePageType.CP3846
            } else if (codePageType == "CP3847") {
                return SCBCodePageType.CP3847
            } else if (codePageType == "CP3848") {
                return SCBCodePageType.CP3848
            } else if (codePageType == "UTF8") {
                return SCBCodePageType.UTF8
            } else if (codePageType == "Blank") {
                return SCBCodePageType.blank
            } else {
                return SCBCodePageType.CP998
            }
        } else {
            return SCBCodePageType.CP998
        }
    }
    func getFont(_ font: String?) -> SCBFontStyleType {
        if !(font ?? "").isEmpty {
            if (font == "A") {
                return SCBFontStyleType.A
            } else if (font == "B") {
                return SCBFontStyleType.B
            } else {
                return SCBFontStyleType.A
            }
        } else {
            return SCBFontStyleType.A
        }
    }
    func getCutPaperAction(_ cutPaperAction: String?) -> SCBCutPaperAction {
        if !(cutPaperAction ?? "").isEmpty {
            if (cutPaperAction == "FullCut") {
                return SCBCutPaperAction.fullCut
            } else if (cutPaperAction == "FullCutWithFeed") {
                return SCBCutPaperAction.fullCutWithFeed
            } else if (cutPaperAction == "PartialCut") {
                return SCBCutPaperAction.partialCut
            } else if (cutPaperAction == "PartialCutWithFeed") {
                return SCBCutPaperAction.partialCutWithFeed
            } else {
                return SCBCutPaperAction.partialCutWithFeed
            }
        } else {
            return SCBCutPaperAction.partialCutWithFeed
        }
    }
    func getPeripheralChannel(_ peripheralChannel: NSNumber?) -> SCBPeripheralChannel {
        if peripheralChannel != nil {
            if peripheralChannel?.intValue ?? 0 == 1 {
                return SCBPeripheralChannel.no1
            } else if peripheralChannel?.intValue ?? 0 == 2 {
                return SCBPeripheralChannel.no2
            } else {
                return SCBPeripheralChannel.no1
            }
        } else {
            return SCBPeripheralChannel.no1
        }
    }
    func getBlackMarkType(_ blackMarkType: String?) -> SCBBlackMarkType {
        if !(blackMarkType ?? "").isEmpty {
            if (blackMarkType == "Valid") {
                return SCBBlackMarkType.valid
            } else if (blackMarkType == "Invalid") {
                return SCBBlackMarkType.invalid
            } else if (blackMarkType == "ValidWithDetection") {
                return SCBBlackMarkType.validWithDetection
            } else {
                return SCBBlackMarkType.valid
            }
        } else {
            return SCBBlackMarkType.valid
        }
    }
    func getAlignment(_ alignment: String?) -> SCBAlignmentPosition {
        if !(alignment ?? "").isEmpty {
            if alignment?.caseInsensitiveCompare("left") == .orderedSame {
                return SCBAlignmentPosition.left
            } else if alignment?.caseInsensitiveCompare("center") == .orderedSame {
                return SCBAlignmentPosition.center
            } else if alignment?.caseInsensitiveCompare("right") == .orderedSame {
                return SCBAlignmentPosition.right
            } else {
                return SCBAlignmentPosition.left
            }
        } else {
            return SCBAlignmentPosition.left
        }
    }
    func getLogoSize(_ logoSize: String?) -> SCBLogoSize {
        if !(logoSize ?? "").isEmpty {
            if (logoSize == "Normal") {
                return SCBLogoSize.normal
            } else if (logoSize == "DoubleWidth") {
                return SCBLogoSize.doubleWidth
            } else if (logoSize == "DoubleHeight") {
                return SCBLogoSize.doubleHeight
            } else if (logoSize == "DoubleWidthDoubleHeight") {
                return SCBLogoSize.doubleWidthDoubleHeight
            } else {
                return SCBLogoSize.normal
            }
        } else {
            return SCBLogoSize.normal
        }
    }
    func getBarcodeSymbology(_ barcodeSymbology: String?) -> SCBBarcodeSymbology {
        if !(barcodeSymbology ?? "").isEmpty {
            if (barcodeSymbology == "Code128") {
                return SCBBarcodeSymbology.code128
            } else if (barcodeSymbology == "Code39") {
                return SCBBarcodeSymbology.code39
            } else if (barcodeSymbology == "Code93") {
                return SCBBarcodeSymbology.code128
            } else if (barcodeSymbology == "ITF") {
                return SCBBarcodeSymbology.ITF
            } else if (barcodeSymbology == "JAN8") {
                return SCBBarcodeSymbology.JAN8
            } else if (barcodeSymbology == "JAN13") {
                return SCBBarcodeSymbology.JAN13
            } else if (barcodeSymbology == "NW7") {
                return SCBBarcodeSymbology.NW7
            } else if (barcodeSymbology == "UPCA") {
                return SCBBarcodeSymbology.UPCA
            } else if (barcodeSymbology == "UPCE") {
                return SCBBarcodeSymbology.UPCE
            } else {
                return SCBBarcodeSymbology.code128
            }
        } else {
            return SCBBarcodeSymbology.code128
        }
    }
    func getBarcodeWidth(_ barcodeWidth: String?) -> SCBBarcodeWidth {
        if !(barcodeWidth ?? "").isEmpty {
            if (barcodeWidth == "Mode1") {
                return SCBBarcodeWidth.mode1
            } else if (barcodeWidth == "Mode2") {
                return SCBBarcodeWidth.mode2
            } else if (barcodeWidth == "Mode3") {
                return SCBBarcodeWidth.mode3
            } else if (barcodeWidth == "Mode4") {
                return SCBBarcodeWidth.mode4
            } else if (barcodeWidth == "Mode5") {
                return SCBBarcodeWidth.mode5
            } else if (barcodeWidth == "Mode6") {
                return SCBBarcodeWidth.mode6
            } else if (barcodeWidth == "Mode7") {
                return SCBBarcodeWidth.mode7
            } else if (barcodeWidth == "Mode8") {
                return SCBBarcodeWidth.mode8
            } else if (barcodeWidth == "Mode9") {
                return SCBBarcodeWidth.mode9
            } else {
                return SCBBarcodeWidth.mode2
            }
        } else {
            return SCBBarcodeWidth.mode2
        }
    }
    func getQrCodeModel(_ qrCodeModel: String?) -> SCBQrCodeModel {
        if !(qrCodeModel ?? "").isEmpty {
            if (qrCodeModel == "No1") {
                return SCBQrCodeModel.no1
            } else if (qrCodeModel == "No2") {
                return SCBQrCodeModel.no2
            } else {
                return SCBQrCodeModel.no1
            }
        } else {
            return SCBQrCodeModel.no1
        }
    }
    func getQrCodeLevel(_ qrCodeLevel: String?) -> SCBQrCodeLevel {
        if !(qrCodeLevel ?? "").isEmpty {
            if (qrCodeLevel == "H") {
                return SCBQrCodeLevel.H
            } else if (qrCodeLevel == "L") {
                return SCBQrCodeLevel.L
            } else if (qrCodeLevel == "M") {
                return SCBQrCodeLevel.M
            } else if (qrCodeLevel == "Q") {
                return SCBQrCodeLevel.Q
            } else {
                return SCBQrCodeLevel.H
            }
        } else {
            return SCBQrCodeLevel.H
        }
    }
    //  Converted to Swift 5.2 by Swiftify v5.2.29688 - https://swiftify.com/
    func getBitmapConverterRotation(_ rotation: String?) -> SCBBitmapConverterRotation {
        if !(rotation ?? "").isEmpty {
            if (rotation == "Normal") {
                return SCBBitmapConverterRotation.normal
            } else if (rotation == "Left90") {
                return SCBBitmapConverterRotation.left90
            } else if (rotation == "Right90") {
                return SCBBitmapConverterRotation.right90
            } else if (rotation == "Rotate180") {
                return SCBBitmapConverterRotation.rotate180
            } else {
                return SCBBitmapConverterRotation.normal
            }
        } else {
            return SCBBitmapConverterRotation.normal
        }
    }
    func imageWithString(string: String, font: UIFont, width: CGFloat) -> UIImage? {
        let size = string.boundingRect(
            with: CGSize(width: width, height: 10000),
            options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
            attributes: [NSAttributedString.Key.font : font] ,
            context: nil).size

        if UIScreen.main.responds(to: #selector(getter: UIScreen.scale)) {
            if UIScreen.main.scale == 2.0 {
                UIGraphicsBeginImageContextWithOptions(size , false, 1.0)
            } else {
                UIGraphicsBeginImageContext(size )
            }
        } else {
            UIGraphicsBeginImageContext(size )
        }

        let context = UIGraphicsGetCurrentContext()
        UIColor.white.set()

        let rect = CGRect(x: 0, y: 0, width: size.width + 1, height: size.height + 1)

        context!.fill(rect)

        let attributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: font
            ]
        

        string.draw(in: rect, withAttributes: attributes)

        let imageToPrint = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return imageToPrint
    }
    func sendCommand(portName:String,portSetting:String,command:[UInt8],result: FlutterResult){
        var port :SMPort
        var status: StarPrinterStatus_2 = StarPrinterStatus_2()

        do {
            port = try SMPort.getPort(portName: portName, portSettings: portSetting, ioTimeoutMillis: 10000)
            let SM_TRUE =  SM_TRUESHARED
            
            var json = Dictionary<AnyHashable, Any>()
            defer {
                SMPort.release(port)
            }
            usleep(200000)
            try port.beginCheckedBlock(starPrinterStatus: &status, level: 2)
            json = portStatusToDictionary(status: status, firmwareInformation: [String:Any](),errorMsg: nil)
            var isSucess = true
             if (status.coverOpen == SM_TRUE) {
              json["error_message"] = "Printer cover is open"
              isSucess = false
            } else if (status.receiptPaperEmpty == SM_TRUE) {
              json["error_message"] = "Paper empty"
              isSucess = false
            }else if (status.presenterPaperJamError == SM_TRUE) {
              json["error_message"] = "Paper Jam"
              isSucess = false
            }else if (status.offline == SM_TRUE) {
              json["error_message"] = "A printer is offline"
              isSucess = false
            }

            if (status.receiptPaperNearEmptyInner == SM_TRUE || status.receiptPaperNearEmptyOuter == SM_TRUE){
              json["info_message"] = "Paper near empty"
            }
            if isSucess {
                var total: UInt32 = 0
                while total < UInt32(command.count) {
                    var written: UInt32 = 0
                    try port.write(writeBuffer: command, offset: total, size: UInt32(command.count) - total, numberOfBytesWritten: &written)
                    total += written
                }
                try port.endCheckedBlock(starPrinterStatus: &status, level: 2)
                let newStat = portStatusToDictionary(status: status, firmwareInformation: [String:Any](),errorMsg: nil)
                
                json.merge(newStat) {  (current, _) in current}
                if (status.coverOpen == SM_TRUE) {
                  json["error_message"] = "Printer cover is open"
                } else if (status.receiptPaperEmpty == SM_TRUE) {
                  json["error_message"] = "Paper empty"
                }else if (status.presenterPaperJamError == SM_TRUE) {
                  json["error_message"] = "Paper Jam"
                }else if (status.offline == SM_TRUE) {
                  json["error_message"] = "A printer is offline"
                  isSucess = false
                }
            }
        
            if (status.receiptPaperNearEmptyInner == SM_TRUE || status.receiptPaperNearEmptyOuter == SM_TRUE){
              json["error_message"] = "Paper near empty"
            }
            json["is_success"] = isSucess
            result(json)

        } catch {
            result(
              FlutterError.init(code: "STARIO_PRINT_EXCEPTION", message: error.localizedDescription, details: nil)
          )
        }
    }


}
