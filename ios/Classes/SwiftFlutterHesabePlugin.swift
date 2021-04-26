import Flutter
import UIKit


public class SwiftFlutterHesabePlugin: NSObject, FlutterPlugin, UINavigationControllerDelegate {
    
    var results : FlutterResult!
    var navigationController: UINavigationController?
    
    override init(){
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_hesabe_payment", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterHesabePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        results = result
        
        if(call.method.elementsEqual("payment"))
        {
            
            let arguments = call.arguments as! NSDictionary
            // let arguments = call.arguments as! [String:Any]
            
            var price : String!
            if let amount = arguments["price"] as? Double{
                price = String(amount)
            }else{
                price = "0.0"
            }
            
            
            print(arguments["orderReference"] )
            
            var paymentRequest_ = PaymentRequest(amount: price, merchantCode: arguments["merchant_code"] as? String ?? "", responseUrl: arguments["response_URL"] as? String ?? "", failureUrl: arguments["failure_URL"] as? String ?? "")
            
            paymentRequest_?.orderReferenceNumber = arguments["orderReference"] as? String ?? "" ;
            
            let vc = HesabeGatewayVC()
            vc.delegate = self
            vc.paymentRequest = paymentRequest_
            
            vc.url = arguments["cred_url"] as? String ?? ""
            
            vc.accessCode = arguments["access_code"] as? String ?? ""
            vc.merchantCode = arguments["merchant_code"] as? String ?? ""
            vc.merchantIV = arguments["iv_key"] as? String ?? ""
            vc.merchantKey = arguments["secret_key"] as? String ?? ""
            
            vc.responseURL = arguments["response_URL"] as? String ?? ""
            vc.failureURL = arguments["failure_URL"] as? String ?? ""
            
            
            vc.modalPresentationStyle = .overFullScreen // to
            
            let navigationController = UINavigationController(rootViewController: vc)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
}

extension SwiftFlutterHesabePlugin: HesabeGatewayVCDelegate {
    func paymentResponse(response: PaymentResponse?) {
        if let response = response {
            print(response.response.orderReferenceNumber!)
            results(["message":response.response.resultCode,"responseCode":response.code,"responseStatus":response.status])
        } else {
            results(["message":"UserClosed"])
        }
    }
}
