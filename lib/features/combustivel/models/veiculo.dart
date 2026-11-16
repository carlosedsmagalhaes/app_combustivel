// Tipos aceitos pela BrasilAPI. O name ("carros", "motos", "caminhoes")
// vai direto na URL; o rótulo aparece na tela.
enum TipoVeiculo {
  carros('Carro'),
  motos('Moto'),
  caminhoes('Caminhão');

  final String rotulo;

  const TipoVeiculo(this.rotulo);
}

// O veículo cadastrado (o app guarda apenas um por vez).
class Veiculo {
  final int? id;
  final TipoVeiculo tipo;
  final String marca;
  final String modelo;
  final int ano;
  final int cilindrada; // em cm³ (ex.: 1000 = motor 1.0)

  const Veiculo({
    this.id,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.cilindrada,
  });

  // SQLite -> objeto
  Veiculo.deMapa(Map<String, Object?> mapa)
    : id = mapa['id'] as int,
      tipo = TipoVeiculo.values.byName(mapa['tipo'] as String),
      marca = mapa['marca'] as String,
      modelo = mapa['modelo'] as String,
      ano = mapa['ano'] as int,
      cilindrada = mapa['cilindrada'] as int;

  // objeto -> SQLite (sem o id: o banco gera)
  Map<String, Object?> paraMapa() {
    return {
      'tipo': tipo.name,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'cilindrada': cilindrada,
    };
  }
}
