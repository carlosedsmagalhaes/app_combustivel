import 'package:flutter/material.dart';

import 'package:app_combustivel/features/combustivel/models/indicador.dart';
import 'package:app_combustivel/features/combustivel/presentation/formatacao.dart';
import 'package:app_combustivel/features/combustivel/presentation/widgets/grafico_barras.dart';
import 'package:app_combustivel/features/combustivel/presentation/widgets/grafico_linha.dart';
import 'package:app_combustivel/features/combustivel/presentation/widgets/mensagem_estado.dart';

// Aba Dashboard: resumo e gráficos dos indicadores.
class AbaDashboard extends StatelessWidget {
  final List<Indicador> indicadores; // Do mais antigo para o mais recente

  const AbaDashboard({super.key, required this.indicadores});

  // Média simples de uma lista de valores.
  double? _media(List<double> valores) {
    if (valores.isEmpty) return null;
    return valores.reduce((a, b) => a + b) / valores.length;
  }

  @override
  Widget build(BuildContext context) {
    if (indicadores.isEmpty) {
      return const MensagemEstado(
        icone: Icons.local_gas_station,
        texto: 'Registre o primeiro abastecimento para ver o dashboard.',
      );
    }

    final rotulos = indicadores
        .map((i) => formatarDiaMes(i.abastecimento.dataHora))
        .toList();
    final valores = indicadores.map((i) => i.abastecimento.valorTotal).toList();
    final consumos = indicadores.map((i) => i.kmPorLitro).toList();
    final custos = indicadores.map((i) => i.custoPorKm).toList();

    // whereType<double>() descarta os null (abastecimento de referência).
    final mediaConsumo = _media(consumos.whereType<double>().toList());
    final mediaCusto = _media(custos.whereType<double>().toList());
    final totalGasto = valores.reduce((a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      children: [
        Row(
          children: [
            Expanded(
              child: _Resumo(
                titulo: 'Total gasto',
                valor: formatarReais(totalGasto),
              ),
            ),
            Expanded(
              child: _Resumo(
                titulo: 'Consumo médio',
                valor: mediaConsumo == null
                    ? '--'
                    : '${formatarNumero(mediaConsumo, casas: 1)} km/L',
              ),
            ),
            Expanded(
              child: _Resumo(
                titulo: 'Custo médio',
                valor: mediaCusto == null
                    ? '--'
                    : '${formatarReais(mediaCusto)}/km',
              ),
            ),
          ],
        ),
        GraficoBarras(
          titulo: 'Valor de cada abastecimento (R\$)',
          valores: valores,
          rotulos: rotulos,
          cor: Colors.teal,
        ),
        if (mediaConsumo == null)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Os gráficos de consumo (km/L) e custo por km (R\$/km) '
                'aparecem a partir do segundo abastecimento. '
                'O primeiro serve de referência inicial.',
              ),
            ),
          )
        else ...[
          GraficoLinha(
            titulo: 'Consumo (km/L)',
            valores: consumos,
            rotulos: rotulos,
            cor: Colors.green,
            casas: 1,
          ),
          GraficoLinha(
            titulo: 'Custo por quilômetro (R\$/km)',
            valores: custos,
            rotulos: rotulos,
            cor: Colors.orange,
            casas: 2,
          ),
        ],
      ],
    );
  }
}

// Cartão pequeno com um número de resumo.
class _Resumo extends StatelessWidget {
  final String titulo;
  final String valor;

  const _Resumo({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(titulo, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              valor,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
