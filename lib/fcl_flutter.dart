import 'fcl_flutter_platform_interface.dart';
import 'model/flow_account.dart';

class FclFlutter {
  /// Initial flow client library <br>
  /// **Must be called before any other functions**
  Future<void> initFCL(String bloctoAppId, {bool useTestNet = false}) {
    return FclFlutterPlatform.instance
        .initFCL(bloctoAppId, useTestNet: useTestNet);
  }

  /// Retrieve account address **without** account proof data
  Future<String?> simpleLogin() {
    return FclFlutterPlatform.instance.simpleLogin();
  }

  /// Retrieve account address **with** account proof data <br>
  /// appIdentifier is used to verify
  Future<String?> accountProofLogin(String appIdentifier) {
    return FclFlutterPlatform.instance.accountProofLogin(appIdentifier);
  }

  /// Verify account proof <br>
  /// Should only be called after accountProofLogin success<br>
  /// appIdentifier is identical to accountProofLogin's appIdentifier <br>
  /// [Learn more about account proof](https://developers.flow.com/tools/fcl-js/reference/proving-authentication#authenticating-a-user-using-account-proof)
  Future<bool?> verifyAccountProof(String appIdentifier) {
    return FclFlutterPlatform.instance.verifyAccountProof(appIdentifier);
  }

  /// Get account address after login, return null if not login
  Future<String?> getAddress() {
    return FclFlutterPlatform.instance.getAddress();
  }

  /// Unauthenticate current user
  Future<void> unauthenticate() {
    return FclFlutterPlatform.instance.unauthenticate();
  }

  /// Retrieve account details by account address
  Future<FlowAccount> getAccountDetails(String address) {
    return FclFlutterPlatform.instance.getAccountDetails(address);
  }
}
