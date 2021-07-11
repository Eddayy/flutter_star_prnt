import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_star_prnt/src/enums.dart';
import 'package:flutter_star_prnt/src/portInfo.dart';
import 'package:flutter_star_prnt/src/print_commands.dart';
import 'package:flutter_star_prnt/src/utilities.dart';
import 'printer_response_status.dart';

/// Class to handle printer communication
class StarPrnt {
  static const MethodChannel _channel =
      const MethodChannel('flutter_star_prnt');

  /// Scan for available printers. Have specify [StarPortType] of the printer
  static Future<List<PortInfo>> portDiscovery(StarPortType portType) async {
    dynamic result =
        await _channel.invokeMethod('portDiscovery', {'type': portType.text});
    if (result is List) {
      return result.map<PortInfo>((port) {
        return PortInfo(port);
      }).toList();
    } else {
      return [];
    }
  }

  /// Check status of printer. Have specify [portName] and [emulation]. Returns [PrinterResponseStatus]. Use [StarMicronicsUtilities] to find suitable emulations.
  static Future<PrinterResponseStatus> getStatus({
    required String portName,
    required String emulation,
  }) async {
    dynamic result = await _channel.invokeMethod('checkStatus', {
      'portName': portName,
      'emulation': emulation,
    });
    return PrinterResponseStatus.fromMap(
      Map<String, dynamic>.from(result),
    );
  }

  /// Sends [PrintCommands] to the printer. Have to specify [portName] and [emulation]. Returns [PrinterResponseStatus]
  static Future<PrinterResponseStatus> sendCommands({
    required String portName,
    required String emulation,
    required PrintCommands printCommands,
  }) async {
    dynamic result = await _channel.invokeMethod('print', {
      'portName': portName,
      'emulation': emulation,
      'printCommands': printCommands.getCommands(),
    });
    return PrinterResponseStatus.fromMap(
      Map<String, dynamic>.from(result),
    );
  }

  /// Sends [PrintCommands] optimized for speed to the printer.Should execute faster than sendCommands with diffrent option. Have to specify [portName] , [emulation]
  /// [useStartEndBlock] making this true make execution faster but it can case printer hang with Bluetooth printer or USB printer
  /// pass this false for Bluetooth or USB
  /// . Returns [PrinterResponseStatus]
  static Future<PrinterResponseStatus> sendCommandsSpeedOptimized({
    required String portName,
    required String emulation,
    required PrintCommands printCommands,
    required bool useStartEndBlock,
  }) async {
    dynamic result = await _channel.invokeMethod('print', {
      'portName': portName,
      'emulation': emulation,
      'printCommands': printCommands.getCommands(),
      'fastPrint': true,
      'useStartEndBlock': useStartEndBlock,
      'fastPrintWithBlock':
          true, // making this false will make this function almost equal to sendCommands
    });
    return PrinterResponseStatus.fromMap(
      Map<String, dynamic>.from(result),
    );
  }

  /// sends commands to printer to run
  @Deprecated('Use sendCommands instead.')
  static Future<dynamic> print({
    required String portName,
    required String emulation,
    required PrintCommands printCommands,
  }) async {
    dynamic result = await _channel.invokeMethod('print', {
      'portName': portName,
      'emulation': emulation,
      'printCommands': printCommands.getCommands(),
    });
    return result;
  }

  /// Check status of printer
  @Deprecated('Use getStatus instead.')
  static Future<dynamic> checkStatus({
    required String portName,
    required String emulation,
  }) async {
    dynamic result = await _channel.invokeMethod('checkStatus', {
      'portName': portName,
      'emulation': emulation,
    });
    return result;
  }

  // static Future<dynamic> connect({
  //   required String portName,
  //   required String emulation,
  //   bool hasBarcodeReader = false,
  // }) async {
  //   dynamic result = await _channel.invokeMethod('connect', {
  //     'portName': portName,
  //     'emulation': emulation,
  //     'hasBarcodeReader': hasBarcodeReader,
  //   });
  //   return result;
  // }
}
