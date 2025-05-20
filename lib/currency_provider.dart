import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Exchange rates relative to USD
const Map<String, double> _exchangeRates = {
  'USD': 1.0,
  'EUR': 0.93, // As of 2024-03-04
  'MXN': 17.0, // As of 2024-03-04
  'COP': 3950.0, // As of 2024-03-04
};
class CurrencyProvider extends ChangeNotifier {List<String> get supportedCurrencies => ['COP', 'USD', 'EUR'];
  String _selectedCurrency = 'COP';

  CurrencyProvider() {
    _loadSelectedCurrency();
  }

  String getSelectedCurrency() => _selectedCurrency;

  String getCurrencySymbol() {
    switch (_selectedCurrency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'MXN':
        return 'MX\$';
      case 'COP':
        return 'COL\$';
      default:
        return '';
    }
  }

  String formatAmount(double amount) {
    return '${getCurrencySymbol()}${amount.toStringAsFixed(2)}';
  }

  Future<void> setSelectedCurrency(String currency) async {
    _selectedCurrency = currency;
    notifyListeners();

    await _saveSelectedCurrency(currency);
  }

  Future<void> _loadSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCurrency = prefs.getString('currency') ?? 'COP';
    notifyListeners();
  }

  Future<void> _saveSelectedCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  double convertAmountToSelectedCurrency(double amountInUSD) {
    if (_exchangeRates.containsKey(_selectedCurrency)) {
      return amountInUSD * _exchangeRates[_selectedCurrency]!;
    }
    return amountInUSD; // Return as is if currency not found
  }

  double convertAmountToUSD(double amountInSelectedCurrency) {
    // Assuming the input amount is in the currently selected currency
     return amountInSelectedCurrency / _exchangeRates[_selectedCurrency]!;
  }
}