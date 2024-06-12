import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  CartScreen({required this.cartItems});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니'),
      ),
      body: widget.cartItems.isEmpty
          ? Center(child: Text('장바구니가 비었습니다.'))
          : ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          return Card(
            child: ListTile(
              leading: Image.network(
                item['image_url'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(item['title']),
              subtitle: Text('가격: ${item['price']}원\n맛: ${item['taste']}'),
            ),
          );
        },
      ),
    );
  }
}
