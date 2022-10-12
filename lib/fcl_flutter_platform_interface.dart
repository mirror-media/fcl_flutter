import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fcl_flutter_method_channel.dart';

abstract class FclFlutterPlatform extends PlatformInterface {
  /// Constructs a FclFlutterPlatform.
  FclFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FclFlutterPlatform _instance = MethodChannelFclFlutter();

  /// The default instance of [FclFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFclFlutter].
  static FclFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FclFlutterPlatform] when
  /// they register themselves.
  static set instance(FclFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initFCL(String bloctoAppId, {bool useTestNet = false}) {
    throw UnimplementedError('initFCL() has not been implemented.');
  }

  Future<String?> simpleLogin() {
    throw UnimplementedError('simpleLogin() has not been implemented.');
  }

  Future<String?> accountProofLogin(String appIdentifier) {
    throw UnimplementedError('accountProofLogin() has not been implemented.');
  }

  Future<bool?> verifyAccountProof(String appIdentifier) {
    throw UnimplementedError('verifyAccountProof() has not been implemented.');
  }

  Future<String?> getAddress() {
    throw UnimplementedError('getAddress() has not been implemented.');
  }

  Future<void> unauthenticate() {
    throw UnimplementedError('unauthenticate() has not been implemented.');
  }
}
