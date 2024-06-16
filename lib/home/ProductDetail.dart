import 'package:flutter/material.dart';
import 'package:sakesage/DatabaseHelper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'Cart.dart';
import 'package:sakesage/login/auth_service.dart'; // AuthService import

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetail(this.product, {Key? key}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final DatabaseHelper db = DatabaseHelper();
  final AuthService _authService = AuthService(); // AuthService instance
  Map<String, dynamic>? review;
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReview();
  }

  Future<void> fetchReview() async {
    await db.connect();
    Map<String, dynamic>? fetchedReview = await db.getReview(widget.product['title']);
    print('Fetched review: $fetchedReview'); // 디버깅 출력
    setState(() {
      review = fetchedReview;
      isLoading = false;
    });
  }

  Future<void> addToCart() async {
    String? userEmail = await _authService.getUserEmail(); // 사용자 이메일 가져오기
    if (userEmail == null) return;

    await db.addToCart(
      userEmail,
      widget.product['title'],
      widget.product['price'].toString(),
      1, // 수량을 1로 설정 (필요에 따라 변경 가능)
    );
    setState(() {
      cartItems.add(widget.product);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('장바구니에 상품이 담겼습니다'),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildProductImage(double width, double height) {
    return Center(
      child: widget.product['image_url'] != null && widget.product['image_url'].isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          widget.product['image_url'],
          width: width / 2,
          height: height,
          fit: BoxFit.cover,
        ),
      )
          : Container(
        width: width / 2,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Icon(
            Icons.image,
            size: height / 2,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget buildProductTitle(double fontSize) {
    return AutoSizeText(
      widget.product['title'],
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      minFontSize: (fontSize * 0.8).roundToDouble(),
      stepGranularity: 0.1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildProductPrice(double fontSize) {
    return Text(
      '${widget.product['price']}',
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildProductSiteName(double fontSize) {
    return Text(
      '${widget.product['site_name']}',
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.grey[600],
      ),
    );
  }

  Widget buildProductTaste(double fontSize) {
    return Text(
      '${widget.product['taste'] ?? ''}',
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.black87,
      ),
    );
  }

  Widget buildAddToCartButton(double fontSize) {
    return ElevatedButton(
      onPressed: addToCart,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        textStyle: TextStyle(fontSize: fontSize),
      ),
      child: Text('장바구니에 담기'),
    );
  }

  Widget buildReview(Map<String, dynamic> review, double width, double height) {
    final imgurHeight = height;
    final imgurWidth = width * 0.7; // imgur 이미지 너비를 중앙으로 설정
    return Center(
      child: review['imgur_url'] != null && review['imgur_url'].isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          review['imgur_url'],
          width: imgurWidth,
          height: imgurHeight,
          fit: BoxFit.cover,
        ),
      )
          : Container(
        width: imgurWidth,
        height: imgurHeight,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Icon(
            Icons.image,
            size: imgurHeight / 2,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenHeight * 0.4; // Product image height remains the same
    final fontSizeTitle = screenHeight * 0.02; // Reduced font size
    final fontSizePrice = screenHeight * 0.015; // Reduced font size
    final fontSizeSiteName = screenHeight * 0.01; // Reduced font size
    final fontSizeTaste = screenHeight * 0.01; // Reduced font size

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['title']),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            iconSize: 36.0, // 아이콘 크기 설정
            onPressed: () async {
              String? userEmail = await _authService.getUserEmail(); // 사용자 이메일 가져오기
              if (userEmail != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(userEmail: userEmail), // 사용자 이메일 전달
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProductImage(screenWidth, imageHeight),
            SizedBox(height: 16.0),
            buildProductTitle(fontSizeTitle),
            SizedBox(height: 8.0),
            buildProductPrice(fontSizePrice),
            SizedBox(height: 8.0),
            buildProductSiteName(fontSizeSiteName),
            SizedBox(height: 16.0),
            buildProductTaste(fontSizeTaste),
            SizedBox(height: 16.0),
            buildAddToCartButton(fontSizeTaste), // '장바구니에 담기' 버튼 추가
            SizedBox(height: 16.0),
            Text(
              '한눈에 보이는 리뷰',
              style: TextStyle(
                fontSize: fontSizeTitle * 0.9,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : review == null
                ? Center(child: Text('리뷰가 없습니다.'))
                : buildReview(review!, screenWidth, imageHeight),
          ],
        ),
      ),
    );
  }
}
