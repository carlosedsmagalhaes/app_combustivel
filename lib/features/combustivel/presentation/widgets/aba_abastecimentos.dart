import 'package:flutter/material.dart';

import 'package:app_combustivel/features/combustivel/models/abastecimento.dart';
import 'package:app_combustivel/features/combustivel/models/indicador.dart';
import 'package:app_combustivel/features/combustivel/presentation/formatacao.dart';
import 'package:app_combustivel/features/combustivel/presentation/widgets/mensagem_estado.dart';

// Aba Abastecimentos: lista com valor e indicadores de cada registro.
class AbaAbastecimentos extends StatelessWidget {
  final List<Indicador> indicadores; // Do mais antigo para o mais recente
  final void Function(Abastecimento abastecimento) aoExcluir;

  const AbaAbastecimentos({
    super.key,
    required this.indicadores,
    required this.aoExcluir,
  });

  String _linhaIndicadores(Indicador indicador) {
    final distancia = indicador.distancia;
    final kmPorLitro = indicador.kmPorLitro;
    final custoPorKm = indicador.custoPorKm;

    if (distancia == null || kmPorLitro == null || custoPorKm == null) {
      return 'Referência inicial (sem km/L e R\$/km)';
    }

    return '${formatarNumero(distancia, casas: 0)} km rodados · '
        '${formatarNumero(kmPorLitro, casas: 1)} km/L · '
        '${formatarReais(custoPorKm)}/km';
  }

  @override
  Widget build(BuildContext context) {
    if (indicadores.isEmpty) {
      return const MensagemEstado(
        icone: Icons.local_gas_station,
        texto: 'Nenhum abastecimento registrado.\nToque em Abastecer.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
      itemCount: indicadores.length,
      itemBuilder: (context, index) {
        // Mostra do mais recente para o mais antigo.
        final indicador = indicadores[indicadores.length - 1 - index];
        final a = indicador.abastecimento;

        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.local_gas_station)),
            title: Text(
              '${formatarData(a.dataHora)} ${formatarHora(a.dataHora)} · '
              '${a.combustivel.rotulo}',
            ),
            subtitle: Text(
              '${formatarNumero(a.litros)} L × ${formatarReais(a.precoLitro)} = '
              '${formatarReais(a.valorTotal)}\n'
              'Quilometragem: ${formatarNumero(a.quilometragem, casas: 0)} km\n'
              '${_linhaIndicadores(indicador)}',
            ),
            isThreeLine: true,
            trailing: IconButton(
              tooltip: 'Excluir abastecimento',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => aoExcluir(a),
            ),
          ),
        );
      },
    );
  }
}
