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
          
      case "getAddress":
          result(fcl.currentUser?.address.hexStringWithPrefix)
      case "unauthenticate":
          fcl.unauthenticate()
          result("Unauthenticate success")
      case "getAccountDetails":
          let arguments = call.arguments as! [String: Any]
          let address = arguments["address"] as! String
          Task{
              let account = await getAccountDetails(address: address)
              if(account != nil){
                  result([
                    "address":account!.address.hexStringWithPrefix,
                    "balance":String(account!.balance)])
              }else{
                  result(FlutterError.init(code: "GetAccountDetailFailed", message: "Get account detail error", details: nil))
              }
          }
      case "query":
          let flutterArguments = call.arguments as! [String: Any]
          let script = flutterArguments["script"] as! String
          let arguments = flutterArguments["arguments"] as? Array<String>
          Task{
              let queryResult = await query(script: script, arguments: arguments)
              if(queryResult != nil){
                  result(queryResult)
              }else{
                  result(FlutterError.init(code: "QueryFailed", message: "FCL query error", details: nil))
              }
          }
      case "mutate":
          let flutterArguments = call.arguments as! [String: Any]
          let script = flutterArguments["script"] as! String
          let arguments = flutterArguments["arguments"] as? Array<String>
          let limit = flutterArguments["limit"] as? Int
          Task{
              let mutateResult = await mutate(script: script, arguments: arguments, limit: limit)
              if(mutateResult != nil){
                  result(mutateResult)
              }else{
                  result(FlutterError.init(code: "MutateFailed", message: "FCL mutate error", details: nil))
              }
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
    
    private func getAccountDetails(address: String) async -> Account? {
        do{
            return try await fcl.getAccount(address: address)
        }catch{
            print("Get account detail error")
            print(error)
            return nil
        }
    }
    
    private func query(script: String, arguments: Array<String>?) async -> String?{
        do {
            var argumentArray: [Cadence.Argument] = []
            if(arguments != nil){
                for item in arguments!{
                    argumentArray.append(try JSONDecoder().decode(Cadence.Argument.self,from: item.data(using: .utf8)!))
                }
            }
            
            let result = try await fcl.query(script: script, arguments: argumentArray)
            
            return result.value.description
        } catch {
            print("FCL query error")
            print(error)
            return nil
        }
    }
    
    private func mutate(script: String, arguments: Array<String>?, limit: Int?) async -> String?{
        do {
            guard let userWalletAddress = fcl.currentUser?.address else {
                // handle error
                print("Please login first!!")
                return nil
            }
            var argumentArray: [Cadence.Argument] = []
            if(arguments != nil){
                for item in arguments!{
                    argumentArray.append(try JSONDecoder().decode(Cadence.Argument.self,from: item.data(using: .utf8)!))
                }
            }
            
            let txHsh = try await fcl.mutate(
                cadence: script,
                arguments: argumentArray,
                limit: UInt64(limit ?? 1000),
                authorizers: [userWalletAddress]
            )
            
            return txHsh.description
        } catch {
            print("FCL mutate error")
            print(error)
            return nil
        }
    }
}
