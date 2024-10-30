import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'mqttConfigure.dart';

class ControllerPage extends StatelessWidget {
  ControllerPage({super.key});

  final MQTTManager _myClient = MQTTManager(
      host: '169.254.222.162', topic: '22205245/anawen/device/test');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text(navigationsBarList[2].title),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 25, bottom: 25),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: Color(0xFF7A2119),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Fonte do Controlo',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A2119)),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: Color(0xFF7A2119),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Opções de Subscrição/Ligação',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildControllerButton('Subscribe', MdiIcons.timelinePlus,
                        () => _myClient.subscribe()),
                SizedBox(
                  width: 15,
                ),
                buildControllerButton('Unsubscrib', MdiIcons.timelineMinus,
                        () => _myClient.unsubscribe())
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Opções de Funcionamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildControllerButton('  OK        ', MdiIcons.stickerCheck,
                        () => _myClient.publishMessage('Corre função 2 modo OK')),
                SizedBox(
                  width: 15,
                ),
                buildControllerButton('NOT OK     ', MdiIcons.stickerAlert,
                        () => _myClient.publishMessage('Corre função 3 modo NOT OK')),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Opção de Fechar a Ligação',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildControllerButton(
                    'Disconnect',
                    MdiIcons.lanDisconnect,
                        () => _myClient.disconnect()),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget buildControllerButton(
      String label, IconData iconData, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 13.0),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Define a cor de fundo cinza
          borderRadius: BorderRadius.circular(10.0), // Cantos arredondados
          border: Border.all(
              color: Colors.black,
              width: 2), // Mantém a borda como está, mas ajusta a largura conforme necessário
        ),
        child: TextButton(
          onPressed: () {
            onPressed.call();
            debugPrint('Pressed $label');
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            minimumSize: Size(95, 15), // Largura e altura mínimas do botão
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData, color: Color(0xFF7A2119)), // Ícone vermelho
              SizedBox(width: 10), // Um pequeno espaço entre o ícone e o texto
              Text(label), // O texto que você deseja exibir
            ],
          ),
        ),
      ),
    );
  }
}
