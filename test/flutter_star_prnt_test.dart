import 'package:flutter/services.dart';
import 'package:flutter_star_prnt/flutter_star_prnt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_star_prnt');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('test appendTwoColumn', () async {
    final PrintCommands printCommands = PrintCommands();

    printCommands.push({
      'append': 'EAR BUDS SPECIAL SUPER BRAND DAY J-JINISO-ENCOBUDS',
      'align': 'Left',
    });
    printCommands.appendTwoColumn(
        leftText: '1 @ Rp 100.000.000,00', rightText: 'Rp 100.000.000,00');
    printCommands.appendTwoColumn(
        leftText: '1 @ Rp 100.000.000,00', rightText: 'Rp 100.000.000,00');

    final List<Map<String, dynamic>> result = printCommands.getCommands();
    final List<Map<String, dynamic>> expected = [
      {
        'append': 'EAR BUDS SPECIAL SUPER BRAND DAY J-JINISO-ENCOBUDS',
        'align': 'Left'
      },
      {'append': '1 @ Rp                        Rp'},
      {'append': '100.000.000,00    100.000.000,00'},
      {'append': '1 @ Rp                        Rp'},
      {'append': '100.000.000,00    100.000.000,00'},
    ];
    expect(result, expected);
  });
}
