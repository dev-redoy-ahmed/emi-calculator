import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'language_change_controller.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final LanguageChangeController languageController = Get.find<LanguageChangeController>();
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> languages = [
    {'name': 'English', 'code': 'en', 'nativeName': 'English', 'flag': '🇬🇧'},
    {'name': 'Bengali', 'code': 'bn', 'nativeName': 'বাংলা', 'flag': '🇧🇩'},
    {'name': 'Hindi', 'code': 'hi', 'nativeName': 'हिंदी', 'flag': '🇮🇳'},
    {'name': 'Spanish', 'code': 'es', 'nativeName': 'Español', 'flag': '🇪🇸'},
    {'name': 'French', 'code': 'fr', 'nativeName': 'Français', 'flag': '🇫🇷'},
    {'name': 'German', 'code': 'de', 'nativeName': 'Deutsch', 'flag': '🇩🇪'},
    {'name': 'Japanese', 'code': 'ja', 'nativeName': '日本語', 'flag': '🇯🇵'},
    {'name': 'Korean', 'code': 'ko', 'nativeName': '한국어', 'flag': '🇰🇷'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredLanguages {
    if (searchQuery.isEmpty) {
      return languages;
    }
    return languages.where((lang) {
      return lang['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          lang['nativeName']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          lang['code']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(context),
          Expanded(
            child: _buildLanguageList(),
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
          colors: [Colors.blue.shade800, Colors.purple.shade800],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Text(
                AppLocalizations.of(context)?.choose_language ?? 'Choose Your Language',
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
          hintText: AppLocalizations.of(context)?.find_a_language ?? 'Search languages',
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

  Widget _buildLanguageList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredLanguages.length,
        itemBuilder: (context, index) {
          final lang = filteredLanguages[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildLanguageItem(lang),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageItem(Map<String, dynamic> lang) {
    return Obx(() {
      final isSelected = languageController.appLocale.value.languageCode == lang['code'];
      return Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Material(
          elevation: isSelected ? 8 : 2,
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          child: InkWell(
            onTap: () {
              languageController.changeLanguage(Locale(lang['code']!));
              setState(() {});
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 60, // Reduced height
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    lang['flag'],
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          lang['nativeName'],
                          style: TextStyle(
                            fontSize: 12,
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
}