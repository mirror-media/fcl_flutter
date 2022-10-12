import Flutter
import UIKit
import FCL_SDK
import Foundation
import Cadence
import FlowSDK

public class SwiftFclFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fcl_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftFclFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch(call.method){
        case "initFCL":
          let arguments = call.arguments as! [String: Any]
          let bloctoSDKAppId = arguments["bloctoAppId"] as! String
          let useTestNet = arguments["useTestNet"] as! Bool
          initFCL(bloctoSDKAppId: bloctoSDKAppId, useTestNet: useTestNet)
          result("Initial success")
        case "simpleLogin":
          Task{
              let address = await simpleLogin()
              if(address == "error"){
                  result(FlutterError.init(code: "SimpleLoginFailed", message: "Get user account address failed", details: nil))
              }else{
                  result(address)
              }
          }
        case "accountProofLogin":
          let arguments = call.arguments as! [String: Any]
          let appIdentifier = arguments["appIdentifier"] as! String
          Task{
              let address = await accountProofLogin(appIdentifier: appIdentifier)
              if(address == "error"){
                  result(FlutterError.init(code: "AccountProofLoginFailed", message: "Get user account address failed", details: nil))
              }else{
                  result(address)
              }
          }
        case "verifyAccountProof":
          let arguments = call.arguments as! [String: Any]
          let appIdentifier = arguments["appIdentifier"] as! String
          
          if(fcl.currentUser?.accountProof != nil){
              let accountProof = fcl.currentUser!.accountProof!
              Task {
                  let isValid = await verifyAccountProof(appIdentifier: appIdentifier, accountProof: accountProof)
                  if(isValid != nil){
                      result(isValid)
                  }else{
                      result(FlutterError.init(code: "VerifyAccountProofFailed", message: "Verify accountProof failed", details: nil))
                  }
              }
          }else{
              print("AccountProofData is nil")
              result(FlutterError.init(code: "NoAccountProofData", message: "AccountProofData is nil", details: nil))
          }

          
        default:
          result(FlutterMethodNotImplemented)
    }
      
  }
    
    private func initFCL(bloctoSDKAppId: String, useTestNet: Bool){
        do {
            let bloctoWalletProvider = try BloctoWalletProvider(
                bloctoAppIdentifier: bloctoSDKAppId,
                window: nil,
                testnet: useTestNet
            )
            fcl.config
                .put(.network(useTestNet ? .testnet : .mainnet))
                .put(.supportedWalletProviders(
                    [
                        bloctoWalletProvider,
                    ]
                ))
            print("Initial FCL success")
        } catch {
            print("Initial FCL error")
            print(error)
        }
    }
    
    private func simpleLogin() async -> String{
        var accountAddress: String
        do{
            accountAddress = try await fcl.login().hexStringWithPrefix
        }catch{
            print("Simple login error")
            print(error)
            accountAddress = "error"
        }
      return accountAddress
    }
    
    private func accountProofLogin(appIdentifier: String) async -> String{
        var accountAddress: String
        let nonce = getNonce()
        if(nonce != nil){
            let accountProofData = FCLAccountProofData(
                appId: appIdentifier,
                nonce: nonce! // minimum 32-byte random nonce as a hex string.
            )
            do{
                accountAddress = try await fcl.authanticate(accountProofData: accountProofData).hexStringWithPrefix
            }catch{
                print("AccountProof login error")
                print(error)
                accountAddress = "error"
            }
        }else{
            print("AccountProof login error")
            accountAddress = "error"
        }
        return accountAddress
    }
    
    private func getNonce() -> String?{
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }
        if result == errSecSuccess {
            return keyData.toHexString()
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    
    private func verifyAccountProof(appIdentifier: String,accountProof: AccountProofSignatureData) async -> Bool?{
        do {
            let valid = try await AppUtilities.verifyAccountProof(
                appIdentifier: appIdentifier,
                accountProofData: accountProof,
                fclCryptoContract: nil
            )
            return valid
        } catch {
            print("Verify accountProof error")
            print(error)
            return nil
        }
    }
}
