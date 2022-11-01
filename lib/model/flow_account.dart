import 'dart:io';

import 'package:decimal/decimal.dart';

/// Flow account details
class FlowAccount {
  /// Account address
  final String address;

  /// Account balance <br>
  /// Use [decimal](https://pub.dev/packages/decimal) package to prevent double's deviation
  final Decimal balance;

  FlowAccount({
    required this.address,
    required this.balance,
  });

  factory FlowAccount.fromMap(dynamic source) {
    /// In Android, balance is BigDecimal, so we pass String back is correctly, just parse to dart Decimal
    /// In iOS, balance is Uint64, so we need to divided by 100000000
    Decimal balance = Decimal.parse(source['balance']);
    if (Platform.isIOS) {
      balance = (balance / Decimal.parse('100000000')).toDecimal();
    }
    return FlowAccount(
      address: source['address'],
      balance: balance,
    );
  }
}
