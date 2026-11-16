import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:app_combustivel/features/combustivel/presentation/formatacao.dart';

// Gráfico de barras com o valor (R$) de cada abastecimento.
class GraficoBarras extends StatelessWidget {
  final String titulo;
  final List<double> valores;
  final List<String> rotulos;
  final Color cor;

  const GraficoBarras({
    super.key,
    required this.titulo,
    required this.valores,
    required this.rotulos,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    if (valores.isEmpty) return const SizedBox.shrink();

    final passo = max(1, (valores.length / 6).ceil());

    // Uma barra (BarChartGroupData) por abastecimento.
    final barras = <BarChartGroupData>[];
    for (var i = 0; i < valores.length; i++) {
      barras.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: valores[i],
              color: cor,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

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
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: valores.reduce(max) * 1.2,
                  barGroups: barras,
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
                          formatarNumero(valor, casas: 0),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
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
