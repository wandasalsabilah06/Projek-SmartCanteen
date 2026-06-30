import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _idrFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _usdFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String toIDR(num amount) => _idrFormatter.format(amount);

  static String toUSD(num amount) => _usdFormatter.format(amount);

  static String format(num amount, {String currency = 'IDR'}) {
    return currency == 'IDR' ? toIDR(amount) : toUSD(amount);
  }
}
