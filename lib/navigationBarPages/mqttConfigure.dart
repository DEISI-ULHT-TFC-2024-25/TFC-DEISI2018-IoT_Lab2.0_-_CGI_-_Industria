import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/material.dart';
import 'package:tfc_industria/databaseconnector.dart';
class MQTTManager {
  final String host;
  final List<String> topics; // Support multiple topics
  late MqttServerClient client;
  Map<String, String> sensorData = {}; // Store received sensor data

  MQTTManager({required this.host, required this.topics}) {
    connect();
  }

  Future<MqttServerClient> connect() async {
    client = MqttServerClient.withPort(host, '22205245/anawen/device/test', 1883);
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;

    try {
      await client.connect();
    } catch (e) {
      debugPrint('Exception: $e');
      client.disconnect();
    }




    // Listen for incoming messages
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (var message in messages) {
        final MqttPublishMessage recMessage = message.payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

        debugPrint('Received message: $payload from topic: ${message.topic}');

        // Store data and process it
        onMessageReceived(message.topic, payload);
      }
    });

    return client;
  }

  void subscribe() {
    for (String topic in topics) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void publishMessage(String topic, String text) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(text);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void unsubscribe() {
    for (String topic in topics) {
      client.unsubscribe(topic);
    }
  }

  void disconnect() {
    client.disconnect();
  }

  // Handle incoming messages
  void onMessageReceived(String topic, String payload) async {
    SensorToDataBase sensorDB = SensorToDataBase();


    if (topic == '22205245/anawen/device/power') {
      List<String> values = payload.split(',');
      if (values.length >= 3) {
        double voltage = double.parse(values[0].split(':')[1].trim().replaceAll('V', ''));
        double current = double.parse(values[1].split(':')[1].trim().replaceAll('mA', ''));
        double power = double.parse(values[2].split(':')[1].trim().replaceAll('mW', ''));

        Map<String, double> data = {
          "voltage": voltage,
          "current": current,
          "power": power
        };

        String result = await sensorDB.insertSensorData("PowerSensor", data);
        debugPrint(result);
      }
    }
    else if (topic == '22205245/anawen/device/dht11') {
      List<String> values = payload.split(',');
      if (values.length >= 2) {
        double temperature = double.parse(values[0].split(':')[1].trim().replaceAll('C', ''));
        double humidity = double.parse(values[1].split(':')[1].trim().replaceAll('%', ''));

        Map<String, double> data = {
          "temperature": temperature,
          "humidity": humidity
        };

        String result = await sensorDB.insertSensorData("DHT11Sensor", data);
        debugPrint(result);
      }
    }
  }



  // Connection callbacks
  void onConnected() => debugPrint('Connected');
  void onDisconnected() => debugPrint('Disconnected');
  void onSubscribed(String topic) => debugPrint('Subscribed topic: $topic');
  void onSubscribeFail(String topic) => debugPrint('Failed to subscribe $topic');
  void onUnsubscribed(String? topic) => debugPrint('Unsubscribed topic: $topic');
  void pong() => debugPrint('Ping response received');
}
class SensorToDataBase {
  final DatabaseConnector dbConnector = DatabaseConnector();

  Future<String> insertSensorData(String table, Map<String, double> data) async {
    try {
      await dbConnector.connect();
      final conn = dbConnector.connection;

      // Define the SQL INSERT statement based on the sensor type
      String sql = "";
      if (table == "PowerSensor") {
        sql = "INSERT INTO PowerSensor (voltage, current, power) VALUES (?, ?, ?)";

      } else if (table == "DHT11Sensor") {
        sql = "INSERT INTO DHT11Sensor (temperature, humidity) VALUES (?, ?)";
        debugPrint(sql);
      } else {
        return "Erro: Tabela desconhecida!";
      }

      // Map the keys of 'data' to parameters in the query
      Map<String, dynamic> parameters = {};

      if (table == "PowerSensor") {
        parameters = {
          '@voltage': data['voltage'],
          '@current': data['current'],
          '@power': data['power'],
        };
      } else if (table == "DHT11Sensor") {
        parameters = {
          '@temperature': data['temperature'],
          '@humidity': data['humidity'],
        };
      }

      // Execute the query with parameters as a Map
      var result = await conn.execute(sql, parameters);

      if (result.affectedRows > BigInt.from(0)) {
        return "Dados inseridos com sucesso na tabela $table";
      } else {
        return "Erro ao inserir os dados na tabela $table";
      }
    } catch (e) {
      return "Erro no banco de dados: $e";
    } finally {
      await dbConnector.close();
    }
  }



}