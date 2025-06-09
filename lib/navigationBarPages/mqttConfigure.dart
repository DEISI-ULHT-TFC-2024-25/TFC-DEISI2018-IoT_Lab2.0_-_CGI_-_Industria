import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/material.dart';
import 'package:tfc_industria/databaseconnector.dart';

import '../notificationManager.dart';

class MQTTManager {
  final String host;
  final List<String> topics;
  late MqttServerClient client;
  Map<String, String> sensorData = {};
  final NotificationManager notificationManager;

  MQTTManager({required this.host, required this.topics}) : notificationManager = NotificationManager() {
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

    // Check the message content and show notification
    if (text == "Corre funcao 1 modo OK") {
      // Show notification for 2 seconds
      notificationManager.showNotification("The service was OK", "The service was functioning correctly.");
    } else if (text == "Corre funcao 2 modo NOT OK") {
      // Show notification for 2 seconds
      notificationManager.showNotification("The service was NOT OK", "There was an issue with the service.");
    }
  }

  void unsubscribe() {
    for (String topic in topics) {
      client.unsubscribe(topic);
    }
  }

  void disconnect() => client.disconnect();

  Future<String> insertSensorData(String table, Map<String, double> data) async {
    try {
      DatabaseConnector dbConnector = DatabaseConnector();
      await dbConnector.connect();
      final conn = dbConnector.connection;

      String sql = "";
      Map<String, dynamic> parameters = {};

      if (table == "PowerSensor") {
        sql = "INSERT INTO PowerSensor (voltage, current, power) VALUES (:voltage, :current, :power)";
        parameters = {
          "voltage": data['voltage'] ?? 0.0,
          "current": data['current'] ?? 0.0,
          "power": data['power'] ?? 0.0,
        };
      } else if (table == "DHT11Sensor") {
        sql = "INSERT INTO DHT11Sensor (temperature, humidity) VALUES (:temperature, :humidity)";
        parameters = {
          "temperature": data['temperature'] ?? 0.0,
          "humidity": data['humidity'] ?? 0.0,
        };
        debugPrint(sql);
      } else {
        return "Erro: Tabela desconhecida!";
      }


      var result = await conn.execute(sql, parameters);

      if (result.affectedRows > BigInt.zero) {
        return "Dados inseridos com sucesso na tabela $table";
      } else {
        return "Erro ao inserir os dados na tabela $table";
      }
    } catch (e) {
      return "Erro no banco de dados: $e";
    } finally {
      final db = DatabaseConnector();
      await db.close();
    }
  }

  // Handle incoming messages
  void onMessageReceived(String topic, String payload) async {

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

        String result = await insertSensorData("PowerSensor", data);
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

        String result = await insertSensorData("DHT11Sensor", data);
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