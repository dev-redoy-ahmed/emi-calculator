import 'package:emicalculator/privacy_policy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen/home_page.dart';
import 'l10n_controller/CountrySelectionScreen.dart';
import 'l10n_controller/language.dart';

class OnboardingScreen extends StatelessWidget {
  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;

  final List<Widget> _pages = [
    PrivacyPolicy(),
    LanguageScreen(),
    CountrySelectionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => _currentPage.value = index,
            children: _pages,
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                child: Text(
                  _currentPage.value == 0
                      ? 'Agree & Continue'
                      : _currentPage.value == 1
                      ? 'Confirm & Continue'
                      : 'Get Started',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Button corner radius
                  ),
                ),
                onPressed: () {
                  if (_currentPage.value < 2) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
              )),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    Get.off(() => Home());
  }
}
