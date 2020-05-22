class PortInfo {
  String macAddress;
  String modelName;
  String portName;
  String usbSerialNumber;

  PortInfo(dynamic port) {
    if (port.containsKey('macAddress')) this.macAddress = port['macAddress'];
    if (port.containsKey('modelName')) this.modelName = port['modelName'];
    if (port.containsKey('portName')) this.portName = port['portName'];
    if (port.containsKey('USBSerialNumber'))
      this.usbSerialNumber = port['USBSerialNumber'];
  }
}
