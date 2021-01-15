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
            
            eth.getERC20TokenBalance(tokenContractAddress: "0x2f73393abedd4af33c97cbc3d8abb35dd48cd3d1", walletAddress: "0xd139b1d6094feb5e8018aad5e23d7ec4b8f0d0a4")
//
//             eth.sendEther(walletAddress: "0x8E63bD8e5d31D960c60be06bE61Ad554DB216724", password: "2132", receiverAddress: "0x0D6CB8a9d1AE75e5110294dc4C29a22E591EC63d", tokenAmount: "0", gasPrice: 0, gasLimit: 0)
        }
       
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

