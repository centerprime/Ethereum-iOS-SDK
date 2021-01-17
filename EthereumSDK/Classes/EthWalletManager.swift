//
//  Created by Centerprime on 14/01/2021.
//  Copyright © 2021 Centerprime. All rights reserved.
//

import Foundation
import web3swift
import SwiftyJSON
import Alamofire
import BigInt

public final class EthWalletManager {

    var infuraUrl = "";
    var web3Manager:  web3

    public init(infuraUrl : String) {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        self.infuraUrl = infuraUrl;
        self.web3Manager = web3(provider: Web3HttpProvider(URL(string: infuraUrl)!)!)
        self.web3Manager.addKeystoreManager(keystoreManager)
    }

    
    /* Wallet Create */
    public func createWallet(walletPassword : String) -> Wallet? {
        var mapToUpload = [String: Any]()
        mapToUpload["network"] = isMainnet() ? "MAINNET" : "TESTNET"
        mapToUpload["action_type"] = "WALLET_CREATE"
        do {
                let ks = try EthereumKeystoreV3(password : walletPassword, aesMode: "aes-128-ctr")
                // encode json
                let jsonEncoder = JSONEncoder()
                let keydata = try jsonEncoder.encode(ks!.keystoreParams)
                let walletAddress = ks?.addresses?.first
    
                let keystore = String(data: keydata, encoding: String.Encoding.utf8)
   
                writeToFile(fileName: walletAddress!.address, keystore: keydata)

                mapToUpload["wallet_address"] = walletAddress?.address
                mapToUpload["status"] = "SUCCESS"
                self.sendToHyperLedger(map: mapToUpload)
            
            return Wallet(keystore: keystore!, walletAddress: walletAddress!.address)
        } catch {
              mapToUpload["status"] = "FAILURE"
              print(error.localizedDescription);
              self.sendToHyperLedger(map: mapToUpload)
              return nil
            
        }
    }
    
    /* Import Wallet By Keystore */
    public func importByKeystore(keystore : String , password : String) -> Wallet? {
        var mapToUpload = [String: Any]()
        mapToUpload["network"] = isMainnet() ? "MAINNET" : "TESTNET"
        mapToUpload["action_type"] = "WALLET_IMPORT_KEYSTORE"
        do {
            let decoder = JSONDecoder()
            let json = JSON.init(parseJSON:keystore)
            let keystoreData: Data =  try JSONEncoder().encode(json)// Load keystore data from file?
            let keystore1 = try decoder.decode(Keystore.self, from: keystoreData)
            _ = try keystore1.privateKey(password: password)
            let walletAddress = keystore1.address

            
            writeToFile(fileName: walletAddress, keystore: keystoreData)

            mapToUpload["wallet_address"] = walletAddress
            mapToUpload["status"] = "SUCCESS"
            self.sendToHyperLedger(map: mapToUpload)
            return Wallet(keystore: keystore, walletAddress: walletAddress)
        } catch {
            print(error.localizedDescription)
            mapToUpload["status"] = "FAILURE"
            self.sendToHyperLedger(map: mapToUpload)
            return nil
        }
    }
    
    /* Import Wallet By Private Key */
    public func importByPrivateKey(privateKey : String ) -> Wallet? {
        var mapToUpload = [String: Any]()
        mapToUpload["network"] = isMainnet() ? "MAINNET" : "TESTNET"
        mapToUpload["action_type"] = "WALLET_IMPORT_PRIVATE_KEY"
        do {
            let privateKeyData = Data.fromHex(privateKey)
            let password = ""
            let ks = try EthereumKeystoreV3(privateKey: privateKeyData!, password: password ,aesMode: "aes-128-ctr")
            let jsonEncoder = JSONEncoder()
            let keydata = try jsonEncoder.encode(ks?.keystoreParams)
            
            let walletAddress = ks?.addresses?.first
            
            let keystore = String(data: keydata, encoding: String.Encoding.utf8)
            
            writeToFile(fileName: walletAddress!.address, keystore: keydata)

            mapToUpload["wallet_address"] = walletAddress
            mapToUpload["status"] = "SUCCESS"
            self.sendToHyperLedger(map: mapToUpload)
            return Wallet(keystore: keystore, walletAddress: walletAddress?.address)
        } catch {
            print(error.localizedDescription)
            mapToUpload["status"] = "FAILURE"
            self.sendToHyperLedger(map: mapToUpload)
            return nil
        }
    }
    
    
    /* Export Private Key */
    func exportPrivateKey(walletAddress : String, password : String ) -> [UInt8]{
        var mapToUpload = [String: Any]()
        mapToUpload["network"] = isMainnet() ? "MAINNET" : "TESTNET"
        mapToUpload["action_type"] = "WALLET_EXPORT_PRIVATE_KEY"
        do {
            let decoder = JSONDecoder()
            let keystore = exportKeystore(walletAddress: walletAddress)
            let json = JSON.init(parseJSON:keystore)
            let keystoreData: Data =  try JSONEncoder().encode(json)// Load keystore data from file?
            let keystore1 = try decoder.decode(Keystore.self, from: keystoreData)
            let privateKey = try keystore1.privateKey(password: password)
            mapToUpload["wallet_address"] = walletAddress
            mapToUpload["status"] = "SUCCESS"
            self.sendToHyperLedger(map: mapToUpload)
            return privateKey
        } catch {
            print(error.localizedDescription)
            mapToUpload["wallet_address"] = walletAddress
            mapToUpload["status"] = "FAILURE"
            self.sendToHyperLedger(map: mapToUpload)
            return [0]
        }
    }
    
    /* Export Keystore */
    func exportKeystore(walletAddress : String ) -> String {
        var mapToUpload = [String: Any]()
        mapToUpload["network"] = isMainnet() ? "MAINNET" : "TESTNET"
        mapToUpload["action_type"] = "WALLET_EXPORT_PRIVATE_KEY"
        do {
            let ks = findKeystoreMangerByAddress(walletAddress: walletAddress)
            let jsonEncoder = JSONEncoder()
            let keydata = try jsonEncoder.encode(ks?.keystoreParams)
            let keystore = String(data: keydata, encoding: String.Encoding.utf8)
            mapToUpload["wallet_address"] = walletAddress
            mapToUpload["status"] = "SUCCESS"
            self.sendToHyperLedger(map: mapToUpload)
            return keystore!
        } catch {
            mapToUpload["wallet_address"] = walletAddress
            mapToUpload["status"] = "FAILURE"
            self.sendToHyperLedger(map: mapToUpload)
            return error.localizedDescription
        }
    }
    
    /* Get Ether Balance */
    public func getEtherBalance (walletAddress : String ) -> String? {
        do {
            var mapToUpload = [String: Any]()
            mapToUpload["network"] = isMainnet() ? "MAINNET" : "TESTNET"
            mapToUpload["action_type"] = "COIN_BALANCE"
            let etherAddress = EthereumAddress(walletAddress)
            let balancebigint = try self.web3Manager.eth.getBalance(address: etherAddress!)
            let etherBalance  = (String(describing: Web3.Utils.formatToEthereumUnits(balancebigint )!))
            print(etherBalance)
            mapToUpload["status"] = "SUCCESS"
            mapToUpload["balance"] = etherBalance
            self.sendToHyperLedger(map: mapToUpload)
            return etherBalance
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /* Get ERC20 Token Balance */
    public func getERC20TokenBalance (tokenContractAddress : String , walletAddress : String ) -> String? {
        do {
            let contractAddress = EthereumAddress(tokenContractAddress)
            let contract = self.web3Manager.contract(Web3Utils.erc20ABI, at: contractAddress, abiVersion: 2)!
            let tokenName = try contract.method("name")?.call()
            let tokenSymbol = try contract.method("symbol")?.call()
            let decimals = try contract.method("decimals")?.call()
            let balance = try contract.method("balanceOf", parameters: [walletAddress] as [AnyObject], extraData: Data(), transactionOptions: TransactionOptions.defaultOptions)?.call()
            
            let numStr = decimals!["0"] as! BigUInt
            let decimal = Double(String(numStr))

            let balanceStr = balance!["0"] as! BigUInt
            let tokenBalance = Double(String(balanceStr))
            let tokenBal = tokenBalance!/pow(10, decimal!)

            var mapToUpload = [String: Any]()
            mapToUpload["network"] = isMainnet() ? "MAINNET" : "TESTNET"
            mapToUpload["action_type"] = "TOKEN_BALANCE"
            mapToUpload["wallet_address"] = walletAddress
            mapToUpload["token_smart_contract"] = tokenContractAddress
            mapToUpload["token_name"] = tokenName!["0"]!
            mapToUpload["token_symbol"] = tokenSymbol!["0"]!
            mapToUpload["balance"] = balance
            mapToUpload["status"] = "SUCCESS"
            
            self.sendToHyperLedger(map: mapToUpload)
            
            return String(tokenBal)

        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /* Send ERC20 Token */
    public func sendERC20Token(walletAddress : String , password : String , receiverAddress : String , tokenAmount : String, gasPrice : Double, gasLimit : Double, tokenContractAddress : String) -> String? {
        
        do {
            
            if (findKeystoreMangerByAddress(walletAddress: walletAddress) == nil) {
                 return "Keystore does not exist"
            }

            let contractAddress =  EthereumAddress(tokenContractAddress)
            let receviverEthAddress =  EthereumAddress(receiverAddress)
            let senderEthAddress = EthereumAddress(walletAddress)
            let contract = self.web3Manager.contract(Web3Utils.erc20ABI, at: contractAddress, abiVersion: 2)!
            let tokenName = try contract.method("name")?.call()
            let tokenSymbol = try contract.method("symbol")?.call()
            let amount = Web3.Utils.parseToBigUInt(tokenAmount, units: .eth)

            var options = TransactionOptions.defaultOptions
            options.from = senderEthAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            
            let intermediate = try contract.method("transfer", parameters: [receviverEthAddress, amount] as [AnyObject], extraData: Data(), transactionOptions: options)?.send(password: password, transactionOptions: options)
            
            let transaction = intermediate?.hash
            
            
            var mapToUpload = [String: Any]()
            mapToUpload["network"] = isMainnet() ? "MAINNET" : "TESTNET"
            mapToUpload["action_type"] = "SEND_TOKEN"
            mapToUpload["from_wallet_address"] = walletAddress
            mapToUpload["to_wallet_address"] = receiverAddress
            mapToUpload["amount"] = tokenAmount
            mapToUpload["gasLimit"] = options.gasLimit
            mapToUpload["gasPrice"] = options.gasPrice
            mapToUpload["fee"] = 0
            mapToUpload["token_smart_contract"] = tokenContractAddress
            mapToUpload["token_name"] = tokenName
            mapToUpload["token_symbol"] = tokenSymbol
            mapToUpload["tx_hash"] = transaction
            mapToUpload["status"] = "SUCCESS"
            
            self.sendToHyperLedger(map: mapToUpload)

            return transaction

        } catch {
            print(error.localizedDescription)
            return error.localizedDescription
        }
        
    }
    
    /* Send Ether  */
    public func sendEther(walletAddress : String , password : String , receiverAddress : String , tokenAmount : String, gasPrice : Double, gasLimit : Double) -> String? {
        
        do {
            if (findKeystoreMangerByAddress(walletAddress: walletAddress) == nil) {
                return "Keystore does not exist"
            }

            let ethSenderAddress = EthereumAddress(walletAddress)!
            let resEthAddress = EthereumAddress(receiverAddress)!
            let contract = self.web3Manager.contract(Web3.Utils.coldWalletABI, at: resEthAddress, abiVersion: 2)!
            let amount = Web3.Utils.parseToBigUInt(tokenAmount, units: .eth)
            var options = TransactionOptions.defaultOptions
            options.value = amount
            options.from = ethSenderAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic

            let tx = contract.write(
                                "fallback",
                                parameters: [AnyObject](),
                                extraData: Data(),
                                transactionOptions: options)!
            
            let result = try tx.send(password: password)
            
            
            var mapToUpload = [String: Any]()
            mapToUpload["network"] = isMainnet() ? "MAINNET" : "TESTNET"
            mapToUpload["action_type"] = "SEND_ETHER"
            mapToUpload["from_wallet_address"] = walletAddress
            mapToUpload["to_wallet_address"] = receiverAddress
            mapToUpload["amount"] = tokenAmount
            mapToUpload["gasLimit"] = options.gasLimit
            mapToUpload["gasPrice"] = options.gasPrice
            mapToUpload["fee"] = 0
            mapToUpload["tx_hash"] = result.hash
            mapToUpload["status"] = "SUCCESS"
            
            self.sendToHyperLedger(map: mapToUpload)
            
            return result.hash
        } catch {
            print(error.localizedDescription)
            return error.localizedDescription
        }
        
    }

    
    func sendToHyperLedger (map : [String: Any]) {
        
         
        let url = "http://34.231.96.72:8081/createTransaction/"
        
        var mapToUpload = [String : Any]()
        var body = map
        
        mapToUpload["orgname"] = "org1"
        mapToUpload["username"] = "user1"
        mapToUpload["tx_type"] = "ETHEREUM"
        if let theJSONData = try?  JSONSerialization.data(
          withJSONObject: self.getDeviceInfo()
          ),
          let theJSONText = String(data: theJSONData,
                                   encoding: String.Encoding(rawValue: String.Encoding.RawValue(Int(String.Encoding.ascii.rawValue)))) {
            body["DEVICE_INFO"] = theJSONText
        }
        mapToUpload["body"] = body
        
        print(mapToUpload)

        Alamofire.request(url, method: .post, parameters: mapToUpload,encoding: JSONEncoding.default, headers: nil).responseJSON {
        response in
          switch response.result {
                        case .success:
                            print(response)

                            break
                        case .failure(let error):

                            print(error)
                        }
        }
        
        
    }
    
    func isMainnet() -> Bool {
        return self.infuraUrl.contains("mainnet")
    }
    
    func getDeviceInfo() -> [String : Any]{
        var data = [String : Any]()
        
        let deviceUUID = UIDevice.current.identifierForVendor!.uuidString
        let osName = "iOS"
        let modelName = UIDevice.current.name
        let serialNumber = "Not allowed"
        let manufacturer = "Apple"
        
        data["ID"] = deviceUUID
        data["OS"] = osName
        data["MODEL"] = modelName
        data["SERAIL"] = serialNumber
        data["MANUFACTURER"] = manufacturer
        
        return data
        
        
    }
    

    
    func writeToFile(fileName : String , keystore : Data){
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        FileManager.default.createFile(atPath: userDir + "/keystore/" + fileName +  ".json", contents: keystore, attributes: nil)
    }
    
    
    func findKeystoreMangerByAddress(walletAddress : String) -> EthereumKeystoreV3? {
        let ethWalletAddress = EthereumAddress(walletAddress)
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        for i in keystoreManager?.keystores ?? [] {
            if (i.getAddress() == ethWalletAddress){
                return i
            }
        }
        return nil
        
    }
    
}
