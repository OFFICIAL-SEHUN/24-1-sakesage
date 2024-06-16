import 'package:flutter/material.dart';
import 'package:sakesage/DatabaseHelper.dart';
import 'package:sakesage/login/auth_service.dart'; // AuthService를 임포트합니다.

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final DatabaseHelper db = DatabaseHelper();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> orderHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderHistory();
  }

  void fetchOrderHistory() async {
    String? userEmail = await _authService.getUserEmail();
    if (userEmail != null) {
      try {
        List<Map<String, dynamic>> fetchedOrderHistory = await db.fetchOrderHistory(userEmail);
        setState(() {
          orderHistory = fetchedOrderHistory;
          isLoading = false;
        });
      } catch (e) {
        print('Error fetching order history: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle case where userEmail is null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 내역'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orderHistory.isEmpty
          ? Center(child: Text('주문 내역이 없습니다.'))
          : ListView.builder(
        itemCount: orderHistory.length,
        itemBuilder: (context, index) {
          var order = orderHistory[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('주문 ID: ${order['order_id']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  if (order['image_url'] != null)
                    Image.network(
                      order['image_url'],
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  SizedBox(height: 8.0),
                  Text('사케 이름: ${order['sake_title']}'),
                  Text('가격: ¥${order['price']}'),
                  Text('수량: ${order['quantity']}'),
                  Text('주문 날짜: ${order['order_date']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
