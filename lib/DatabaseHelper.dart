import 'dart:convert';

import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  final ConnectionSettings settings = ConnectionSettings(
    host: 'database-sakesage.c3suqkcwcjd4.ap-northeast-2.rds.amazonaws.com',
    port: 3306,
    user: 'admin',
    password: 'tkzptkzptkrp24',
    db: 'sakesage',
  );

  MySqlConnection? _connection;

  Future<void> connect() async {
    _connection = await MySqlConnection.connect(settings);
  }

  Future<List<Map<String, dynamic>>> getData() async {
    await connect(); // 데이터베이스 연결 확인
    final conn = _connection;
    if (conn == null) {
      throw Exception('Database not connected');
    }
    var results = await conn.query('SELECT no, title, price, taste, image_url, site_name, name FROM sake_info');
    List<Map<String, dynamic>> data = [];
    for (var row in results) {
      data.add({
        'no': row[0],
        'title': row[1],
        'price': row[2],
        'taste': row[3],
        'image_url': row[4],
        'site_name': row[5],
        'name': row[6],
      });
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getStoreLocations() async {
    final conn = _connection;
    if (conn == null) {
      throw Exception('Database not connected');
    }
    var results = await conn.query('SELECT store_name, address, phone, business_hours FROM sake_store_info');
    List<Map<String, dynamic>> storeLocations = [];
    for (var row in results) {
      String storeName = row[0].toString();
      String address = row[1].toString();
      String phone = row[2]?.toString() ?? 'N/A';
      String businessHours = row[3]?.toString() ?? 'N/A';

      print('Fetched store: $storeName, address: $address, phone: $phone, business hours: $businessHours');
      storeLocations.add({
        'store_name': storeName,
        'address': address,
        'phone': phone,
        'business_hours': businessHours,
      });
    }
    return storeLocations;
  }

  Future<List<Map<String, dynamic>>> getStoreProducts(String storeName) async {
    final conn = _connection;
    if (conn == null) {
      throw Exception('Database not connected');
    }
    var query = 'SELECT no, title, price, taste, image_url, site_name FROM sake_info WHERE site_name LIKE ?';
    var results = await conn.query(query, ['%$storeName%']);
    List<Map<String, dynamic>> products = [];
    for (var row in results) {
      products.add({
        'no': row[0],
        'title': row[1],
        'price': row[2],
        'taste': row[3],
        'image_url': row[4],
        'site_name': row[5],
      });
    }
    print('Products: $products');
    return products;
  }

  Future<Map<String, dynamic>?> getReview(String title) async {
    final conn = _connection;
    if (conn == null) {
      throw Exception('Database not connected');
    }
    var query = '''
    SELECT 
        sake_info.title COLLATE utf8mb4_unicode_ci AS title, 
        sake_info.image_url, 
        sake_review.imgur_url,
        sake_review.explanation
    FROM 
        sake_info
    JOIN 
        sake_review 
    ON 
        sake_info.title COLLATE utf8mb4_unicode_ci = sake_review.sake_title COLLATE utf8mb4_unicode_ci
    WHERE
        sake_info.title COLLATE utf8mb4_unicode_ci = ?
        AND sake_review.imgur_url IS NOT NULL 
        AND sake_review.imgur_url != ''
    LIMIT 1;
  ''';
    print('Querying review for title: $title');
    var results = await conn.query(query, [title]);

    if (results.isEmpty) {
      return null;  // 결과가 없으면 null 반환
    }

    var row = results.first;
    Map<String, dynamic> review = {
      'sake_title': row[0],
      'image_url': row[1],
      'imgur_url': row[2] != null ? row[2] as String : null,
      'explanation': row[3],
    };

    print('Review: $review');
    return review;
  }



  Future<List<Map<String, dynamic>>> searchData(String query) async {
    final conn = _connection;
    if (conn == null) {
      throw Exception('Database not connected');
    }
    var results = await conn.query('SELECT title, price, image_url FROM sake_info WHERE title LIKE ?', ['%$query%']);
    List<Map<String, dynamic>> searchResults = [];
    for (var row in results) {
      searchResults.add({
        'title': row[0],
        'price': row[1],
        'image_url': row[2],
      });
    }
    return searchResults;
  }

  Future<List<Map<String, dynamic>>> getCuratedSake(String recipient, String flavor, String body, String aroma) async {
    final conn = _connection;
    if (conn == null) {
      throw Exception('Database not connected');
    }
    var results = await conn.query(
        'SELECT sake_id, name, flavor, aroma, body, recipient_type, occasion '
            'FROM sake_curation '
            'WHERE recipient_type = ? AND flavor = ? AND body = ? AND aroma = ?',
        [recipient, flavor, body, aroma]);
    List<Map<String, dynamic>> curatedSake = [];
    for (var row in results) {
      curatedSake.add({
        'sake_id': row[0],
        'name': row[1],
        'flavor': row[2],
        'aroma': row[3],
        'body': row[4],
        'recipient_type': row[5],
        'occasion': row[6],
      });
    }
    return curatedSake;
  }
}
