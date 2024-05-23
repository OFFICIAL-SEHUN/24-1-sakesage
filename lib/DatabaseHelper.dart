import 'package:mysql_client/mysql_client.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late MySQLConnection _connection;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<void> connect() async {
    _connection = await MySQLConnection.createConnection(
      host: 'database-sakesage.c3suqkcwcjd4.ap-northeast-2.rds.amazonaws.com',
      port: 3306,
      userName: 'admin',
      password: 'tkzptkzptkrp24',
      databaseName: 'sakesage',
    );
    await _connection.connect();
  }

  MySQLConnection get connection => _connection;

  Future<List<Map<String, dynamic>>> getUsers() async {
    var result = await _connection.execute('SELECT no, name FROM sake_info');
    List<Map<String, dynamic>> users = [];
    for (final row in result.rows) {
      users.add({
        'no': row.colAt(0),
        'name': row.colAt(1),
      });
    }
    return users;
  }

  Future<void> close() async {
    await _connection.close();
  }
}
