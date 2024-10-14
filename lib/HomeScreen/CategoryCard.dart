import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<Widget> items;

  CategoryCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.items,
  });

  void _showAllItems(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: EdgeInsets.all(Get.width * 0.05), // Responsive padding
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: Get.textScaleFactor * 20, // Responsive text size
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Get.height * 0.02), // Responsive height
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: Get.width * 0.02, // Responsive spacing
                      mainAxisSpacing: Get.width * 0.02, // Responsive spacing
                      children: items,
                    ),
                    SizedBox(height: Get.height * 0.02),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Get.width * 0.03), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      radius: Get.width * 0.05, // Responsive size for CircleAvatar
                      child: Icon(icon, color: color, size: Get.width * 0.07), // Responsive icon size
                    ),
                    SizedBox(width: Get.width * 0.03), // Responsive spacing
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: Get.textScaleFactor * 18, // Responsive text size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showAllItems(context),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: Get.textScaleFactor * 14, // Responsive text size
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.02), // Responsive height
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items.take(4).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
