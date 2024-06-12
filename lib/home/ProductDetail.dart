import 'package:flutter/material.dart';
import 'package:sakesage/DatabaseHelper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'Cart.dart';

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetail(this.product, {Key? key}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final DatabaseHelper db = DatabaseHelper();
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    await db.connect();
    List<Map<String, dynamic>> fetchedReviews = await db.getReviews(widget.product['title']);
    setState(() {
      reviews = fetchedReviews;
      isLoading = false;
    });
  }

  void addToCart() {
    setState(() {
      cartItems.add(widget.product);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cartItems: cartItems),
      ),
    );
  }

  Widget buildProductImage() {
    return widget.product['image_url'] != null
        ? ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.network(
        widget.product['image_url'],
        width: double.infinity,
        height: 200.0,
        fit: BoxFit.cover,
      ),
    )
        : Container(
      width: double.infinity,
      height: 200.0,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          size: 100,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget buildProductTitle() {
    return AutoSizeText(
      widget.product['title'],
      style: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      minFontSize: 18.0,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildProductPrice() {
    return Text(
      '${widget.product['price']}',
      style: TextStyle(
        fontSize: 24.0,
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildProductSiteName() {
    return Text(
      '${widget.product['site_name']}',
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.grey[600],
      ),
    );
  }

  Widget buildProductTaste() {
    return Text(
      '${widget.product['taste'] ?? ''}',
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.black87,
      ),
    );
  }

  Widget buildAddToCartButton() {
    return ElevatedButton(
      onPressed: addToCart,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        textStyle: TextStyle(fontSize: 18.0),
      ),
      child: Text('장바구니에 담기'),
    );
  }

  Widget buildReviewCard(Map<String, dynamic> review) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review['writer'],
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(review['review']),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: ${review['date']}'),
                Text('Score: ${review['score']}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReviews() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            var review = reviews[index];
            return buildReviewCard(review);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProductImage(),
            SizedBox(height: 16.0),
            buildProductTitle(),
            SizedBox(height: 8.0),
            buildProductPrice(),
            SizedBox(height: 8.0),
            buildProductSiteName(),
            SizedBox(height: 16.0),
            buildProductTaste(),
            SizedBox(height: 16.0),
            buildAddToCartButton(),
            SizedBox(height: 16.0),
            Text(
              '리뷰',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            buildReviews(),
          ],
        ),
      ),
    );
  }
}
