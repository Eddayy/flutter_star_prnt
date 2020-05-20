import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_star_prnt/flutter_star_prnt.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_star_prnt');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    print(await FlutterStarPrnt.platformVersion);
    expect(await FlutterStarPrnt.platformVersion, '42');
  });

  test('portDiscovery', () async {
    print(await FlutterStarPrnt.portDiscovery('all'));
    expect(await FlutterStarPrnt.portDiscovery('all'), '31');
  });
}
