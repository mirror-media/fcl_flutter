import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fcl_flutter/fcl_flutter_method_channel.dart';

void main() {
  MethodChannelFclFlutter platform = MethodChannelFclFlutter();
  const MethodChannel channel = MethodChannel('fcl_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('simpleLogin', () async {
    expect(await platform.simpleLogin(), '42');
  });
}
