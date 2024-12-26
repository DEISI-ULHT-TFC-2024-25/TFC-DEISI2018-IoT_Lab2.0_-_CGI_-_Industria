import 'package:mysql_client/mysql_client.dart';

class DatabaseConnector {
  static final DatabaseConnector _instance = DatabaseConnector._internal();
  factory DatabaseConnector() => _instance;

  DatabaseConnector._internal();

  late final MySQLConnection _conn;

  // Configurações da conexão
  Future<void> connect() async {
    try {
      _conn = await MySQLConnection.createConnection(
        host: "10.0.2.2",
        port: 3309,
        userName: "root",
        password: "my-secret",
        databaseName: "Teste",
      );

      //await _conn.connect();
      //print("Conexão à base de dados bem-sucedida!");
    } catch (e) {
      print("Erro ao conectar à base de dados: $e");
      throw Exception('Erro ao conectar à db: $e');
    }
  }

  Future<void> close() async {
    if (_conn.connected) {
      await _conn.close();
      print("Conexão ao banco de dados encerrada.");
    } else {
      print("Conexão já estava fechada ou nunca foi inicializada.");
    }
  }

  MySQLConnection get connection => _conn; // Retorna a conexão ativa
}
