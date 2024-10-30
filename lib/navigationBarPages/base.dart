import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _typeProductController = TextEditingController();

  DatabaseReference listaBaseDados = FirebaseDatabase.instance.ref().child('listBasedados');

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = "${picked.hour}:${picked.minute}";
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isDate = true, bool isTime = false, bool customIconColor = false, bool readOnly = true}) {
    final Color customColor = Color(0xFF7A2119); // Definir a cor personalizada

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isDate) {
            _selectDate(context, controller);
          } else if (isTime) {
            _selectTime(context, controller);
          }
        },
        child: AbsorbPointer(
          absorbing: readOnly,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: Icon(icon, size: 20, color: customIconColor ? customColor : null), // Definir a cor do ícone condicionalmente
              labelText: label,
              labelStyle: TextStyle(fontSize: 14),
            ),
            readOnly: readOnly,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color customColor = Color(0xFF7A2119); // Definir a cor personalizada

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Divider(color: customColor), // Cor das linhas laterais ajustada
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Base Dados',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: customColor),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: customColor), // Cor das linhas laterais ajustada
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _buildTextField(_dateStartController, 'Data Inicial', MdiIcons.calendarSearch, customIconColor: true),
                SizedBox(width: 10),
                _buildTextField(_dateEndController, 'Data Final', MdiIcons.calendarSearch, customIconColor: true),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                _buildTextField(_timeController, 'Hora', MdiIcons.timerCog, isDate: false, isTime: true, customIconColor: true),
                SizedBox(width: 10),
                _buildTextField(_typeProductController, 'Tipo de Chocolate', MdiIcons.noteEdit, isDate: false, customIconColor: true, readOnly: false),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                print('Pesquisar com: ${_dateStartController.text} - ${_dateEndController.text}, Hora: ${_timeController.text}, Temp: ${_typeProductController.text}');
              },
              child: Text('Pesquisar', style: TextStyle(color: Colors.white)), // Cor do texto do botão
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
                backgroundColor: customColor, // Cor de fundo do botão
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: listaBaseDados.onValue,
                builder: (context, snapshot) {
                  print('Snapshot data: ${snapshot.data}');
                  if (snapshot.hasData && !snapshot.hasError && snapshot.data!.snapshot.value != null) {
                    Map data = snapshot.data!.snapshot.value as Map;
                    List<Map<String, dynamic>> items = [];
                    data.forEach((index, data) => items.add({"key": index, ...data}));

                    // Ordenar os itens pela hora em ordem decrescente
                    items.sort((a, b) {
                      DateTime timeA = DateTime.parse("2000-01-01 ${a['time']}:00");
                      DateTime timeB = DateTime.parse("2000-01-01 ${b['time']}:00");
                      return timeB.compareTo(timeA);
                    });

                    return ListView(
                      children: items.map((item) {
                        Color getIconColorEstado(String tipoTexto) {
                          switch (tipoTexto) {
                            case 'Em Produção...':
                              return Colors.orange;
                            case 'Fase da Mistura':
                              return Colors.red;
                            case 'Produzido com Sucesso !':
                              return Colors.green;
                            default:
                              return Colors.grey;
                          }
                        }

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: customColor), // Borda ao redor do Card
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['time'] ?? '',
                                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(item['date'] ?? ''),
                                    Row(
                                      children: [
                                        Icon(MdiIcons.thermometerHigh, size: 20, color: Colors.indigo),
                                        SizedBox(width: 5),
                                        Text(item['temperature'] ?? ''),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(width: 20),
                                Container(
                                  height: 60,
                                  width: 2,
                                  color: Color(0xFF7A2119),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(MdiIcons.viewComfyOutline, size: 20, color: Colors.brown),
                                          SizedBox(width: 5),
                                          Text(item['chocolateName'] ?? '', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(MdiIcons.counter, size: 20),
                                          SizedBox(width: 5),
                                          Text(item['NchocolateProduzir'] ?? '', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(MdiIcons.checkNetworkOutline, size: 20, color: getIconColorEstado(item['produzidoComSucesso'] ?? '')),
                                          SizedBox(width: 5),
                                          Text(item['produzidoComSucesso'] ?? '', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
