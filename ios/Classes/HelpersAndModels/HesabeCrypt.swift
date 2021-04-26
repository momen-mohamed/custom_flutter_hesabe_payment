import Foundation
import CryptoSwift

struct HesabeCrypt {

    // MARK: - Value
    // MARK: Private
    private var key: Data
    private var iv: Data

    var merchantKey: String!
    var merchantIV: String!
    
    // MARK: - Initialzier
    init?() {
        guard let keyData = MERCHANT_KEY.data(using: .utf8) else {
            debugPrint("Error: Failed to set a key.")
            return nil
        }
        
        guard let ivData = MERCHANT_IV.data(using: .utf8) else {
            debugPrint("Error: Failed to set an initial vector.")
            return nil
        }

        self.key = keyData
        self.iv  = ivData
    }
    
    mutating func setData(){
        guard let keyData = merchantKey.data(using: .utf8) else {
            debugPrint("Error: Failed to set a key.")
            return
        }

        guard let ivData = merchantIV.data(using: .utf8) else {
            debugPrint("Error: Failed to set an initial vector.")
            return
        }

        self.key = keyData
        self.iv  = ivData
    }

    // MARK: - Function
    // MARK: Public
    
    /// AES Encryption Method using `CryptoSwift` dependency.
    func encrypt(data: Data) -> String? {
        let encrypted = try? AES(key: Array(self.key), blockMode: CBC(iv: Array(self.iv)), padding: .pkcs5).encrypt(Array(data))
        return encrypted?.toHexString()
    }
    
    /// AES Decryption Method using `CryptoSwift` dependency.
    func decrypt(data: String) -> String? {
        guard let key = String(data: self.key, encoding: .utf8), let iv = String(data: self.iv, encoding: .utf8) else { return nil }
        let aes = try? AES(key: key, iv: iv)
        let byteArray = Array<UInt8>(hex: data)
        if let decrypted = try? aes!.decrypt(byteArray) {
            return String(data: Data(decrypted), encoding: .utf8)
        }
        return nil
    }
}
