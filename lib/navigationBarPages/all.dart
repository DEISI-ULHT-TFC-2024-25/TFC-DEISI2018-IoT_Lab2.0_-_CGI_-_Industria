import 'package:flutter/material.dart';
import 'navigationsBarList.dart';
import 'mqttConfigure.dart';

class AllPage extends StatelessWidget {
  AllPage({super.key});
  //final MQTTManager _myClient = MQTTManager(host: '169.254.222.162', topic: '22205245/anawen/device/test');
  //_myClient.subscribe()
  //_myClient.unsubscribe()
  //_myClient.publishMessage('mensagem')
  //_myClient.disconnect()
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Em Atualização....😊⚙️',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
