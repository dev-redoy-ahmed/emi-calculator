import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'CountryChangeController.dart';

class CountrySelectionScreen extends StatefulWidget {
  @override
  _CountrySelectionScreenState createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  List<MapEntry<String, Map<String, String>>> get filteredCountries {
    if (searchQuery.isEmpty) {
      return currencyController.countryCurrencyMap.entries.toList();
    }
    return currencyController.countryCurrencyMap.entries
        .where((entry) =>
    entry.key.toLowerCase().contains(searchQuery.toLowerCase()) ||
        entry.value['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(context),
          Expanded(
            child: _buildCountryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal.shade700, Colors.blue.shade700],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Text(
                'Select Your Country',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
            ),
            if (Navigator.of(context).canPop())
              Positioned(
                left: 10,
                top: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search countries or currencies',
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() => searchQuery = '');
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  Widget _buildCountryList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredCountries.length,
        itemBuilder: (context, index) {
          final entry = filteredCountries[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildCountryItem(entry.key, entry.value),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountryItem(String country, Map<String, String> currencyInfo) {
    return Obx(() {
      final isSelected = currencyController.selectedCountry.value == country;
      return Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Material(
          elevation: isSelected ? 8 : 2,
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          child: InkWell(
            onTap: () {
              currencyController.changeCountry(country);
              setState(() {});
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 70,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _getCountryFlag(country),
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          country,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          '${currencyInfo['symbol']} ${currencyInfo['name']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white70 : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  String _getCountryFlag(String countryName) {
    final Map<String, String> countryFlags = {
      'United States': '🇺🇸',
      'European Union': '🇪🇺',
      'United Kingdom': '🇬🇧',
      'Japan': '🇯🇵',
      'China': '🇨🇳',
      'Switzerland': '🇨🇭',
      'Canada': '🇨🇦',
      'Australia': '🇦🇺',
      'India': '🇮🇳',
      'Russia': '🇷🇺',
      'South Korea': '🇰🇷',
      'Brazil': '🇧🇷',
      'Mexico': '🇲🇽',
      'Indonesia': '🇮🇩',
      'Turkey': '🇹🇷',
      'Saudi Arabia': '🇸🇦',
      'Sweden': '🇸🇪',
      'Norway': '🇳🇴',
      'Denmark': '🇩🇰',
      'Poland': '🇵🇱',
      'Argentina': '🇦🇷',
      'Thailand': '🇹🇭',
      'South Africa': '🇿🇦',
      'Singapore': '🇸🇬',
      'Malaysia': '🇲🇾',
      'Philippines': '🇵🇭',
      'Hong Kong': '🇭🇰',
      'Egypt': '🇪🇬',
      'Pakistan': '🇵🇰',
      'Bangladesh': '🇧🇩',
      'Vietnam': '🇻🇳',
      'New Zealand': '🇳🇿',
      'Czech Republic': '🇨🇿',
      'Israel': '🇮🇱',
      'United Arab Emirates': '🇦🇪',
      'Taiwan': '🇹🇼',
      'Romania': '🇷🇴',
      'Chile': '🇨🇱',
      'Hungary': '🇭🇺',
      'Colombia': '🇨🇴',
      'Ukraine': '🇺🇦',
      'Nigeria': '🇳🇬',
      'Kenya': '🇰🇪',
      'Morocco': '🇲🇦',
      'Peru': '🇵🇪',
      'Sri Lanka': '🇱🇰',
      'Croatia': '🇭🇷',
      'Bulgaria': '🇧🇬',
      'Serbia': '🇷🇸',
      'Kazakhstan': '🇰🇿',
    };
    return countryFlags[countryName] ?? '🏳️';  // Default to white flag if not found
  }
}