import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _idrFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String toIDR(num amount) => _idrFormatter.format(amount);

  // Alias toUSD untuk tampilan - pakai format IDR karena backend pakai Rupiah
  static String toUSD(num amount) => _idrFormatter.format(amount);

  static String format(num amount) => _idrFormatter.format(amount);
}
