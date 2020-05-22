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
                list.forEach((port) async {
                  print(port.portName);
                  if (port.portName.isNotEmpty) {
                    print(await FlutterStarPrnt.checkStatus(
                      portName: port.portName,
                      emulation: 'StarGraphic',
                    ));
                    print(await FlutterStarPrnt.connect(
                      portName: port.portName,
                      emulation: 'StarGraphic',
                    ));
                  }
                });
              },
              child: Text('test')),
        ),
      ),
    );
  }
}
