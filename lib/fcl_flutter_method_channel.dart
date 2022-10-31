import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fcl_flutter_platform_interface.dart';
import 'model/flow_account.dart';

/// An implementation of [FclFlutterPlatform] that uses method channels.
class MethodChannelFclFlutter extends FclFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fcl_flutter');

  @override
  Future<void> initFCL(String bloctoAppId, {bool useTestNet = false}) async {
    await methodChannel.invokeMethod<void>(
        'initFCL', {'bloctoAppId': bloctoAppId, 'useTestNet': useTestNet});
  }

  @override
  Future<String?> simpleLogin() async {
    return await methodChannel.invokeMethod<String?>('simpleLogin');
  }

  @override
  Future<String?> accountProofLogin(String appIdentifier) async {
    return await methodChannel.invokeMethod<String?>(
        'accountProofLogin', {'appIdentifier': appIdentifier});
  }

  @override
  Future<bool?> verifyAccountProof(String appIdentifier) async {
    return await methodChannel.invokeMethod<bool>(
        'verifyAccountProof', {'appIdentifier': appIdentifier});
  }

  @override
  Future<String?> getAddress() async {
    return await methodChannel.invokeMethod<String?>('getAddress');
  }

  @override
  Future<void> unauthenticate() async {
    await methodChannel.invokeMethod<void>('unauthenticate');
  }

  @override
  Future<FlowAccount> getAccountDetails(String address) async {
    var result = await methodChannel
        .invokeMethod('getAccountDetails', {'address': address});
    if (result == null) {
      throw Exception("Failed to get account details");
    } else {
      return FlowAccount.fromMap(result);
    }
  }
}
