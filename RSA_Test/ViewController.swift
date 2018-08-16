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

        let test : String = "测试编码"

        guard let publicKeyPath = Bundle.main.path(forResource: "ios", ofType: "der") else {
            return
        }
        let encryptString = ATRSATool.encryptString(test, publicKeyWithContentsOfFile: publicKeyPath)

        guard let privateKeyPath = Bundle.main.path(forResource: "ios_private_key", ofType: "p12") else {
            return
        }
        let decpryptString = ATRSATool.decryptString(encryptString, privateKeyWithContentsOfFile: privateKeyPath, password: "")
        print(decpryptString ?? "")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

