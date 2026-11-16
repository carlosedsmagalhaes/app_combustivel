import 'package:app_combustivel/features/combustivel/data/database/banco_combustivel.dart';
import 'package:app_combustivel/features/combustivel/models/abastecimento.dart';

// Operações na tabela abastecimentos.
class RepositorioAbastecimentos {
  static const _tabela = 'abastecimentos';

  const RepositorioAbastecimentos();

  // Do mais antigo para o mais recente: a ordem que o cálculo
  // dos indicadores precisa.
  Future<List<Abastecimento>> listar(int veiculoId) async {
    final banco = await BancoCombustivel.obter();
    final registros = await banco.query(
      _tabela,
      where: 'veiculo_id = ?',
      whereArgs: [veiculoId],
      orderBy: 'data_hora ASC, id ASC',
    );

    return registros.map((registro) => Abastecimento.deMapa(registro)).toList();
  }

  Future<int> inserir(Abastecimento abastecimento) async {
    final banco = await BancoCombustivel.obter();
    return banco.insert(_tabela, abastecimento.paraMapa());
  }

  Future<int> excluir(int id) async {
    final banco = await BancoCombustivel.obter();
    return banco.delete(_tabela, where: 'id = ?', whereArgs: [id]);
  }
}
