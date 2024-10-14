import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: Get.height * 0.11,
        width: Get.width * 0.21,
        child: Container(
          // decoration: BoxDecoration(
          //   color: Colors.transparent,
          //   borderRadius: BorderRadius.circular(5),
          //   border: Border.all(color: Colors.black12, width: 1),
          // ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Vertically center the icon and text
            crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center
            children: [
              Container(
                height: Get.height * 0.06, // Set a consistent height for the icon
                child: Icon(
                  icon,
                  color: color,
                  size: Get.height * 0.05, // Icon size relative to height
                ),
              ),
              SizedBox(height: Get.height * 0.01), // Adjust the spacing between icon and text
              Container(
                height: Get.height * 0.03, // Consistent height for the text
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Get.textScaleFactor * 14, // Responsive text size using GetX
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
