import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tfc_industria/databaseconnector.dart';


class AllPage extends StatefulWidget {
  @override
  _AllPageState createState() => _AllPageState();
}

class _AllPageState extends State<AllPage> {
  final db = DatabaseConnector();
  TouchLineBarSpot? touchedSpot;  // <- aqui, troque o tipo
  int? touchedSpotBarIndex;
  List<FlSpot> temperatureSpots = [];
  List<FlSpot> humiditySpots = [];
  List<String> dates = [];

  String idMachine = '-';
  String state = '-';
  String lastRead = '-';
  double voltage = 0;
  double current = 0;
  double power = 0;

  // Future que carrega os dados
  late Future<void> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await db.connect();
      final conn = db.connection;

      final result = await conn.execute(
          'SELECT id_maquina, DATE_FORMAT(data, "%Y-%m-%d %H:%i:%s") AS data, '
              'temperature, humidity, voltage, current, power, estado '
              'FROM AllData ORDER BY data DESC LIMIT 20'
      );

      List<Map<String, dynamic>> dataList = [];

      for (final row in result.rows) {
        final dataAssoc = row.assoc();

        double temperature = double.tryParse(dataAssoc["temperature"] ?? '0') ?? 0;
        double humidity = double.tryParse(dataAssoc["humidity"] ?? '0') ?? 0;
        double voltageVal = double.tryParse(dataAssoc["voltage"] ?? '0') ?? 0;
        double currentVal = double.tryParse(dataAssoc["current"] ?? '0') ?? 0;
        double powerVal = double.tryParse(dataAssoc["power"] ?? '0') ?? 0;

        dataList.add({
          "id_maquina": dataAssoc["id_maquina"],
          "data": dataAssoc["data"],
          "estado": dataAssoc["estado"],
          "temperature": temperature,
          "humidity": humidity,
          "voltage": voltageVal,
          "current": currentVal,
          "power": powerVal,
        });
      }

      dataList = dataList.reversed.toList();

      List<FlSpot> tempSpots = [];
      List<FlSpot> humSpots = [];
      List<String> dataStrings = [];

      for (int i = 0; i < dataList.length; i++) {
        tempSpots.add(FlSpot(i.toDouble(), dataList[i]["temperature"]));
        humSpots.add(FlSpot(i.toDouble(), dataList[i]["humidity"]));
        dataStrings.add(dataList[i]["data"]);
      }

      final firstRowDesc = dataList.isNotEmpty ? dataList.last : null;

      setState(() {
        temperatureSpots = tempSpots;
        humiditySpots = humSpots;
        dates = dataStrings;

        if (firstRowDesc != null) {
          idMachine = firstRowDesc["id_maquina"] ?? '-';
          state = firstRowDesc["estado"] ?? '-';
          lastRead = firstRowDesc["data"] ?? '-';
          voltage = firstRowDesc["voltage"] ?? 0;
          current = firstRowDesc["current"] ?? 0;
          power = firstRowDesc["power"] ?? 0;
        }
      });
    } catch (e) {
      print("Erro ao buscar dados: $e");
    } finally {
      await db.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar dados"));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          _buildKPIStatusCard(),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildOverlayCard()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildSensorCard()),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),


                  const Text(
                    "Últimas Leituras: Temperatura & Humidade",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildChart(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSensorCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sensores",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text("Tensão: $voltage V"),
                    Text("Corrente: $current A"),
                    Text("Potência: $power W"),
                    Text("Temperatura: ${temperatureSpots.isNotEmpty ? temperatureSpots.last.y.toStringAsFixed(1) : '-'}°C"),
                    Text("Umidade: ${humiditySpots.isNotEmpty ? humiditySpots.last.y.toStringAsFixed(1) : '-'}%"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIStatusCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "KPIs Gerais",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text("ID Máquina: $idMachine"),
                    Text("Estado: $state"),
                    Text("Última leitura: $lastRead"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (temperatureSpots.isEmpty || humiditySpots.isEmpty) {
      return const Center(
        child: Text("Nenhum dado para exibir"),
      );
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 5,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  if (value >= 10 && value <= 110 && value % 10 == 0) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: temperatureSpots,
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: humiditySpots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.transparent, // transparente
              tooltipRoundedRadius: 0,             // sem bordas
              tooltipPadding: EdgeInsets.zero,     // sem padding
              getTooltipItems: (touchedSpots) {
                return List.generate(touchedSpots.length, (_) => null);
              },
            ),
            touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
              if (response != null &&
                  response.lineBarSpots != null &&
                  response.lineBarSpots!.isNotEmpty) {
                setState(() {
                  touchedSpot = response.lineBarSpots!.first;
                  touchedSpotBarIndex = response.lineBarSpots!.first.barIndex;
                });
              } else {
                setState(() {
                  touchedSpot = null;
                  touchedSpotBarIndex = null;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayCard() {
    if (touchedSpot == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Toque no gráfico para ver detalhes'),
        ),
      );
    }

    int index = touchedSpot!.x.toInt();
    double temp = temperatureSpots[index].y;
    double hum = humiditySpots[index].y;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leitura Pressionada',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Temperatura: ${temp.toStringAsFixed(1)} °C'),
            Text('Umidade: ${hum.toStringAsFixed(1)} %'),
          ],
        ),
      ),
    );
  }
}





/*
import 'package:flutter/material.dart';


class AllPage extends StatelessWidget {
  AllPage({super.key});
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

 */

