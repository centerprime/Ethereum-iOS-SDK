//
//  ViewController.swift
//  EthereumSDK
//
//  Created by centerprime on 01/15/2021.
//  Copyright (c) 2021 centerprime. All rights reserved.
//

import UIKit

import EthereumSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let eth = EthWalletManager.init(infuraUrl: "https://ropsten.infura.io/v3/a396c3461ac048a59f389c7778f06689")
        
        DispatchQueue.global(qos: .background).async {
             eth.createWallet(walletPassword: "12345")
        }
       
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

