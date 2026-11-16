import 'package:flutter/material.dart';

import 'package:app_combustivel/features/combustivel/models/veiculo.dart';

// Aba Veículo: dados do veículo e o botão de exclusão.
class AbaVeiculo extends StatelessWidget {
  final Veiculo veiculo;
  final VoidCallback aoExcluir;

  const AbaVeiculo({super.key, required this.veiculo, required this.aoExcluir});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Tipo'),
                subtitle: Text(veiculo.tipo.rotulo),
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Marca'),
                subtitle: Text(veiculo.marca),
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Modelo'),
                subtitle: Text(veiculo.modelo),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Ano'),
                subtitle: Text('${veiculo.ano}'),
              ),
              ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('Cilindrada do motor'),
                subtitle: Text('${veiculo.cilindrada} cm³'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Para cadastrar outro veículo, exclua o atual. '
          'Os abastecimentos dele também serão excluídos.',
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: cores.error,
            foregroundColor: cores.onError,
          ),
          onPressed: aoExcluir,
          icon: const Icon(Icons.delete_forever),
          label: const Text('Excluir veículo'),
        ),
      ],
    );
  }
}
