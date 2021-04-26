# Hesabe Payment Gateway Plugin

A flutter plugin for integrating Hesabe payment gateway. Supports Android and iOS. 

### Installing
Add this in pubspec.yaml
```
  dependencies:
    flutter_hesabe_payment: ^2.0.2
```
### iOS 9+ Specific
iOS developers should add the following to their plist
```
# Uncomment the next line to define a global platform for your project
# platform :ios, '10.0'

target 'PluginProject' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'CryptoSwift', '~> 1.0'
  pod 'Alamofire'
  # Pods for PluginProject

end
```

### Using
```
import 'package:flutter_hesabe_payment/flutter_hesabe_payment.dart';
```

```
startpayment() async {
    //Testing Credentials
    String credUrl = "http://api.hesbstck.com";
    String name = "JP";
    double price = 111.0;


    String EX_SECRET_KEY = "";
    String EX_IV_KEY = "";
    String EX_MERCHANT_CODE = "";
    String EX_ACCESS_CODE = "";

    String successURL = "";
    String cancelURL = "";

    String data;

    Map<dynamic, dynamic> map = {"cred_url":credUrl,
                              "name":name,
                              "price":price,
                              "secret_key":EX_SECRET_KEY,
      "iv_key":EX_IV_KEY,
      "merchant_code":EX_MERCHANT_CODE,
      "access_code":EX_ACCESS_CODE,
      "response_URL":successURL,
      "failure_URL":cancelURL};

    var response ;
    
    try {
           response = await FlutterMyfatoorah.payment(map);
        } on PlatformException {
            print('error');
        }
}
```
See the ```example``` directory for a complete sample app.

### Responses :
```
Sucess Response:
    all data about payment done in json string format

Error Response:
    cancelled by user: {"Error":"Payment Cancelled"}
  
    Gateway Errors: {"Error":"ssl error","responseCode":"500"}
```

