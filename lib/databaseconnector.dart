import 'package:mysql_client/mysql_client.dart';

class DatabaseConnector {
  static final DatabaseConnector _instance = DatabaseConnector._internal();
  factory DatabaseConnector() => _instance;

  DatabaseConnector._internal();

  MySQLConnection? _conn;

  Future<void> connect() async {
    if (_conn == null) {
      try {
        _conn = await MySQLConnection.createConnection(
          host: "10.0.2.2",
          port: 3306,
          userName: "root",
          password: "ubuntu",
          databaseName: "IoT_Lab2_0",
        );
        await _conn!.connect();
      } catch (e) {
        print("Erro ao conectar à base de dados: $e");
        _conn = null;
        throw Exception("Erro ao conectar à base de dados: $e");
      }
    }
  }

  MySQLConnection get connection {
    if (_conn == null) {
      throw Exception("A conexão não foi inicializada.");
    }
    return _conn!;
  }

  Future<void> close() async {
    if (_conn != null) {
      await _conn!.close();
      _conn = null;
    }
  }
}