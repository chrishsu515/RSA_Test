//
//  ViewController.swift
//  RSA_Test
//
//  Created by Chris on 2018/7/16.
//  Copyright © 2018年 Chris. All rights reserved.
//

import UIKit
import CoreFoundation
import Security


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let rsa : RSAWrapper? = RSAWrapper()
//        if !(rsa?.initKey())! {
//            print("Failed")
//            return
//        }
//        let success : Bool = (rsa?.generateKeyPair(keySize: 1024, privateTag: "com.privateTag", publicTag: "com.publicTag"))!
//        if (!success) {
//            print("Failed")
//            return
//        }
//        print(rsa?.getPublicKey() ?? nil)
        let test : String = "测试编码"
//        let data = rsa?.encrypt(text: test)
//        let transData : Data = (data?.base64EncodedData(options: Data.Base64EncodingOptions(rawValue: 0)))!
//        let str = String.init(data: transData, encoding: String.Encoding.utf8)

//        let encryptString = (rsa?.encryptBase64(text: test))!
//        print(encryptString)
        guard let publicKeyPath = Bundle.main.path(forResource: "ios", ofType: "der") else {
            return
        }
        let encryptString = ATRSATool.encryptString(test, publicKeyWithContentsOfFile: publicKeyPath)

        guard let privateKeyPath = Bundle.main.path(forResource: "ios_private_key", ofType: "p12") else {
            return
        }
        let decpryptString = ATRSATool.decryptString(encryptString, privateKeyWithContentsOfFile: privateKeyPath, password: "")
        print(decpryptString)
//        let encryptString = "IJC8qRFfLJqV3J9LIin8AeSJwCxTOZxaomTotNztGNT8epu0rrUp1L5coEo6xKOXEztr2ixkQS6UNYCV3Rdl+5TIo5TWeOYi7P5apr1uBcaxppg2qXA5jIo183NgR3nVE25/H0FIL5qXiw48RXAfhsLtg74zY/d/qEeYGYkwCuk="
//        let decpryptString = rsa?.decpryptBase64(encrpted: encryptString)
//        print(decpryptString)
//        let decription = rsa?.decprypt(encrpted: encryption!)
//        print(decription)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class RSAWrapper {

    private var publicKey : SecKey?
    private var privateKey : SecKey?

    func generatePublicKey() -> SecKey? {
        let key = "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJbdMdC0Mhnlvo9nUsMoex8nMlBbh+Wo/KS8cJOWREM/0ENWfCumbUrYnIkP4gmfvdnwW3AR6HMhEwFEydFup5sbyVvRmYj3o2IcjJjWYbZwjr3UnhKTrKYlbmrle2QWVTcFuRnyEyMUjlxQFG00PUCBT8ELkaXHfWDwoI39kRGwIDAQAB\n-----END PUBLIC KEY-----"
        let keyData = key.data(using: String.Encoding.ascii)
//        let publicTag = ""
//        let publicKeyParameters: [NSString: AnyObject] = [
//            kSecAttrIsPermanent: true as AnyObject,
//            kSecAttrApplicationTag: publicTag as AnyObject
//        ]

        var error: Unmanaged<CFError>?
        var secKey : SecKey?
        if #available(iOS 10.0, *) {
            secKey = SecKeyCreateWithData(keyData! as CFData, NSDictionary(), &error)
            if error != nil {
                print(error.debugDescription)
            }
        }else {
            // Fallback on earlier versions
        }
        return secKey
        //        let secKey = SecKeyCreateFromData(NSDictionary(), pubKeyData!, &error)
    }

    func generatePublicKeyWithFile() -> SecKey? {

        guard let keyPath = Bundle.main.path(forResource: "ios", ofType: "der") else {
            return nil
        }
        let keyData = NSData(contentsOfFile: keyPath)

        var key : SecKey?
        var trust : SecTrust?
        var policy : SecPolicy?

        if let cert = SecCertificateCreateWithData(nil, keyData!) {
            policy = SecPolicyCreateBasicX509()
            if  policy != nil {
                if SecTrustCreateWithCertificates(cert, policy, &trust) == noErr {

                    var result = SecTrustResultType.init(rawValue: 0)
                    if SecTrustEvaluate(trust!, &result!)  == noErr {
                        key = SecTrustCopyPublicKey(trust!)
                    }
                }
            }

        }
        return key
    }

    func generatePrivateKey() -> SecKey? {
        var secKey : SecKey?
        let key = "MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAKRtqpLqfgXIhlhig0aF0E98Itnl+9OG5e6KSP0NDmDrVPY+famhYyVblZNKy0FLSmvpvOys/NkMQEBNE6glWneUQkhOAhKhq6P7dV1dghLRng9NLtn2IYcpTnio2yslOOl6UdItcP80arY3kOwlAPRGaL+7g6GuB2gZXBkQcX11AgMBAAECgYEAlMpIGDnpYAJcz44VjLN6FPMX9mWOw5LGblzkP1iZMkrBzzItNFq+BQgjCe4cjzE6Xvxb4S+Ifj//xC/7IaTrfuBFUrVMqq6uMaDyMvr9qBoRrPr0psYUPUM7Zhv/FvqllIfr+4b54VzzFHh30o6CxblM54cvEU3Aq92Ee+H0ReECQQD2JPaEyvskATHs30WhLtJ7ITAOMi61gHTWoZUERpcdNnnHr/im/L2Yb3+iZsJxvw6PM2I9rrj7g2eh7rOfqMGDAkEAqwMYafBU8mL+VmZ87qNs/cwHJbN77d91v5et+tLdVt2F6fQPYqdUm6a8sncpFfeHCmOr71nLHY/xjkC0C+jrpwJAJ/VCK7aD5IlpIGnydMMUGjb+BR/yYzaSQRGEDmijOXPRezA+7mTTJn7bOnLyF+MLKwYNabQGhZYEac5FTKLpnwJBAJwxfZD1E4E3bXnYre8AkUHVogmLP3vqB4/wp9VZ1xPJzM/8PDktABgSWHLgZ0RLCqowkw9QAjaEDGqTKl9eZC0CQQCxyxAZM4+FiKiv1/EsTVk4f2rPpv4DHuHJsF7PBcE3uoYGhUAxIQHaHNPJcwFhk09WOb+kSMgQ/KW2Xs18+TiU"
        let keyData = key.data(using: String.Encoding.ascii)

        var error: Unmanaged<CFError>?
        if #available(iOS 10.0, *) {
            secKey = SecKeyCreateWithData(keyData! as CFData, NSDictionary(), &error)
        } else {
            // Fallback on earlier versions
        }
        return secKey

    }

    func generatePrivateKeyWithFile() -> SecKey? {

//        guard let keyPath = Bundle.main.path(forResource: "ios_private_key", ofType: "p12") else {
//            return nil
//        }

//        let keyData = NSData(contentsOfFile: keyPath)
//
        var key : SecKey?
//        let options = NSMutableDictionary()
//        options.setObject("", forKey: kSecImportExportPassphrase as! NSCopying)
//        var items = CFArrayCreate(nil, nil, 0, nil)
//
//        let securityError = SecPKCS12Import(keyData!, options, &items)
//        if securityError == noErr && CFArrayGetCount(items) > 0 {
//
//            let identityDict : CFDictionary = CFArrayGetValueAtIndex(items, 0) as! CFDictionary
//            var secImportItemIdentity = kSecImportItemIdentity
//            let identityApp : SecIdentity = CFDictionaryGetValue(identityDict, &secImportItemIdentity) as! SecIdentity
//            let _ = SecIdentityCopyPrivateKey(identityApp, &key)
//
//        }
        return key

    }

//    func initKey() -> Bool {
//        publicKey = generatePublicKey()
//        privateKey = generatePrivateKey()
//        return (publicKey != nil && privateKey != nil)
//    }
    func initKey() -> Bool {

        return (publicKey != nil)
    }

    func generateKeyPair(keySize: UInt, privateTag: String, publicTag: String) -> Bool {

//        publicKey = generatePublicKey()
        publicKey = nil
//        privateKey = generatePrivateKey()
        privateKey = nil
        if (keySize != 512 && keySize != 1024 && keySize != 2048) {
            // Failed
            print("Key size is wrong")
            return false
        }

        let publicKeyParameters: [NSString: AnyObject] = [
            kSecAttrIsPermanent: true as AnyObject,
            kSecAttrApplicationTag: publicTag as AnyObject
        ]
        let privateKeyParameters: [NSString: AnyObject] = [
            kSecAttrIsPermanent: true as AnyObject,
            ]

        let parameters: [String: AnyObject] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: keySize as AnyObject,
            kSecPrivateKeyAttrs as String: privateKeyParameters as AnyObject,
            kSecPublicKeyAttrs as String: publicKeyParameters as AnyObject
        ];

        let status : OSStatus = SecKeyGeneratePair(parameters as CFDictionary, &(self.publicKey), &(self.privateKey))
        return (status == errSecSuccess && self.publicKey != nil && self.privateKey != nil)
    }

//    func encrypt(text: String) -> [UInt8] {
//        let plainBuffer = [UInt8](text.utf8)
//        var cipherBufferSize : Int = Int(SecKeyGetBlockSize((self.publicKey)!))
//        var cipherBuffer = [UInt8](repeating:0, count:Int(cipherBufferSize))
//
//        // Encrypto  should less than key length
//        let status = SecKeyEncrypt((self.publicKey)!, SecPadding.PKCS1, plainBuffer, plainBuffer.count, &cipherBuffer, &cipherBufferSize)
//
//
//        if (status != errSecSuccess) {
//            print("Failed Encryption")
//        }
//        return cipherBuffer
//
//    }

    func encrypt(text: String) -> Data {
        let plainBuffer = [UInt8](text.utf8)
        var cipherBufferSize : Int = Int(SecKeyGetBlockSize((self.publicKey)!))
        var cipherBuffer = [UInt8](repeating:0, count:Int(cipherBufferSize))
        var data = NSMutableData()
        // Encrypto  should less than key length
        let status = SecKeyEncrypt((self.publicKey)!, SecPadding.PKCS1, plainBuffer, plainBuffer.count, &cipherBuffer, &cipherBufferSize)


        if (status != errSecSuccess) {
            print("Failed Encryption")
        } else {
            data =  NSMutableData(bytes: cipherBuffer, length: cipherBufferSize)
        }
        //        return cipherBuffer
        return data as Data
    }

    func decprypt(encrpted: [UInt8]) -> String? {
        var plaintextBufferSize = Int(SecKeyGetBlockSize((self.privateKey)!))
        var plaintextBuffer = [UInt8](repeating:0, count:Int(plaintextBufferSize))

        let status = SecKeyDecrypt((self.privateKey)!, SecPadding.PKCS1, encrpted, plaintextBufferSize, &plaintextBuffer, &plaintextBufferSize)

        if (status != errSecSuccess) {
            print("Failed Decrypt")
            return nil
        }
        return NSString(bytes: &plaintextBuffer, length: plaintextBufferSize, encoding: String.Encoding.utf8.rawValue)! as String
    }

    func encryptBase64(text: String) -> String {
        let plainBuffer = [UInt8](text.utf8)
        var cipherBufferSize : Int = Int(SecKeyGetBlockSize((self.publicKey)!))
        var cipherBuffer = [UInt8](repeating:0, count:Int(cipherBufferSize))

        // Encrypto  should less than key length
        let status = SecKeyEncrypt((self.publicKey)!, SecPadding.PKCS1, plainBuffer, plainBuffer.count, &cipherBuffer, &cipherBufferSize)
        if (status != errSecSuccess) {
            print("Failed Encryption")
        }

        let mudata = NSData(bytes: &cipherBuffer, length: cipherBufferSize)
        return mudata.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
    }

    func decpryptBase64(encrpted: String) -> String? {

        let data : NSData = NSData(base64Encoded: encrpted, options: .ignoreUnknownCharacters)!
//        print(String.init(data: data as Data, encoding: String.Encoding(rawValue: String.Encoding.ascii.rawValue)))
        let count = data.length / MemoryLayout<UInt8>.size
        var array = [UInt8](repeating: 0, count: count)
        data.getBytes(&array, length:count * MemoryLayout<UInt8>.size)
//        print(String.init(data: data as Data, encoding: String.Encoding(rawValue: String.Encoding.ascii.rawValue)))
        var plaintextBufferSize = Int(SecKeyGetBlockSize((self.privateKey)!))
        var plaintextBuffer = [UInt8](repeating:0, count:Int(plaintextBufferSize))

        let status = SecKeyDecrypt((self.privateKey)!, SecPadding.PKCS1, array, plaintextBufferSize, &plaintextBuffer, &plaintextBufferSize)

        if (status != errSecSuccess) {
            if #available(iOS 11.3, *) {
                print(SecCopyErrorMessageString(status, nil)!)
            } else {
                // Fallback on earlier versions
            }
//            print("Failed Decrypt")
            return nil
        }

        return NSString(bytes: &plaintextBuffer, length: plaintextBufferSize, encoding: String.Encoding.utf8.rawValue)! as String
    }


    func getPublicKey() -> String? {
        return self.publicKey.debugDescription
    }

    func getPrivateKey() -> String? {
        return self.privateKey.debugDescription
    }


}

