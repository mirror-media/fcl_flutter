import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:fcl_flutter/fcl_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: MyApp(),
  ));
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
  String? _queryResult;
  String? _transactionId;

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
    return Scaffold(
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
            if (_queryResult != null)
              Text(
                'Query result: $_queryResult',
                textAlign: TextAlign.center,
              ),
            if (_transactionId != null)
              Text(
                'Transaction ID: $_transactionId',
                textAlign: TextAlign.center,
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
                  ElevatedButton(
                    onPressed: () async => await testMutate(context),
                    child: const Text('Use mutate send 1.01 Flow'),
                  ),
                  ElevatedButton(
                    onPressed: () async => await createREADrVault(context),
                    child: const Text('Create READr vault'),
                  ),
                  ElevatedButton(
                    onPressed: () async => await getREADrBalance(),
                    child: const Text('Get READrCoin balance'),
                  ),
                ],
                ElevatedButton(
                  onPressed: () async => await getAddress(),
                  child: const Text('Get account address'),
                ),
                ElevatedButton(
                  onPressed: () async => await testQuery(),
                  child: const Text('Test query 7+6'),
                ),
              ],
            ),
          ],
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

  Future<void> testQuery() async {
    const String script = '''
    pub fun main(a: Int, b: Int): Int {
      return a + b
    }
    ''';
    final List<String> arguments = [
      '''
      {
        "type": "Int",
        "value": "7"
      }
      ''',
      '''
      {
        "type": "Int",
        "value": "6"
      }
      ''',
    ];
    String? result;
    try {
      result =
          await _fclFlutterPlugin.query(script: script, arguments: arguments);
      _alert = '';
    } on PlatformException {
      _alert = 'Query failed';
    }

    if (!mounted) return;

    setState(() {
      _queryResult = result;
    });
  }

  Future<void> testMutate(BuildContext context) async {
    String? address = await showDialog<String>(
      context: context,
      builder: (context) {
        String? input;
        return AlertDialog(
          title: const Text('Input address you want to send'),
          content: TextField(
            onChanged: (value) => input = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (address != null) {
      String script = '''
      import FungibleToken from 0x9a0766d93b6608b7

      transaction(amount: UFix64, to: Address) {
        let vault: @FungibleToken.Vault
        
        prepare(currentUser: AuthAccount) {
          self.vault <- currentUser
            .borrow<&{FungibleToken.Provider}>(from: /storage/flowTokenVault)!
            .withdraw(amount: amount)
        }

        execute {
          getAccount(to)
            .getCapability(/public/flowTokenReceiver)!
            .borrow<&{FungibleToken.Receiver}>()!
            .deposit(from: <- self.vault)
        }
      }
      ''';

      final List<String> arguments = [
        '''
        {
          "type": "UFix64",
          "value": "1.01"
        }
        ''',
        '''
        {
          "type": "Address",
          "value": "$address"
        }
        ''',
      ];

      String? result;
      try {
        result = await _fclFlutterPlugin.mutate(
            script: script, arguments: arguments);
        _alert = '';
        if (kDebugMode) {
          print('Transaction ID: $result');
        }
      } on PlatformException {
        _alert = 'Mutate failed';
      }

      if (!mounted) return;

      setState(() {
        _transactionId = result;
      });
    }
  }

  Future<void> createREADrVault(BuildContext context) async {
    String script = '''
      import FungibleToken from 0x9a0766d93b6608b7
      import ReadrCoin from 0x191deed43d01c59c
      transaction {
        prepare(signer: AuthAccount) {
          // Return early if the account already stores a ReadrCoin Vault
          if signer.borrow<&ReadrCoin.Vault>(from: ReadrCoin.VaultStoragePath) != nil {
            return
          }
          // Create a new ReadrCoin Vault and put it in storage
          signer.save(
            <-ReadrCoin.createEmptyVault(),
            to: ReadrCoin.VaultStoragePath
          )
          // Create a public capability to the Vault that only exposes
          // the deposit function through the Receiver interface
          signer.link<&ReadrCoin.Vault{FungibleToken.Receiver}>(
            ReadrCoin.ReceiverPublicPath,
            target: ReadrCoin.VaultStoragePath
          )
          // Create a public capability to the Vault that only exposes
          // the balance field through the Balance interface
          signer.link<&ReadrCoin.Vault{FungibleToken.Balance}>(
            ReadrCoin.BalancePublicPath,
            target: ReadrCoin.VaultStoragePath
          )
        }
      }
      ''';

    String? result;
    try {
      result = await _fclFlutterPlugin.mutate(script: script);
      _alert = '';
      if (kDebugMode) {
        print('Transaction ID: $result');
      }
    } on PlatformException {
      _alert = 'Mutate failed';
    }

    if (!mounted) return;

    setState(() {
      _transactionId = result;
    });
  }

  Future<void> getREADrBalance() async {
    const String script = '''
    import FungibleToken from 0x9a0766d93b6608b7
    import ReadrCoin from 0x191deed43d01c59c
    pub fun main(account: Address): UFix64 {
      let acct = getAccount(account)
      let vaultRef = acct.getCapability(ReadrCoin.BalancePublicPath)
        .borrow<&ReadrCoin.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")
      return vaultRef.balance
    }
    ''';
    final List<String> arguments = [
      '''
      {
        "type": "Address",
        "value": "$_accountAddress"
      }
      ''',
    ];
    String? result;
    try {
      result =
          await _fclFlutterPlugin.query(script: script, arguments: arguments);
      _alert = '';
    } on PlatformException {
      _alert = 'Get READr balance failed';
    }

    if (!mounted) return;

    setState(() {
      _accountBalance = '$result READrCoin';
    });
  }
}
