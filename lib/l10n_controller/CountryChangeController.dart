import 'package:get/get.dart';

class CurrencyController extends GetxController {
  var selectedCurrency = '\$'.obs;  // Default currency symbol is USD
  var selectedCurrencyName = 'USD'.obs;  // Default currency name is USD
  var selectedCountry = 'United States'.obs;

  // Map of countries to their currency symbols and names
  Map<String, Map<String, String>> countryCurrencyMap = {
    'United States': {'symbol': '\$', 'name': 'USD'},
    'European Union': {'symbol': '€', 'name': 'EUR'},
    'United Kingdom': {'symbol': '£', 'name': 'GBP'},
    'Japan': {'symbol': '¥', 'name': 'JPY'},
    'China': {'symbol': '¥', 'name': 'CNY'},
    'Switzerland': {'symbol': 'CHF', 'name': 'CHF'},
    'Canada': {'symbol': '\$', 'name': 'CAD'},
    'Australia': {'symbol': '\$', 'name': 'AUD'},
    'India': {'symbol': '₹', 'name': 'INR'},
    'Russia': {'symbol': '₽', 'name': 'RUB'},
    'South Korea': {'symbol': '₩', 'name': 'KRW'},
    'Brazil': {'symbol': 'R\$', 'name': 'BRL'},
    'Mexico': {'symbol': '\$', 'name': 'MXN'},
    'Indonesia': {'symbol': 'Rp', 'name': 'IDR'},
    'Turkey': {'symbol': '₺', 'name': 'TRY'},
    'Saudi Arabia': {'symbol': '﷼', 'name': 'SAR'},
    'Sweden': {'symbol': 'kr', 'name': 'SEK'},
    'Norway': {'symbol': 'kr', 'name': 'NOK'},
    'Denmark': {'symbol': 'kr', 'name': 'DKK'},
    'Poland': {'symbol': 'zł', 'name': 'PLN'},
    'Argentina': {'symbol': '\$', 'name': 'ARS'},
    'Thailand': {'symbol': '฿', 'name': 'THB'},
    'South Africa': {'symbol': 'R', 'name': 'ZAR'},
    'Singapore': {'symbol': '\$', 'name': 'SGD'},
    'Malaysia': {'symbol': 'RM', 'name': 'MYR'},
    'Philippines': {'symbol': '₱', 'name': 'PHP'},
    'Hong Kong': {'symbol': 'HK\$', 'name': 'HKD'},
    'Egypt': {'symbol': 'E£', 'name': 'EGP'},
    'Pakistan': {'symbol': '₨', 'name': 'PKR'},
    'Bangladesh': {'symbol': '৳', 'name': 'BDT'},
    'Vietnam': {'symbol': '₫', 'name': 'VND'},
    'New Zealand': {'symbol': '\$', 'name': 'NZD'},
    'Czech Republic': {'symbol': 'Kč', 'name': 'CZK'},
    'Israel': {'symbol': '₪', 'name': 'ILS'},
    'United Arab Emirates': {'symbol': 'د.إ', 'name': 'AED'},
    'Taiwan': {'symbol': 'NT\$', 'name': 'TWD'},
    'Romania': {'symbol': 'lei', 'name': 'RON'},
    'Chile': {'symbol': '\$', 'name': 'CLP'},
    'Hungary': {'symbol': 'Ft', 'name': 'HUF'},
    'Colombia': {'symbol': '\$', 'name': 'COP'},
    'Ukraine': {'symbol': '₴', 'name': 'UAH'},
    'Nigeria': {'symbol': '₦', 'name': 'NGN'},
    'Kenya': {'symbol': 'KSh', 'name': 'KES'},
    'Morocco': {'symbol': 'د.م.', 'name': 'MAD'},
    'Peru': {'symbol': 'S/', 'name': 'PEN'},
    'Sri Lanka': {'symbol': 'Rs', 'name': 'LKR'},
    'Croatia': {'symbol': 'kn', 'name': 'HRK'},
    'Bulgaria': {'symbol': 'лв', 'name': 'BGN'},
    'Serbia': {'symbol': 'дин.', 'name': 'RSD'},
    'Kazakhstan': {'symbol': '₸', 'name': 'KZT'},
  };

  void changeCountry(String country) {
    selectedCountry.value = country;
    selectedCurrency.value = countryCurrencyMap[country]?['symbol'] ?? '\$';  // Default to USD symbol if not found
    selectedCurrencyName.value = countryCurrencyMap[country]?['name'] ?? 'USD';  // Default to USD if not found
  }
}