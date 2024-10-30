import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTManager {
  final String host;
  final String topic;
  late MqttServerClient client;

  MQTTManager({required this.host, required this.topic}) {
    connect();
  }

  Future<MqttServerClient> connect() async {
    client =
        MqttServerClient.withPort(host, '22205245/anawen/device/test', 1883);
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
      print('Exception: $e');
      client.disconnect();
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print('Received message:$payload from topic: ${c[0].topic}>');
    });

    return client;
  }

  void subscribe() {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void publishMessage(String text) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(text);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void unsubscribe() {
    client.unsubscribe(topic);
  }

  void disconnect() {
    client.disconnect();
  }

  // connection succeeded
  void onConnected() {
    print('Connected');
  }

// unconnected
  void onDisconnected() {
    print('Disconnected');
  }

// subscribe to topic succeeded
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

// subscribe to topic failed
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// unsubscribe succeeded
  void onUnsubscribed(String? topic) {
    print('Unsubscribed topic: $topic');
  }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }
}
