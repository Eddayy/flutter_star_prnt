import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_star_prnt/flutter_star_prnt.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FlatButton(
              onPressed: () async {
                List<PortInfo> list =
                    await FlutterStarPrnt.portDiscovery(PortType.all);
                print(list);
                print('test');
                list.forEach((port) async {
                  print(port.portName);
                  if (port.portName.isNotEmpty) {
                    print(await FlutterStarPrnt.checkStatus(
                      portName: port.portName,
                      emulation: 'StarGraphic',
                    ));

                    PrntCommands commands = PrntCommands();
                    Map<String, dynamic> rasterMap = {
                      'appendBitmapText': "        Star Clothing Boutique\n" +
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
                          "And tags attached\n",
                      'fontSize': 25, //Defaults to 25
                    };
                    commands.push(rasterMap);
                    print(await FlutterStarPrnt.print(
                        portName: port.portName,
                        emulation: 'StarGraphic',
                        printCommands: commands));
                  }
                });
              },
              child: Text('test')),
        ),
      ),
    );
  }
}
