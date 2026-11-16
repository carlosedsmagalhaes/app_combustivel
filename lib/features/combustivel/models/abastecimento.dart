enum Combustivel {
  etanol('Etanol'),
  gasolina('Gasolina'),
  diesel('Diesel');

  final String rotulo;

  const Combustivel(this.rotulo);
}

// Um abastecimento do veículo.
class Abastecimento {
  final int? id;
  final int veiculoId;
  final Combustivel combustivel;
  final double precoLitro; // R$ por litro
  final double quilometragem; // km no painel no momento do abastecimento
  final double litros;
  final DateTime dataHora;

  const Abastecimento({
    this.id,
    required this.veiculoId,
    required this.combustivel,
    required this.precoLitro,
    required this.quilometragem,
    required this.litros,
    required this.dataHora,
  });

  // Valor total = preço por litro × quantidade de litros.
  // É calculado, não gravado: assim nunca fica diferente dos dados.
  double get valorTotal => precoLitro * litros;

  // SQLite -> objeto
  Abastecimento.deMapa(Map<String, Object?> mapa)
    : id = mapa['id'] as int,
      veiculoId = mapa['veiculo_id'] as int,
      combustivel = Combustivel.values.byName(mapa['combustivel'] as String),
      precoLitro = (mapa['preco_litro'] as num).toDouble(),
      quilometragem = (mapa['quilometragem'] as num).toDouble(),
      litros = (mapa['litros'] as num).toDouble(),
      dataHora = DateTime.parse(mapa['data_hora'] as String);

  // objeto -> SQLite
  Map<String, Object?> paraMapa() {
    return {
      'veiculo_id': veiculoId,
      'combustivel': combustivel.name,
      'preco_litro': precoLitro,
      'quilometragem': quilometragem,
      'litros': litros,
      'data_hora': dataHora.toUtc().toIso8601String(),
    };
  }
}
