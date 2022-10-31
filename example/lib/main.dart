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
  String? _accountAddress;
  bool _isVerified = false;
  final _fclFlutterPlugin = FclFlutter();
  String? _accountBalance = 'Unknown';
  String _alert = "";

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
          title: const Text('FCL_Flutter'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_alert.isNotEmpty)
                Text(
                  _alert,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              if (_accountAddress == null)
                const Text(
                  'Please login',
                  textAlign: TextAlign.center,
                )
              else ...[
                Text(
                  'Account address: $_accountAddress',
                  textAlign: TextAlign.center,
                ),
                Text(
                  'AccountProof verify: $_isVerified',
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Balance: $_accountBalance',
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(
                height: 50,
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: [
                  if (_accountAddress == null) ...[
                    ElevatedButton(
                      onPressed: () async => await simpleLogin(),
                      child: const Text('Simple login'),
                    ),
                    ElevatedButton(
                      onPressed: () async => await accountProofLogin(),
                      child: const Text('AccountProof login'),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () async => await verifyAccountProof(),
                      child: const Text('Verify accountProof'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _fclFlutterPlugin.unauthenticate();
                        setState(() {
                          _accountAddress = null;
                        });
                      },
                      child: const Text('Unauthenticate'),
                    ),
                    ElevatedButton(
                      onPressed: () async => await getAccountBalance(),
                      child: const Text('Get account balance'),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: () async => await getAddress(),
                    child: const Text('Get account address'),
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
    String? accountAddress;

    try {
      accountAddress = await _fclFlutterPlugin.simpleLogin();
      _alert = '';
    } on PlatformException {
      _alert = 'Failed to get account address.';
    }

    if (!mounted) return;

    setState(() {
      _accountAddress = accountAddress;
    });
  }

  Future<void> accountProofLogin() async {
    String? accountAddress;

    try {
      accountAddress = await _fclFlutterPlugin.accountProofLogin('samTest');
      _alert = '';
    } on PlatformException {
      _alert = 'Failed to get account address.';
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

  Future<void> getAddress() async {
    String? accountAddress;

    try {
      accountAddress = await _fclFlutterPlugin.getAddress();
      _alert = '';
    } on PlatformException {
      _alert = 'Failed to get account address.';
    }

    if (!mounted) return;

    setState(() {
      _accountAddress = accountAddress;
    });
  }

  Future<void> getAccountBalance() async {
    String? balance;
    try {
      var accountDetails =
          await _fclFlutterPlugin.getAccountDetails(_accountAddress!);
      balance = accountDetails.balance.toString();
      _alert = '';
    } on PlatformException {
      _alert = 'Failed to get account details.';
    }

    if (!mounted) return;

    setState(() {
      _accountBalance = balance;
    });
  }
}
