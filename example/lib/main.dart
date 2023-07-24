import 'dart:typed_data';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_star_prnt/flutter_star_prnt.dart';
import 'dart:ui' as ui;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey _globalKey = new GlobalKey();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary? boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary!.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      print(e);
      return Uint8List(0);
    }
  }

  String emulationFor(String modelName) {
    String emulation = 'StarGraphic';
    if (modelName != '') {
      final em = StarMicronicsUtilities.detectEmulation(modelName: modelName);
      emulation = em!.emulation!;
    }
    return emulation;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: <Widget>[
            TextButton(
              onPressed: () async {
                List<PortInfo> list =
                    await StarPrnt.portDiscovery(StarPortType.All);
                print(list);
                list.forEach((port) async {
                  print(port.portName);
                  if (port.portName?.isNotEmpty != null) {
                    print(await StarPrnt.getStatus(
                      portName: port.portName!,
                      emulation: emulationFor(port.modelName!),
                    ));

                    PrintCommands commands = PrintCommands();
                    String raster = "        Star Clothing Boutique\n" +
                        "             123 Star Road\n" +
                        "           City, State 12345\n" +
                        "\n" +
                        "Date:MM/DD/YYYY          Time:HH:MM PM\n" +
                        "--------------------------------------\n" +
                        "SALE\n" +
                        "SKU            Description       Total\n" +
                        "300678566      PLAIN T-SHIRT     10.99\n" +
                        "300692003      BLACK DENIM       29.99\n" +
                        "300651148      BLUE DENIM        29.99\n" +
                        "300642980      STRIPED DRESS     49.99\n" +
                        "30063847       BLACK BOOTS       35.99\n" +
                        "\n" +
                        "Subtotal                        156.95\n" +
                        "Tax                               0.00\n" +
                        "--------------------------------------\n" +
                        "Total                           156.95\n" +
                        "--------------------------------------\n" +
                        "\n" +
                        "Charge\n" +
                        "156.95\n" +
                        "Visa XXXX-XXXX-XXXX-0123\n" +
                        "Refunds and Exchanges\n" +
                        "Within 30 days with receipt\n" +
                        "And tags attached\n";
                    commands.appendBitmapText(text: raster);
                    print(await StarPrnt.sendCommands(
                        portName: port.portName!,
                        emulation: emulationFor(port.modelName!),
                        printCommands: commands));
                  }
                });
              },
              child: Text('Print from text'),
            ),
            TextButton(
              onPressed: () async {
                //FilePickerResult file = await FilePicker.platform.pickFiles();
                List<PortInfo> list =
                    await StarPrnt.portDiscovery(StarPortType.All);
                print(list);
                list.forEach((port) async {
                  print(port.portName);
                  if (port.portName?.isNotEmpty != null) {
                    print(await StarPrnt.getStatus(
                      portName: port.portName!,
                      emulation: emulationFor(port.modelName!),
                    ));

                    PrintCommands commands = PrintCommands();
                    commands.appendBitmap(
                        path:
                            'https://c8.alamy.com/comp/MPCNP1/camera-logo-design-photograph-logo-vector-icons-MPCNP1.jpg');
                    print(await StarPrnt.sendCommands(
                        portName: port.portName!,
                        emulation: emulationFor(port.modelName!),
                        printCommands: commands));
                  }
                });
                setState(() {
                  isLoading = false;
                });
              },
              child: Text('Print from url'),
            ),
            SizedBox(
              width: 576, // 3'' only
              child: RepaintBoundary(
                key: _globalKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('This is a text to print as image , for 3\''),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final img = await _capturePng();
                setState(() {
                  isLoading = true;
                });
                //FilePickerResult file = await FilePicker.platform.pickFiles();
                List<PortInfo> list =
                    await StarPrnt.portDiscovery(StarPortType.All);
                print(list);

                list.forEach((port) async {
                  print(port.portName);
                  if (port.portName!.isNotEmpty) {
                    print(await StarPrnt.getStatus(
                      portName: port.portName!,
                      emulation: emulationFor(port.modelName!),
                    ));

                    PrintCommands commands = PrintCommands();
                    commands.appendBitmapByte(
                      byteData: img,
                      diffusion: true,
                      bothScale: true,
                      alignment: StarAlignmentPosition.Left,
                    );
                    print(await StarPrnt.sendCommands(
                        portName: port.portName!,
                        emulation: emulationFor(port.modelName!),
                        printCommands: commands));
                  }
                });
                setState(() {
                  isLoading = false;
                });
              },
              child: Text('Print from genrated image'),
            ),
          ],
        ),
      ),
    );
  }
}
