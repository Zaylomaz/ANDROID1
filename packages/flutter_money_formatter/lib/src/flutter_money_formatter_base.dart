import 'package:intl/intl.dart';

import 'utils/compact_format_type.dart';
import 'utils/money_formatter_compare.dart';
import 'utils/money_formatter_output.dart';
import 'utils/money_formatter_settings.dart';

part 'utils/utilities.dart';

/// [FlutterMoneyFormatter] instance
class FlutterMoneyFormatter {
  /// Init instance of [FlutterMoneyFormatter]
  ///
  /// [amount] (@required) the number that will be formatted
  FlutterMoneyFormatter({
    required this.amount,
    MoneyFormatterSettings? settings,
  }) {
    this.settings = settings ?? MoneyFormatterSettings();
    _utilities = _Utilities(amount: amount, settings: settings);
    output = _getOutput();
    comparator = MoneyFormatterCompare(amount: amount);
  }

  late _Utilities _utilities;

  /// Amount number that will be formatted.
  double amount;

  /// The formatter settings
  late MoneyFormatterSettings settings;

  /// Returns compiled and formatted output in several formats.
  late MoneyFormatterOutput output;

  /// Comparator
  late MoneyFormatterCompare comparator;

  /// output builder
  MoneyFormatterOutput _getOutput() {
    final _urs = _utilities.refineSeparator;
    final _decSepCharPos = _urs.indexOf(settings.decimalSeparator!);

    return MoneyFormatterOutput(
        nonSymbol: _urs,
        symbolOnLeft: '${settings.symbol}${_utilities.spacer}$_urs',
        symbolOnRight: '$_urs${_utilities.spacer}${settings.symbol}',
        compactNonSymbol: _compactNonSymbol,
        compactSymbolOnLeft:
            '${settings.symbol}${_utilities.spacer}$_compactNonSymbol',
        compactSymbolOnRight:
            '$_compactNonSymbol${_utilities.spacer}${settings.symbol}',
        fractionDigitsOnly:
            _urs.substring(-1 == _decSepCharPos ? 0 : _decSepCharPos + 1),
        withoutFractionDigits: _urs.substring(
            0, -1 == _decSepCharPos ? _urs.length - 1 : _decSepCharPos));
  }

  /// returns FlutterMoneyFormatter after calculating amount.
  FlutterMoneyFormatter fastCalc(
      {required FastCalcType type, required double amount}) {
    switch (type) {
      case FastCalcType.addition:
        this.amount += amount;
        break;

      case FastCalcType.substraction:
        this.amount -= amount;
        break;

      case FastCalcType.multiplication:
        this.amount *= amount;
        break;

      case FastCalcType.division:
        this.amount /= amount;
        break;

      case FastCalcType.percentageAddition:
        this.amount += (amount / 100) * this.amount;
        break;

      case FastCalcType.percentageSubstraction:
        this.amount -= (amount / 100) * this.amount;
        break;

      default:
        throw Exception('Unknown calculation type.');
    }

    return this;
  }

  /// Copies current instance and change some values to the new instance.
  FlutterMoneyFormatter copyWith(
      {double? amount,
      String? symbol,
      String? thousandSeparator,
      String? decimalSeparator,
      int? fractionDigits,
      String? symbolAndNumberSeparator,
      CompactFormatType? compactFormatType}) {
    final ts = settings;

    final mfs = MoneyFormatterSettings(
        symbol: symbol ?? ts.symbol,
        thousandSeparator: thousandSeparator ?? ts.thousandSeparator,
        decimalSeparator: decimalSeparator ?? ts.decimalSeparator,
        symbolAndNumberSeparator:
            symbolAndNumberSeparator ?? ts.symbolAndNumberSeparator,
        fractionDigits: fractionDigits ?? ts.fractionDigits,
        compactFormatType: compactFormatType ?? ts.compactFormatType);

    return FlutterMoneyFormatter(amount: amount ?? this.amount, settings: mfs);
  }

  /// Returns compact format number without currency symbol
  String get _compactNonSymbol {
    final compacted = _utilities.baseCompact.format(amount);
    final numerics = RegExp(r'(\d+\.\d+)|(\d+)')
        .allMatches(compacted)
        .map((_) => _.group(0))
        .toString()
        .replaceAll('(', '')
        .replaceAll(')', '');

    final alphas = compacted.replaceAll(numerics, '');

    final reformat = NumberFormat.currency(
            symbol: '',
            decimalDigits:
                !numerics.contains('.') ? 0 : settings.fractionDigits)
        .format(num.parse(numerics));

    return '$reformat$alphas';
  }
}
