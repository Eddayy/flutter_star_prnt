import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_star_prnt/enums.dart';
import 'package:flutter_star_prnt/portInfo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_star_prnt/prnt_commands.dart';

export 'enums.dart';
export 'portInfo.dart';
export 'prnt_commands.dart';

class FlutterStarPrnt {
  static const MethodChannel _channel =
      const MethodChannel('flutter_star_prnt');

  static Future<List<PortInfo>> portDiscovery(PortType portType) async {
    String type;
    switch (portType) {
      case PortType.all:
        type = 'All';
        break;
      case PortType.lan:
        type = 'LAN';
        break;
      case PortType.bluetooth:
        type = 'Bluetooth';
        break;
      case PortType.usb:
        type = 'USB';
        break;
    }
    dynamic result =
        await _channel.invokeMethod('portDiscovery', {'type': type});
    if (result is List) {
      return result.map<PortInfo>((port) {
        return PortInfo(port);
      }).toList();
    } else {
      return null;
    }
  }

  static Future<dynamic> checkStatus({
    @required String portName,
    @required String emulation,
  }) async {
    dynamic result = await _channel.invokeMethod('checkStatus', {
      'portName': portName,
      'emulation': emulation,
    });
    return result;
  }
  static Future<dynamic> print({
    @required String portName,
    @required String emulation,
    @required PrntCommands printCommands
  }) async {
    dynamic result = await _channel.invokeMethod('print', {
      'portName': portName,
      'emulation': emulation,
      'printCommands' :printCommands.getCommands(),
    });
    return result;
  }

  static Future<dynamic> connect({
    @required String portName,
    @required String emulation,
    bool hasBarcodeReader = false,
  }) async {
    dynamic result = await _channel.invokeMethod('connect', {
      'portName': portName,
      'emulation': emulation,
      'hasBarcodeReader': hasBarcodeReader,
    });
    return result;
  }
}
