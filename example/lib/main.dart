import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_hesabe_payment/flutter_hesabe_payment.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String result = 'Tap Pay';

  @override
  void initState() {
    super.initState();
  }

  Future<void> startpayment() async {
    //test credentials
    String credUrl = "http://api.hesbstck.com";
    String name = "JP";
    double price = 111.0;


    String EX_SECRET_KEY = "OGzgrmqyDEnlALQRNvzPv8NJ4BwWM019";
    String EX_IV_KEY = "DEnlALQRNvzPv8NJ";
    String EX_MERCHANT_CODE = "1351719857300";
    String EX_ACCESS_CODE = "2a3789f5-edd1-416d-a472-4357794d6a8c";

    //ios
    //android

    String response_URL = "http://my.site.com/result/";
    String failure_URL = "http://my.site.com/result/";

    String data;

    Map<dynamic, dynamic> map = {"cred_url":credUrl,
                              "name":name,
                              "price":price,
                              "secret_key":EX_SECRET_KEY,
      "iv_key":EX_IV_KEY,
      "merchant_code":EX_MERCHANT_CODE,
      "access_code":EX_ACCESS_CODE,
      "response_URL":response_URL,
      "failure_URL":failure_URL};

    try {
          data = await FlutterHesabePayment.payment(map);
        } on PlatformException {
          data = 'Failed';
        }
    setState(() {
      result = data;
      print("++++"+result.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin Hesabe'),
        ),
        body:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  color: Colors.grey,
                  child: Text("Pay"), 
                  onPressed: (){
                    startpayment();
                  },
                ),
                SizedBox(),
                Text(result),
              ],
            ),
        ),
        ),
    ));
  }
  Future<bool> _onBackPressed() {
    print("bk++++");
  }
}
