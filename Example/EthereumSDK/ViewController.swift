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
        
        let eth = EthWalletManager.init(infuraUrl: "https://ropsten.infura.io/v3/a396c3461ac048a59f389c7778f06689")
        
        DispatchQueue.global(qos: .background).async {
            
            
            do {
//                // 1. Wallet Create
//                var wallet = try eth.createWallet(walletPassword: "12345")
//                print(wallet)
//                // 2. Export Keystore
//                var keysotre = try eth.exportKeystore(walletAddress: (wallet?.walletAddress)!)
//                print(keysotre)
//                // 3. Export Private Key
//                var privateKey = try eth.exportPrivateKey(walletAddress:  "0x9c6f19f15ac5b9fff867ca1f5a41d10b4c6ed1b5", password: "12345")
//                print(privateKey)
                // 4. Import Keystore
//                var keystore = ""
//                var wallet = try eth.importByKeystore(keystore: keystore, password: "12345")
//                print(wallet)
                // 5. Import Private Key
//                var wallet = try eth.importByPrivateKey(privateKey: "")
//                print(wallet)
                // 6. Ether Balance
//                var etherBalance = try eth.getEtherBalance(walletAddress: "0x38C1E1204C10C8be90ecA671Da8Ea8a9AEb16031")
//                print(etherBalance)
                // 7. ERC20 Token Balance
//                var tokenBalance = try eth.getERC20TokenBalance(tokenContractAddress: "0x4b9a509e3290f2e510474f747e27e5ce271565f9", walletAddress: "0x38C1E1204C10C8be90ecA671Da8Ea8a9AEb16031")
//                print(tokenBalance)
                // 8. Send Ether
//                var tx = try eth.sendEther(walletAddress: "0x9c6f19f15ac5b9fff867ca1f5a41d10b4c6ed1b5", password: "12345", receiverAddress: "0x38C1E1204C10C8be90ecA671Da8Ea8a9AEb16031", etherAmount: "0.03", gasPrice: 51, gasLimit: 21000)
//                print(tx)
                // 9. Send ERC20 Token
//                var tx = try eth.sendERC20Token(walletAddress: "0x9c6f19f15ac5b9fff867ca1f5a41d10b4c6ed1b5", password: "12345", receiverAddress: "0x38C1E1204C10C8be90ecA671Da8Ea8a9AEb16031", tokenAmount: "123", tokenContractAddress: "0x4df68db57412cc1418e108d31f4e1bd48e4cc83e", gasPrice: 52, gasLimit: 50000)
//                print(tx)
                
            } catch {
                print(error)
            }
            
           
            
           
//             eth.sendEther(walletAddress: "0x8E63bD8e5d31D960c60be06bE61Ad554DB216724", password: "2132", receiverAddress: "0x0D6CB8a9d1AE75e5110294dc4C29a22E591EC63d", tokenAmount: "0", gasPrice: 0, gasLimit: 0)
            
            
//          var balance =   eth.getERC20TokenBalance(tokenContractAddress: "0x4df68db57412cc1418e108d31f4e1bd48e4cc83e", walletAddress: "0x38C1E1204C10C8be90ecA671Da8Ea8a9AEb16031")
//            print(balance)
        }
       
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

