import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent.withOpacity(0.1),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Icon(
                    Icons.privacy_tip_rounded,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Welcome to our app! Your privacy is important to us, and we want to let you know that we do not collect, store, or share any personal information. All the calculations you perform (such as EMI, loan, or investment calculations) happen locally on your device. We do not send your data anywhere, and it stays completely private.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 24),
              Text(
                'Our app does not track your activity, and there are no ads or third-party services involved. The results you see from the calculators are for informational purposes only and should not be considered as financial advice. Please consult a professional for specific financial decisions.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 24),
              Text(
                'Since we don’t collect any data, our app is fully compliant with global privacy regulations like GDPR and CCPA.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 24),
              Text(
                'If you have any questions, feel free to contact us at [Your Email].',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 36),
              SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
