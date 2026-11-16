import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:app_combustivel/features/combustivel/models/opcao_fipe.dart';
import 'package:app_combustivel/features/combustivel/models/veiculo.dart';
import 'package:app_combustivel/features/combustivel/services/erro_consulta.dart';

// Consulta marcas e modelos na BrasilAPI (dados da tabela FIPE).
class ServicoFipe {
  static const _base = 'https://brasilapi.com.br/api/fipe';
  static const _tempoLimite = Duration(seconds: 20);

  const ServicoFipe();

  // GET /fipe/marcas/v1/{tipo}  ->  [{"nome": "FIAT", "valor": "21"}, ...]
  Future<List<OpcaoFipe>> buscarMarcas(TipoVeiculo tipo) async {
    final lista = await _baixarLista('$_base/marcas/v1/${tipo.name}');
    return _converter(lista, chaveNome: 'nome');
  }

  // GET /fipe/veiculos/v1/{tipo}/{codigoMarca}
  //   ->  [{"modelo": "Uno Mille 1.0", "valor": "1234"}, ...]
  // Só traz os modelos da marca escolhida.
  Future<List<OpcaoFipe>> buscarModelos(
    TipoVeiculo tipo,
    String codigoMarca,
  ) async {
    final lista = await _baixarLista(
      '$_base/veiculos/v1/${tipo.name}/$codigoMarca',
    );
    return _converter(lista, chaveNome: 'modelo');
  }

  // Transforma a lista do JSON em objetos, ignorando itens incompletos,
  // e ordena em ordem alfabética.
  List<OpcaoFipe> _converter(List<dynamic> lista, {required String chaveNome}) {
    final opcoes = <OpcaoFipe>[];

    for (final item in lista) {
      if (item is! Map) continue;

      final codigo = item['valor']?.toString();
      final nome = item[chaveNome]?.toString();
      if (codigo == null || nome == null) continue;

      opcoes.add(OpcaoFipe(codigo: codigo, nome: nome));
    }

    opcoes.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return opcoes;
  }

  Future<List<dynamic>> _baixarLista(String endereco) async {
    final resposta = await _requisitar(Uri.parse(endereco));

    if (resposta.statusCode != 200) {
      throw ErroConsulta(
        'A BrasilAPI está indisponível (código ${resposta.statusCode}). '
        'Tente novamente mais tarde.',
      );
    }

    try {
      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (dados is List) return dados;
    } on FormatException {
      // Tratado logo abaixo, junto com o caso de não ser uma lista.
    }

    throw const ErroConsulta('A BrasilAPI retornou uma resposta inválida.');
  }

  Future<http.Response> _requisitar(Uri url) async {
    try {
      return await http.get(url).timeout(_tempoLimite);
    } on TimeoutException {
      throw const ErroConsulta(
        'A BrasilAPI demorou para responder. Tente novamente.',
      );
    } catch (_) {
      throw const ErroConsulta(
        'Sem conexão com a internet. Verifique e tente novamente.',
      );
    }
  }
}
