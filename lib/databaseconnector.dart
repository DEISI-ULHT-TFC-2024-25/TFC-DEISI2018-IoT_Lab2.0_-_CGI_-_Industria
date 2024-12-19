import 'package:mysql1/mysql1.dart';

class DatabaseConnector {
  static final DatabaseConnector _instance = DatabaseConnector._internal();
  factory DatabaseConnector() => _instance;

  DatabaseConnector._internal();

  // Configurações da conexão
  final _settings = ConnectionSettings(
    host: '10.0.2.2',
    port: 3306,
    user: 'root',
    password: 'secret',
    db: 'IoT_Lab2_0',
  );

  Future<MySqlConnection> connect() async {
    try {
      return await MySqlConnection.connect(_settings);
    } catch (e) {
      throw Exception('Erro ao conectar à db: $e');
    }
  }
}
