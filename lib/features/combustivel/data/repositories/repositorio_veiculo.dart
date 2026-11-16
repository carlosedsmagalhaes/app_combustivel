import 'package:app_combustivel/features/combustivel/data/database/banco_combustivel.dart';
import 'package:app_combustivel/features/combustivel/models/veiculo.dart';

// Operações na tabela veiculo.
class RepositorioVeiculo {
  const RepositorioVeiculo();

  // O app trabalha com um veículo por vez: devolve o cadastrado ou null.
  Future<Veiculo?> buscar() async {
    final banco = await BancoCombustivel.obter();
    final registros = await banco.query('veiculo', limit: 1);

    if (registros.isEmpty) return null;
    return Veiculo.deMapa(registros.first);
  }

  Future<int> salvar(Veiculo veiculo) async {
    final banco = await BancoCombustivel.obter();

    // Regra do enunciado: só um veículo por vez.
    final existentes = await banco.query('veiculo', limit: 1);
    if (existentes.isNotEmpty) {
      throw StateError('Já existe um veículo cadastrado.');
    }

    return banco.insert('veiculo', veiculo.paraMapa());
  }

  // Exclui o veículo E os abastecimentos dele.
  // A transação garante que as duas exclusões acontecem juntas:
  // se uma falhar, nenhuma é aplicada.
  Future<void> excluir(int veiculoId) async {
    final banco = await BancoCombustivel.obter();

    await banco.transaction((txn) async {
      await txn.delete(
        'abastecimentos',
        where: 'veiculo_id = ?',
        whereArgs: [veiculoId],
      );
      await txn.delete('veiculo', where: 'id = ?', whereArgs: [veiculoId]);
    });
  }
}
