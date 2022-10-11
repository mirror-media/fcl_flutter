import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fcl_flutter/fcl_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _accountAddress = 'Unknown';
  bool _isVerified = false;
  final _fclFlutterPlugin = FclFlutter();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await _fclFlutterPlugin.initFCL(
      'b56af110-144a-435e-be9b-d0123bbaec6a',
      useTestNet: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Account address: $_accountAddress',
                textAlign: TextAlign.center,
              ),
              Text(
                'AccountProof verify: $_isVerified',
                textAlign: TextAlign.center,
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () async => await simpleLogin(),
                    child: const Text('Simple login'),
                  ),
                  ElevatedButton(
                    onPressed: () async => await accountProofLogin(),
                    child: const Text('AccountProof login'),
                  ),
                  ElevatedButton(
                    onPressed: () async => await verifyAccountProof(),
                    child: const Text('Verify accountProof'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> simpleLogin() async {
    String accountAddress;

    try {
      accountAddress = await _fclFlutterPlugin.simpleLogin() ?? 'Loading';
    } on PlatformException {
      accountAddress = 'Failed to get account address.';
    }

    if (!mounted) return;

    setState(() {
      _accountAddress = accountAddress;
    });
  }

  Future<void> accountProofLogin() async {
    String accountAddress;

    try {
      accountAddress =
          await _fclFlutterPlugin.accountProofLogin('samTest') ?? 'Loading';
    } on PlatformException {
      accountAddress = 'Failed to get account address.';
    }

    if (!mounted) return;

    setState(() {
      _accountAddress = accountAddress;
    });
  }

  Future<void> verifyAccountProof() async {
    bool isVerify = false;
    try {
      isVerify = await _fclFlutterPlugin.verifyAccountProof('samTest') ?? false;
    } on PlatformException {
      isVerify = false;
    }

    if (!mounted) return;

    setState(() {
      _isVerified = isVerify;
    });
  }
}
