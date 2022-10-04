import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fcl_flutter_platform_interface.dart';

/// An implementation of [FclFlutterPlatform] that uses method channels.
class MethodChannelFclFlutter extends FclFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fcl_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
