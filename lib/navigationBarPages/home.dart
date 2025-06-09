import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tfc_industria/databaseconnector.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variáveis de estado para controlar a visibilidade dos textos
  bool showTextBlock1 = false;
  bool showTextBlock2 = false;
  bool showTextBlock3 = false;

  @override
  Widget build(BuildContext context) {
    // Configurações de tamanho
    double blockSize = 60.0;
    double iconBlockSize = 40.0;
    double lineWidth = 30.0;
    double lineThickness = 2.0;
    double parallelLineLength = 50.0;
    double parallelLineSpacing = 4.0;
    double spaceBetweenBlocksAndTabs = 20.0;

    return DefaultTabController(
      length: 3, // Número de abas
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 55.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildBlock(context, 'Bloco 1', blockSize, 1),
                      _buildLine(lineWidth, lineThickness),
                      _buildBlock(context, 'Bloco 2', blockSize, 2),
                      _buildLine(lineWidth, lineThickness),
                      _buildBlock(context, 'Bloco 3', blockSize, 3),
                      _buildParallelLines(parallelLineLength, lineThickness,
                          parallelLineSpacing),
                      _buildIconBlock(iconBlockSize),
                    ],
                  ),
                  SizedBox(height: 25),
                  if (showTextBlock1)
                    Text(
                        '* Introdução e Análise da Matéria Prima (Ingredientes) *', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (showTextBlock2)
                    Text('* Mistura da Matéria Prima + Formação do Produto *', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (showTextBlock3)
                    Text('* Conclusão do Produto (Embrulho + Saída) *', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: spaceBetweenBlocksAndTabs),
            Material(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Color(0xFFC2BABA),
                indicatorColor: Colors.red[900],
                tabs: [
                  Tab(text: 'Bloco 1'),
                  Tab(text: 'Bloco 2'),
                  Tab(text: 'Bloco 3'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MySQLDataList(),
                  // Conteúdo da aba "Bloco 1"
                  TaskTemperatureWidget(),
                  // Conteúdo da aba "Bloco 2"
                  Center(
                      child: Text(
                          'Processo de embrulho e saída do Produto ⚙️🍫🛍️ ...',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                  // Conteúdo da aba "Bloco 3"
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir um bloco
  Widget _buildBlock(
      BuildContext context, String title, double size, int blockNumber) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (blockNumber == 1) {
            showTextBlock1 = !showTextBlock1;
            showTextBlock2 = false;
            showTextBlock3 = false;
          } else if (blockNumber == 2) {
            showTextBlock2 = !showTextBlock2;
            showTextBlock1 = false;
            showTextBlock3 = false;
          } else if (blockNumber == 3) {
            showTextBlock3 = !showTextBlock3;
            showTextBlock1 = false;
            showTextBlock2 = false;
          }
        });
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Color(0xFF7A2119), width: 2.0),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Método para construir uma linha
  Widget _buildLine(double length, double thickness) {
    return Container(
      height: thickness,
      width: length,
      color: Colors.black,
    );
  }

  // Método para construir linhas paralelas
  Widget _buildParallelLines(double length, double thickness, double spacing) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: thickness,
          width: length,
          color: Colors.black,
        ),
        SizedBox(height: spacing),
        Container(
          height: thickness,
          width: length,
          color: Colors.black,
        ),
      ],
    );
  }

  // Método para construir um bloco com ícone
  Widget _buildIconBlock(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(0xFF4B140C),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Color(0xFF7A2119)),
      ),
      child: Center(
        child: Icon(
          MdiIcons.giftOpenOutline,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// Widget para ler dados do Firebase Realtime Database para a aba "Bloco 1"
// TODO:Begin; Trocar para MySQL
class MySQLDataList extends StatefulWidget {
  @override
  _MySQLDataListState createState() => _MySQLDataListState();
}

class _MySQLDataListState extends State<MySQLDataList> {
  final db = DatabaseConnector();
  List<Map<String, dynamic>> _dataList = [];

  // Definir uma lista de ícones
  final List<IconData> icons = [
    MdiIcons.peanutOutline,
    MdiIcons.cow,
    MdiIcons.seedOutline,
    MdiIcons.cheese,
    MdiIcons.bottleSoda,
    MdiIcons.barley,
    MdiIcons.spoonSugar,
    MdiIcons.potMixOutline,
    MdiIcons.cookieOutline,
    MdiIcons.leaf,
    MdiIcons.beehiveOutline,
    MdiIcons.shakerOutline,
    MdiIcons.bottleSodaClassic,
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await db.connect();
      final conn = db.connection;

      final result = await conn.execute(
          'SELECT nome, descricao FROM Ingrediente');


      setState(() {
        _dataList = result.rows.map((row) => {
          "nome": row.assoc()["nome"],
          "descricao": row.assoc()["descricao"]
        }).toList();
      });
    } catch (e) {
      print("Erro ao buscar dados: $e");
    } finally {
      await db.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        final item = _dataList[index];
        final icon = icons[index % icons.length]; // Escolhe o ícone baseado no índice

        final title = item['nome'] ?? 'Sem nome';
        final descricao = item['descricao'] ?? 'sem descricao';

        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: ListTile(
            leading: Icon(icon, color: Color(0xFF7A2119)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  descricao,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// TODO:END; Trocar para MySQL

// Widget da lista de tarefas e temperatura para a aba "Bloco 2"
class TaskTemperatureWidget extends StatefulWidget {
  @override
  _TaskTemperatureWidgetState createState() => _TaskTemperatureWidgetState();
}

class _TaskTemperatureWidgetState extends State<TaskTemperatureWidget> {
  final List<String> tasks = [
    'Entrada dos ingredientes',
    'Mistura Inicial dos Ingredientes',
    'Refinamento',
    'Conchagem ⬇️',
    'Adição Final de Ingredientes',
    'Temperagem + Moldagem e Resfriamento'
  ];

  final List<bool> _isChecked = List<bool>.filled(6, false);
  int _completedTasks = 0;
  double currentTemperature = 85.0;
  bool isIncreasing = true;
  late Timer _temperatureTimer;
  late Timer _taskTimer;

  @override
  void initState() {
    super.initState();
    _startTemperatureUpdate();
    _startTaskUpdate();
  }

  // Método para iniciar a atualização da temperatura
  void _startTemperatureUpdate() {
    _temperatureTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (isIncreasing) {
          currentTemperature += 1.0;
          if (currentTemperature >= 250.0) {
            isIncreasing = false;
          }
        } else {
          currentTemperature -= 1.0;
          if (currentTemperature <= 10.0) {
            isIncreasing = true;
          }
        }
      });
    });
  }

  // Método para iniciar a atualização das tarefas
  void _startTaskUpdate() {
    _taskTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        if (_completedTasks < tasks.length) {
          _isChecked[_completedTasks] = true;
          _completedTasks++;
        }
      });
    });
  }

  @override
  void dispose() {
    _temperatureTimer.cancel();
    _taskTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(
                    tasks[index],
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors
                            .black), // Alterado o tamanho da letra e a cor
                  ),
                  value: _isChecked[index],
                  onChanged: null, // Desativado para tornar automático
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _completedTasks / tasks.length,
                ),
                SizedBox(height: 10),
                Text(
                  '${(_completedTasks / tasks.length * 100).toInt()}% Completo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  _completedTasks == tasks.length ? 'Produto Feito!' : '',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: _completedTasks == tasks.length
                        ? Colors.green
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thermostat_outlined, size: 24, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Temperatura Atual: ${currentTemperature.toInt()}°',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
