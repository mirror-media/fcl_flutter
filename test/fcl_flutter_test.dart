import 'package:flutter_test/flutter_test.dart';
import 'package:fcl_flutter/fcl_flutter.dart';
import 'package:fcl_flutter/fcl_flutter_platform_interface.dart';
import 'package:fcl_flutter/fcl_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFclFlutterPlatform
    with MockPlatformInterfaceMixin
    implements FclFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FclFlutterPlatform initialPlatform = FclFlutterPlatform.instance;

  test('$MethodChannelFclFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFclFlutter>());
  });

  test('getPlatformVersion', () async {
    FclFlutter fclFlutterPlugin = FclFlutter();
    MockFclFlutterPlatform fakePlatform = MockFclFlutterPlatform();
    FclFlutterPlatform.instance = fakePlatform;

    expect(await fclFlutterPlugin.getPlatformVersion(), '42');
  });
}