import UIKit
import WebKit
import Alamofire

class HesabeGatewayVC: UIViewController {
    
    weak var delegate: HesabeGatewayVCDelegate?
    
    private var AES = HesabeCrypt()
    
    var url: String!
    var accessCode: String!
    var merchantKey: String!
    var merchantIV: String!
    var merchantCode: String!
    var responseURL: String!
    var failureURL: String!
    var rescivedResults = false
    var isInitial = true
    var activityIndicator = UIActivityIndicatorView()
    var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.alpha = 0
        return blurView
    }()
    private var headers: HTTPHeaders {
        ////return ["accessCode": ACCESS_CODE]
        return ["accessCode": accessCode]
    }
    
    
    /// The view to load the payment gateway
    var webView: WKWebView!
    
    /// The property stores the data to be sent while requesting payment token
    /// for eg - var paymentRequest = PaymentRequest(code: "1351719857300", responseUrl: "http://api.hesbstaging.com", failureUrl: "http://api.hesbstaging.com")
    var paymentRequest: PaymentRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkout(paymentRequest: paymentRequest!)
    }
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationController()
        self.view.backgroundColor = .white;
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        
        //activityIndicator.isHidden = true
        
        webView.addSubview(activityIndicator);
        activityIndicator.transform = .init(scaleX: 1.5, y: 1.5)
        
        
        
        blurView.frame = view.bounds
        
        webView.addSubview(blurView)
        
        webView.bringSubviewToFront(activityIndicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isInitial){
            UIView.animate(withDuration: 0.3) {
                self.blurView.alpha = 0.8
            }
            isInitial = false
        }
    }
    
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
            UIView.animate(withDuration: 0.3) {
                self.blurView.alpha = 0.8
            }
        } else {
            activityIndicator.stopAnimating()
            UIView.animate(withDuration: 0.3) {
                self.blurView.alpha = 0
            }
        }
    }
    
    func setupNavigationController() {
        
        self.navigationItem.setRightBarButton(.init(barButtonSystemItem: .done, target: self, action: #selector(dimsissView)), animated: true)
    }
    
    @objc func dimsissView(){
        
        self.dismiss(animated: true, completion: nil);
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard rescivedResults == false else { return }
        delegate?.paymentResponse(response: nil)
    }
    
    
}

// MARK: - Function
extension HesabeGatewayVC {
    
    /// Create request for Payment Token
    func checkout(paymentRequest: PaymentRequest) {
        
        self.AES?.merchantKey = self.merchantKey
        self.AES?.merchantIV = self.merchantIV
        self.AES?.setData()
        
        let paymentRequestJson = try! JSONEncoder().encode(paymentRequest)
        guard let paymentRequestEncrypted = AES?.encrypt(data: paymentRequestJson) else { return }
        let parameters = ["data": paymentRequestEncrypted]
        AF.request(URL(string:self.url.appending("/checkout"))!, method: .post, parameters: parameters, headers: headers).responseString { response in
            switch response.result {
            case .success(let encryptedResponse):
                //                guard let encryptedResponse = response.result.value else { return }
                self.checkoutResponse(response: encryptedResponse)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Update Payment Token response
    func checkoutResponse(response encryptedResponse: String) {
        let decryptedResponse = AES?.decrypt(data: encryptedResponse)
        guard let responseJson = decryptedResponse?.data(using: .utf8) else { return }
        let result = try? JSONDecoder().decode(PaymentToken.self, from: responseJson)
        if result?.code == 200, let token = result?.response.data {
            self.redirectToPayment(with: token)
        }else{
            let alert = UIAlertController(title: "Payment Failure", message: result?.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
                self.navigationController?.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Redirect to payment gateway to complete the process
    func redirectToPayment(with token: String) {
        let url = self.url.appending("/payment?data=") + token
        let request = URLRequest(url: URL(string: url)!)
        self.webView.load(request);
    }
}

// MARK: - WKWebView
extension HesabeGatewayVC: WKNavigationDelegate, WKUIDelegate {
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.showActivityIndicator(show: false);
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
    
    /**
     The gateway URL are handled here. On load of every new url in gateway, the method is being called.
     The `decisionHandler()` allows the method to proceed further or stop processing.
     Here, If the response URL is being called, the process is being stopped to extract the data from that url and proceed to update response.
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        /// Process the response after the transaction is complete. To use this method, make sure your SuccessUrl or FailureUrl points to this method in which you'll receive a "data" paramas a GET request. Then you can process it accordingly.
        if url.absoluteString.contains("\(self.responseURL ?? "")/?data") || url.absoluteString.contains("\(self.failureURL ?? "")/?data") {
            decisionHandler(.cancel)
            let urlComponents = url.absoluteString.components(separatedBy: "=")
            let encryptedResponse = urlComponents[1]
            self.paymentResponse(response: encryptedResponse)
        } else {
            decisionHandler(.allow)
        }
    }
    
    /// Updates Payment response post completion
    func paymentResponse(response encryptedResponse: String) {
        let decryptedResponse = AES?.decrypt(data: encryptedResponse)
        guard let responseJson = decryptedResponse?.data(using: .utf8) else { return }
        var paymentResponse = try? JSONDecoder().decode(PaymentResponse.self, from: responseJson)
        if (paymentResponse == nil ) {
            let newResponseString = decryptedResponse?.components(separatedBy: "}}").first?.appending("}}")
            guard let responseJson = newResponseString?.data(using: .utf8) else { return }
            paymentResponse = try? JSONDecoder().decode(PaymentResponse.self, from: responseJson)
        }
        
        self.rescivedResults.toggle()
        self.delegate?.paymentResponse(response: paymentResponse!)
        
        self.dismiss(animated: true, completion: nil);
    }
}

// MARK: - Protocol and Delegate
protocol HesabeGatewayVCDelegate: class {
    func paymentResponse(response: PaymentResponse?)
}
