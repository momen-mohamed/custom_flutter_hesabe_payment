import 'package:flutter/services.dart';
import 'package:flutter_hesabe_payment/flutter_hesabe_payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_hesabe_payment');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterHesabePayment.payment, '42');
  });
}
