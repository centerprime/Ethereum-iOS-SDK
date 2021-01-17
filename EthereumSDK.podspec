Pod::Spec.new do |s|
  s.name             = 'EthereumSDK'
  s.version          = '0.1.3'
  s.summary          = 'EthereumSDK by Centerprime'

  s.homepage         = 'https://github.com/centerprime/Ethereum-iOS-SDK.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'centerprime' => 'support@centerprime.technology' }
  s.source           = { :git => 'https://github.com/centerprime/Ethereum-iOS-SDK.git', :branch => "master", :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'EthereumSDK/Classes/**/*'
  s.swift_version = '4.0'
  
  s.dependency 'web3swift'
  s.dependency 'Alamofire'
  s.dependency 'SwiftyJSON'
  
end
