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

  /// Send arbitrary Cadence scripts to the chain and receive decoded values <br>
  /// Return Cadence response Value from Flow contract String <br>
  /// Can be performed without user login <br>
  /// - script: Cadence script used to query Flow <br>
  /// - arguments: A list of [Json-Candence data](https://developers.flow.com/cadence/json-cadence-spec) String passed to cadence query <br>
  Future<String?> query({required String script, List<String>? arguments}) {
    return FclFlutterPlatform.instance
        .query(script: script, arguments: arguments);
  }

  /// Use transaction to send Cadence code with specify authorizer to perform permanently state changes on chain <br>
  /// Return the transaction ID <br>
  /// **Must be performed after user logged in** <br>
  /// - script: Cadence script used to mutate Flow <br>
  /// - arguments: A list of [Json-Candence data](https://developers.flow.com/cadence/json-cadence-spec) String passed to cadence transaction <br>
  /// - limit: Gas limit for the computation of the transaction
  Future<String?> mutate(
      {required String script, List<String>? arguments, int? limit}) {
    return FclFlutterPlatform.instance
        .mutate(script: script, arguments: arguments, limit: limit);
  }
}
