import 'package:flutter/material.dart';
import 'package:sakesage/DatabaseHelper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'ProductDetailEVERY.dart';  // ProductDetailEvery 파일을 임포트
import 'package:intl/intl.dart';  // intl 패키지 임포트

class ProductListEveryScreen extends StatefulWidget {
  final String storeName;
  final String storeAddress;

  ProductListEveryScreen({required this.storeName, required this.storeAddress});

  @override
  _ProductListEveryScreenState createState() => _ProductListEveryScreenState();
}

class _ProductListEveryScreenState extends State<ProductListEveryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  final NumberFormat currencyFormat = NumberFormat('#,##0', 'en_US');  // NumberFormat 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await _dbHelper.connect();
    List<Map<String, dynamic>> products = await _dbHelper.getEverySakeStoreAndMenu();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '가게 위치',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),
            AutoSizeText(
              widget.storeAddress,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 20),
            Text(
              '상품 목록',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  final formattedPrice = currencyFormat.format(product['amount']); // 금액 포맷팅
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.network(
                        product['thumbnail'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product['name']),
                      subtitle: Text('가격:  ¥$formattedPrice'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailEveryScreen(product: product),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
