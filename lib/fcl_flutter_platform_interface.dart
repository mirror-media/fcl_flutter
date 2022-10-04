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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
