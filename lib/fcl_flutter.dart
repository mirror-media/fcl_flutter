
import 'fcl_flutter_platform_interface.dart';

class FclFlutter {
  Future<String?> getPlatformVersion() {
    return FclFlutterPlatform.instance.getPlatformVersion();
  }
}
