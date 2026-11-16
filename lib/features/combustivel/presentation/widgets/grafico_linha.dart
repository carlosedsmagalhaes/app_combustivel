import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:app_combustivel/features/combustivel/presentation/formatacao.dart';

// Gráfico de linha da evolução de um indicador (km/L ou R$/km).
// valores[i] é o indicador do abastecimento i; null = sem valor
// (o primeiro abastecimento, que é a referência).
class GraficoLinha extends StatelessWidget {
  final String titulo;
  final List<double?> valores;
  final List<String> rotulos; // Datas "dd/mm" do eixo X
  final Color cor;
  final int casas;

  const GraficoLinha({
    super.key,
    required this.titulo,
    required this.valores,
    required this.rotulos,
    required this.cor,
    this.casas = 1,
  });

  @override
  Widget build(BuildContext context) {
    // Cada ponto (FlSpot) é (x = posição do abastecimento, y = valor).
    final pontos = <FlSpot>[];
    for (var i = 0; i < valores.length; i++) {
      final valor = valores[i];
      if (valor != null) pontos.add(FlSpot(i.toDouble(), valor));
    }

    if (pontos.isEmpty) return const SizedBox.shrink();

    // Margem acima e abaixo da linha para ela não encostar nas bordas.
    final menor = pontos.map((p) => p.y).reduce(min);
    final maior = pontos.map((p) => p.y).reduce(max);
    final folga = maior == menor ? maior * 0.1 + 0.1 : (maior - menor) * 0.2;

    // Mostra no máximo uns 6 rótulos de data, para não amontoar.
    final passo = max(1, (valores.length / 6).ceil());

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text(
                titulo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  // Com um único valor, minX e maxX seriam iguais.
                  maxX: valores.length > 1 ? valores.length - 1.0 : 1.0,
                  minY: max(0.0, menor - folga),
                  maxY: maior + folga,
                  lineBarsData: [
                    LineChartBarData(spots: pontos, color: cor, barWidth: 3),
                  ],
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (valor, meta) => Text(
                          formatarNumero(valor, casas: casas),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 28,
                        getTitlesWidget: (valor, meta) {
                          final indice = valor.toInt();
                          if (indice < 0 ||
                              indice >= rotulos.length ||
                              indice % passo != 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              rotulos[indice],
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
