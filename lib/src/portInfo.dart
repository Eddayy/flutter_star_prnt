/// Contains info of the printer connection
class PortInfo {
  /// MacAdress of printer
  String? macAddress;

  /// Model name of printer
  String? modelName;

  /// Port connection of printer, use this to connect to the printer
  String? portName;

  /// USB Serial number of usb printers
  String? usbSerialNumber;

  PortInfo(dynamic port) {
    if (port.containsKey('macAddress')) this.macAddress = port['macAddress'];
    if (port.containsKey('modelName')) this.modelName = port['modelName'];
    if (port.containsKey('portName')) this.portName = port['portName'];
    if (port.containsKey('USBSerialNumber'))
      this.usbSerialNumber = port['USBSerialNumber'];
  }
}
