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
//             eth.sendEther(walletAddress: "0x8E63bD8e5d31D960c60be06bE61Ad554DB216724", password: "2132", receiverAddress: "0x0D6CB8a9d1AE75e5110294dc4C29a22E591EC63d", tokenAmount: "0", gasPrice: 0, gasLimit: 0)
            
            
          var balance =   eth.getERC20TokenBalance(tokenContractAddress: "0x4df68db57412cc1418e108d31f4e1bd48e4cc83e", walletAddress: "0x38C1E1204C10C8be90ecA671Da8Ea8a9AEb16031")
            print(balance)
        }
       
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

