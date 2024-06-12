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
      String phone = row[2]?.toString() ?? 'N/A';  // phone이 null일 수 있으므로 기본값 설정
      String businessHours = row[3]?.toString() ?? 'N/A';  // business_hours가 null일 수 있으므로 기본값 설정

      print('Fetched store: $storeName, address: $address, phone: $phone, business hours: $businessHours'); // 디버깅 출력
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
    var query = 'SELECT no, title, price, taste, image_url, site_name, name FROM sake_info WHERE site_name LIKE ?';
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
        'name': row[6],
      });
    }
    print('Products: $products'); // 디버깅 출력
    return products;
  }

  Future<List<Map<String, dynamic>>> getReviews(String title) async {
    final conn = _connection;
    if (conn == null) {
      throw Exception('Database not connected');
    }
    var query = 'SELECT sake_title, review, date, writer, score FROM sake_review WHERE sake_title = ?';
    print('Querying reviews for title: $title'); // 디버깅 출력
    var results = await conn.query(query, [title]);
    List<Map<String, dynamic>> reviews = [];
    for (var row in results) {
      reviews.add({
        'sake_title': row[0],
        'review': row[1],
        'date': row[2],
        'writer': row[3],
        'score': row[4],
      });
    }
    print('Reviews: $reviews'); // 디버깅 출력
    return reviews;
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
