import 'package:app_combustivel/features/combustivel/models/abastecimento.dart';

// Um abastecimento com os indicadores calculados em relação ao anterior.
class Indicador {
  final Abastecimento abastecimento;
  final double? distancia; // km rodados desde o abastecimento anterior
  final double? kmPorLitro;
  final double? custoPorKm; // R$/km

  const Indicador({
    required this.abastecimento,
    this.distancia,
    this.kmPorLitro,
    this.custoPorKm,
  });

  // O primeiro abastecimento é a referência inicial: não tem km/L nem R$/km.
  bool get referencia => kmPorLitro == null;

  // Recebe os abastecimentos do mais antigo para o mais recente.
  // Todos completam o tanque, então, a partir do segundo:
  //   distância = km atual - km anterior
  //   km/L      = distância / litros do abastecimento atual
  //   R$/km     = valor total do atual / distância
  static List<Indicador> calcular(List<Abastecimento> abastecimentos) {
    final indicadores = <Indicador>[];

    for (var i = 0; i < abastecimentos.length; i++) {
      final atual = abastecimentos[i];

      if (i == 0) {
        indicadores.add(Indicador(abastecimento: atual));
        continue;
      }

      final anterior = abastecimentos[i - 1];
      final distancia = atual.quilometragem - anterior.quilometragem;

      // Proteção contra divisão por zero ou dados inconsistentes.
      if (distancia <= 0 || atual.litros <= 0) {
        indicadores.add(Indicador(abastecimento: atual));
        continue;
      }

      indicadores.add(
        Indicador(
          abastecimento: atual,
          distancia: distancia,
          kmPorLitro: distancia / atual.litros,
          custoPorKm: atual.valorTotal / distancia,
        ),
      );
    }

    return indicadores;
  }
}
