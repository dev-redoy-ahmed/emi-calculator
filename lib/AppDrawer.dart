import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Constent/Theme Controller.dart';
import '../l10n_controller/CountryChangeController.dart';
import '../l10n_controller/language.dart';
import '../l10n_controller/CountrySelectionScreen.dart';

class AppDrawer extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();

  void _showBottomSheet(BuildContext context, String title, List<String> contentSections) {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 24),
                    ...contentSections.map((section) =>
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            section,
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                    ).toList(),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        child: Text(
                          AppLocalizations.of(context)?.close ?? 'Close',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 60),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Get.theme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.calculate, size: 40, color: Get.theme.primaryColor),
                ),
                SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)?.financial_calculator ?? 'Financial Calculator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Image.asset(
              'assets/translate.png',
              height: 28,
              width: 28,
            ),
            title: Text(AppLocalizations.of(context)?.language ?? 'Language', style: TextStyle(fontSize: 18)),
            onTap: () {
              Get.back();
              Get.to(() => LanguageScreen());
            },
          ),
          ListTile(
            leading: Icon(Icons.public, size: 28),
            title: Text(AppLocalizations.of(context)?.country ?? 'Country', style: TextStyle(fontSize: 18)),
            onTap: () {
              Get.back();
              Get.to(() => CountrySelectionScreen());
            },
          ),
          Obx(() => ListTile(
            leading: Icon(themeController.isDarkMode.value ? Icons.light_mode : Icons.nights_stay, size: 28),
            title: Text(
                themeController.isDarkMode.value
                    ? (AppLocalizations.of(context)?.light_mode ?? 'Light Mode')
                    : (AppLocalizations.of(context)?.dark_mode ?? 'Dark Mode'),
                style: TextStyle(fontSize: 18)
            ),
            onTap: () {
              themeController.toggleTheme();
              Get.back();
            },
          )),
          Divider(height: 1, thickness: 1),
          ListTile(
            leading: Icon(Icons.info, size: 28),
            title: Text(AppLocalizations.of(context)?.about ?? 'About', style: TextStyle(fontSize: 18)),
            onTap: () {
              Get.back();
              _showBottomSheet(
                  context,
                  AppLocalizations.of(context)?.about ?? 'About',
                  [
                    'Welcome to our Financial Calculator app, your ultimate tool for simplifying complex financial calculations.',
                    'Our app offers a comprehensive suite of calculators designed to help you make informed financial decisions quickly and accurately. Whether you\'re planning investments, calculating loan payments, or estimating retirement savings, we\'ve got you covered.',
                    'Key Features:\n• Loan Calculator: Determine monthly payments, interest costs, and amortization schedules.\n• Investment Calculator: Project future values of investments and analyze returns.\n• Retirement Planner: Estimate retirement savings and required contributions.\n• Mortgage Calculator: Calculate mortgage payments and compare different loan scenarios.\n• Savings Goal Calculator: Plan and track progress towards your savings goals.',
                    'Our user-friendly interface ensures that you can easily input your data and get clear, actionable results. We\'re committed to providing accurate, reliable calculations to support your financial planning needs.',
                    'Thank you for choosing our Financial Calculator app. We\'re here to empower you on your journey to financial success!'
                  ]
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.star, size: 28),
            title: Text(AppLocalizations.of(context)?.rate_us ?? 'Rate Us', style: TextStyle(fontSize: 18)),
            onTap: () {
              Get.back();
              _showBottomSheet(
                  context,
                  AppLocalizations.of(context)?.rate_us ?? 'Rate Us',
                  [
                    'We\'re committed to providing the best financial calculation tools to support your financial planning and decision-making.',
                    'If our app has been helpful in your financial journey, we would greatly appreciate your support. Please consider rating us on the app store and sharing your experience with others.',
                    'Your feedback is invaluable to us. It helps us understand what we\'re doing right and where we can improve. By rating our app, you\'re not only supporting our work but also helping other users discover a tool that could benefit their financial planning.',
                    'Moreover, your reviews and ratings enable us to continually enhance our calculators, add new features, and improve the overall user experience. This way, we can serve you and our community of users even better.',
                    'Thank you for being a part of our journey to make financial calculations accessible and easy for everyone. Your support means the world to us!'
                  ]
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description, size: 28),
            title: Text(AppLocalizations.of(context)?.terms_and_conditions ?? 'Terms & Conditions', style: TextStyle(fontSize: 18)),
            onTap: () {
              Get.back();
              _showBottomSheet(
                  context,
                  AppLocalizations.of(context)?.terms_and_conditions ?? 'Terms & Conditions',
                  [
                    'By using our Financial Calculator app, you agree to the following terms and conditions:',
                    '1. Information Purpose: Our app provides financial calculators for informational purposes only. While we strive for accuracy, we recommend verifying important calculations with a financial professional.',
                    '2. No Financial Advice: The calculations and results provided by this app do not constitute financial advice. We strongly recommend consulting with a qualified financial advisor for personalized guidance.',
                    '3. Accuracy: We make every effort to ensure the accuracy of our calculators. However, we cannot guarantee that all information and calculations are error-free. Users should independently verify critical financial decisions.',
                    '4. User Responsibility: Users are responsible for the accuracy of the data they input into the calculators. The quality of the results depends on the accuracy of the input data.',
                    '5. Updates: We reserve the right to update, modify, or discontinue any feature of the app at any time without prior notice.',
                    '6. Liability: We shall not be liable for any direct, indirect, incidental, consequential, or exemplary damages resulting from the use of this app or the information it provides.',
                    'By continuing to use this app, you acknowledge that you have read, understood, and agree to these terms and conditions.'
                  ]
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip, size: 28),
            title: Text(AppLocalizations.of(context)?.privacy_policy ?? 'Privacy Policy', style: TextStyle(fontSize: 18)),
            onTap: () {
              Get.back();
              _showBottomSheet(
                  context,
                  AppLocalizations.of(context)?.privacy_policy ?? 'Privacy Policy',
                  [
                    'At Financial Calculator, we take your privacy seriously. This policy outlines how we handle your data:',
                    '1. Data Collection: Our app performs all calculations locally on your device. We do not collect, store, or transmit any personal financial data you input into our calculators.',
                    '2. Usage Statistics: The app may collect anonymous usage statistics to help us improve our calculators and user experience. This data does not include any personal or financial information.',
                    '3. No Third-Party Sharing: We do not share any user data with third parties. Your calculations and financial information remain private and on your device.',
                    '4. App Permissions: Our app only requests necessary permissions to function properly on your device. We do not access any other areas of your device or other apps.',
                    '5. Security: While we don\'t store your data, we recommend using your device\'s built-in security features (like screen locks) to protect your financial information.',
                    '6. Updates: We may update this privacy policy from time to time. Please review it periodically for any changes.',
                    '7. Contact: If you have any questions about our privacy practices, please contact us at privacy@financialcalculator.com.',
                    'Your trust is important to us, and we are committed to protecting your privacy while providing valuable financial calculation tools.'
                  ]
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail, size: 28),
            title: Text(AppLocalizations.of(context)?.contact_us ?? 'Contact Us', style: TextStyle(fontSize: 18)),
            onTap: () {
              Get.back();
              _showBottomSheet(
                  context,
                  AppLocalizations.of(context)?.contact_us ?? 'Contact Us',
                  [
                    'We\'re here to help you get the most out of our financial calculators. '
                        'If you have any questions, suggestions, or need assistance, please email us at support@financialcalculator.com. '
                        'We aim to respond to all inquiries within 1-2 business days.'
                  ]
              );
            },
          ),
        ],
      ),
    );
  }
}