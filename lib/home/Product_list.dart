import 'package:flutter/material.dart';

class Product_list_Screen extends StatefulWidget {
  const Product_list_Screen({super.key});

  @override
  State<Product_list_Screen> createState() => _Product_list_ScreenState();
}

class _Product_list_ScreenState extends State<Product_list_Screen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("술 목록보기"),
          Text("AI큐레이"),
        ],
      ),
    );
  }
}
