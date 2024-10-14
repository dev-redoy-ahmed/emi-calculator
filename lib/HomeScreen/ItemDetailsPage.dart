import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemDetailsPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  ItemDetailsPage({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: Get.textScaleFactor * 18, // Responsive text size
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: Get.width * 0.25, // Responsive icon size (25% of screen width)
              color: color,
            ),
            SizedBox(height: Get.height * 0.02), // Responsive spacing (2% of screen height)
            Text(
              title,
              style: TextStyle(
                fontSize: Get.textScaleFactor * 24, // Responsive title text size
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Get.height * 0.02), // Responsive spacing (2% of screen height)
            Text(
              'Details for $title will be shown here.',
              style: TextStyle(
                fontSize: Get.textScaleFactor * 16, // Responsive description text size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
