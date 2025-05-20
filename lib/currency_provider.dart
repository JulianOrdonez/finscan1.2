import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  String _selectedCurrency = 'USD';
  final List<String> supportedCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'COP']; // Add your supported currencies

  CurrencyProvider() {
    _loadSelectedCurrency();
  }

  String getSelectedCurrency() => _selectedCurrency;

  Future<void> setSelectedCurrency(String currency) async {
    if (supportedCurrencies.contains(currency)) {
      _selectedCurrency = currency;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('currency', currency);
    } else {
      // Optionally handle unsupported currency selection
      print('Unsupported currency: $currency');
    }
  }

  Future<void> _loadSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCurrency = prefs.getString('currency') ?? 'USD'; // Default to USD if no currency is saved
    notifyListeners();
  }

  String getCurrencySymbol() {
    switch (_selectedCurrency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'COP':
        return '\$'; // Or use the specific COP symbol if available and desired
      default:
        return '\$';
    }
  }

  String formatAmount(double amount) {
    // Simple formatting, you can enhance this with more advanced formatting based on locale
    return amount.toStringAsFixed(2);
  }

  double convertAmountToSelectedCurrency(double amountInUSD) {
    // Implement currency conversion logic here.
    // This is a placeholder; you would typically use exchange rates.
    // For now, assuming a simple conversion or no conversion for simplicity.
    // You might need to pass the original currency of the amount if it's not always USD.
    return amountInUSD; // Assuming amounts are stored in USD or no conversion is needed yet.
  }
}