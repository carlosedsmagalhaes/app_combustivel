// Funções de apresentação de números e datas no padrão brasileiro.

String _doisDigitos(int numero) => numero.toString().padLeft(2, '0');

// 1234.5 com 2 casas -> "1.234,50"
String formatarNumero(double valor, {int casas = 2}) {
  final partes = valor.toStringAsFixed(casas).split('.');
  final inteiro = partes[0];
  final negativo = inteiro.startsWith('-');
  final digitos = negativo ? inteiro.substring(1) : inteiro;

  // Coloca o ponto a cada 3 dígitos, da direita para a esquerda.
  final comPontos = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) comPontos.write('.');
    comPontos.write(digitos[i]);
  }

  final sinal = negativo ? '-' : '';
  return partes.length > 1
      ? '$sinal$comPontos,${partes[1]}'
      : '$sinal$comPontos';
}

String formatarReais(double valor) => 'R\$ ${formatarNumero(valor)}';

// "14/11/2026"
String formatarData(DateTime data) {
  final local = data.toLocal();
  return '${_doisDigitos(local.day)}/${_doisDigitos(local.month)}/${local.year}';
}

// "14:51"
String formatarHora(DateTime data) {
  final local = data.toLocal();
  return '${_doisDigitos(local.hour)}:${_doisDigitos(local.minute)}';
}

// "14/11"
String formatarDiaMes(DateTime data) {
  final local = data.toLocal();
  return '${_doisDigitos(local.day)}/${_doisDigitos(local.month)}';
}

// Aceita "5,89" ou "5.89". Devolve null se não for um número.
double? lerNumero(String texto) {
  return double.tryParse(texto.trim().replaceAll(',', '.'));
}
