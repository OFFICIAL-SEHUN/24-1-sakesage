import 'package:flutter/material.dart';
import 'package:sakesage/DatabaseHelper.dart';
import 'package:sakesage/payment/paymentpage.dart'; // PaymentPage를 임포트합니다.

class CartScreen extends StatefulWidget {
  final String userEmail; // 사용자 이메일을 받는 매개변수 추가

  const CartScreen({Key? key, required this.userEmail}) : super(key: key); // 생성자 수정

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseHelper db = DatabaseHelper();
  List<Map<String, dynamic>> cartItem = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  void fetchCartItems() async {
    try {
      // widget.userEmail을 사용하여 사용자 이메일 전달
      List<Map<String, dynamic>> fetchedItems = await db.bringFromCart(widget.userEmail);
      setState(() {
        cartItem = fetchedItems;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching cart items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  double calculateTotalPrice() {
    double total = 0.0;
    for (var item in cartItem) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  void moveCartToOrderHistory() async {
    try {
      await db.moveCartToOrderHistory(widget.userEmail);
      setState(() {
        cartItem.clear();
      });
    } catch (e) {
      print('Error moving cart items to order history: $e');
    }
  }

  void deleteCartItem(String sakeTitle) async {
    try {
      await db.deleteCartItem(widget.userEmail, sakeTitle);
      fetchCartItems(); // 장바구니 항목을 다시 불러와 화면 갱신
    } catch (e) {
      print('Error deleting cart item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    int crossAxisCount = screenSize.width < 600 ? 1 : 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '   장바구니 아이템',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      '총 가격: ¥${calculateTotalPrice().toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        moveCartToOrderHistory();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PaymentPage()),
                        );
                      },
                      child: Text('결제하기'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: cartItem.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItem[index]['sake_title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text('¥${cartItem[index]['price']}'),
                              Text('수량 ${cartItem[index]['quantity']}'),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteCartItem(cartItem[index]['sake_title']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
