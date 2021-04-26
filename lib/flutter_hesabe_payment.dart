import 'dart:async';

import 'package:flutter/services.dart';

class FlutterHesabePayment {
  static const MethodChannel _channel =
      const MethodChannel('flutter_hesabe_payment');

  static Future<Map>  payment(Map<dynamic, dynamic> map) async {
    final Map data = await _channel.invokeMethod('payment',map);
    return data;
  }
}
