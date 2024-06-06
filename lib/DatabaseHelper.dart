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
}
