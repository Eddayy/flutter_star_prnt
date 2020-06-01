
# flutter_star_prnt

[![Pub Version](https://img.shields.io/pub/v/flutter_star_prnt)](https://pub.dev/packages/flutter_star_prnt)

Flutter plugin for [Star micronics printers](http://www.starmicronics.com/pages/All-Products).

Native code based on React Native and Ionic/Cordova version  
React native Version ➜ [here](https://github.com/infoxicator/react-native-star-prnt)  
Ionic/Cordova Version ➜ [here](https://github.com/auctifera-josed/starprnt)

## Getting Started

```dart
import 'package:flutter_star_prnt/flutter_star_prnt.dart';

// Find printers
List<PortInfo> list = await StarPrnt.portDiscovery(StarPortType.All);

list.forEach((port) async {
/// Check status
await StarPrnt.checkStatus(portName: port.portName,emulation: 'StarGraphic',)
}

///send print commands to printer
PrintCommands commands = PrintCommands();
commands.push({
 'appendBitmapText': "Hello World"
});
commands.push({
 'appendCutPaper': "FullCutWithFeed"
});
await StarPrnt.print(portName: port.portName, emulation: 'StarGraphic',printCommands: commands)
```

## Android

Permissions required depending on your printer:

```xml
<uses-permission android:name="android.permission.INTERNET"></uses-permission>
<uses-permission android:name="android.permission.BLUETOOTH"></uses-permission>
```

## Work in progress

- [ ] Connect/disconnect function for persistent connection
- [ ] Helper function on appending print commands

## Documentation work in progress, please refer to react native or Ionic/Cordova's documentations for command format
