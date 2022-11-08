import 'package:decimal/decimal.dart';
import 'package:fcl_flutter/model/flow_account.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fcl_flutter/fcl_flutter.dart';
import 'package:fcl_flutter/fcl_flutter_platform_interface.dart';
import 'package:fcl_flutter/fcl_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFclFlutterPlatform
    with MockPlatformInterfaceMixin
    implements FclFlutterPlatform {
  @override
  Future<String?> simpleLogin() => Future.value('42');

  @override
  Future<String?> accountProofLogin(String appIdentifier) => Future.value('42');

  @override
  Future<void> initFCL(String bloctoAppId, {bool useTestNet = false}) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<bool?> verifyAccountProof(String appIdentifier) => Future.value(true);

  @override
  Future<String?> getAddress() async => 'efwfet477747';

  @override
  Future<void> unauthenticate() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<FlowAccount> getAccountDetails(String address) async {
    return FlowAccount(address: address, balance: Decimal.parse('0.001'));
  }

  @override
  Future<String?> query(
      {required String script, List<String>? arguments}) async {
    return 'Query success';
  }

  @override
  Future<String?> mutate(
      {required String script, List<String>? arguments, int? limit}) async {
    return 'Mutate success';
  }
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

    expect(await fclFlutterPlugin.simpleLogin(), '42');
  });
}
