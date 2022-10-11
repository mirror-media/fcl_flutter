import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fcl_flutter_platform_interface.dart';

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
}
