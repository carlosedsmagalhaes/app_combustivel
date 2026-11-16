import 'package:flutter/material.dart';

import 'package:app_combustivel/features/combustivel/data/repositories/repositorio_abastecimentos.dart';
import 'package:app_combustivel/features/combustivel/models/abastecimento.dart';
import 'package:app_combustivel/features/combustivel/presentation/formatacao.dart';

class TelaNovoAbastecimento extends StatefulWidget {
  final int veiculoId;
  final Abastecimento? ultimo; // null quando é o primeiro abastecimento

  const TelaNovoAbastecimento({
    super.key,
    required this.veiculoId,
    required this.ultimo,
  });

  @override
  State<TelaNovoAbastecimento> createState() => _TelaNovoAbastecimentoState();
}

class _TelaNovoAbastecimentoState extends State<TelaNovoAbastecimento> {
  final _formKey = GlobalKey<FormState>();
  final _repositorio = const RepositorioAbastecimentos();
  final _precoController = TextEditingController();
  final _litrosController = TextEditingController();
  final _kmController = TextEditingController();

  late Combustivel _combustivel;
  DateTime _dataHora = DateTime.now();
  String? _avisoData;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    // Começa com o mesmo combustível do último abastecimento.
    _combustivel = widget.ultimo?.combustivel ?? Combustivel.gasolina;
  }

  // Valor total = preço × litros. null enquanto os campos estão incompletos.
  double? get _valorTotal {
    final preco = lerNumero(_precoController.text);
    final litros = lerNumero(_litrosController.text);
    if (preco == null || litros == null) return null;
    return preco * litros;
  }

  Future<void> _escolherData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateUtils.dateOnly(_dataHora),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (data == null || !mounted) return;

    setState(() {
      _dataHora = DateTime(
        data.year,
        data.month,
        data.day,
        _dataHora.hour,
        _dataHora.minute,
      );
    });
  }

  Future<void> _escolherHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataHora),
    );
    if (hora == null || !mounted) return;

    setState(() {
      _dataHora = DateTime(
        _dataHora.year,
        _dataHora.month,
        _dataHora.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  String? _validarPreco(String? valor) {
    final preco = lerNumero(valor ?? '');
    if (preco == null || preco <= 0) return 'Informe o preço por litro.';
    if (preco > 50) return 'Confira o preço: valor muito alto.';
    return null;
  }

  String? _validarLitros(String? valor) {
    final litros = lerNumero(valor ?? '');
    if (litros == null || litros <= 0) return 'Informe a quantidade de litros.';
    if (litros > 1000) return 'Confira a quantidade de litros.';
    return null;
  }

  // Todos os abastecimentos completam o tanque, então a quilometragem
  // precisa ser maior que a do anterior para calcular a distância.
  String? _validarKm(String? valor) {
    final km = lerNumero(valor ?? '');
    final ultimo = widget.ultimo;

    if (km == null || km < 0) return 'Informe a quilometragem.';
    if (ultimo != null && km <= ultimo.quilometragem) {
      return 'Deve ser maior que a do último abastecimento '
          '(${formatarNumero(ultimo.quilometragem, casas: 0)} km).';
    }
    return null;
  }

  String? _validarDataHora() {
    final ultimo = widget.ultimo;

    if (_dataHora.isAfter(DateTime.now())) {
      return 'A data e o horário não podem estar no futuro.';
    }
    if (ultimo != null && !_dataHora.isAfter(ultimo.dataHora)) {
      return 'Deve ser depois do último abastecimento '
          '(${formatarData(ultimo.dataHora)} ${formatarHora(ultimo.dataHora)}).';
    }
    return null;
  }

  Future<void> _salvar() async {
    final formularioValido = _formKey.currentState!.validate();
    final avisoData = _validarDataHora();
    setState(() => _avisoData = avisoData);

    if (!formularioValido || avisoData != null) return;

    setState(() => _salvando = true);

    try {
      await _repositorio.inserir(
        Abastecimento(
          veiculoId: widget.veiculoId,
          combustivel: _combustivel,
          // Os validadores já garantiram que os três números são válidos.
          precoLitro: lerNumero(_precoController.text)!,
          litros: lerNumero(_litrosController.text)!,
          quilometragem: lerNumero(_kmController.text)!,
          dataHora: _dataHora,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true); // Avisa a tela principal que salvou
    } catch (erro) {
      debugPrint('Erro ao salvar abastecimento: $erro');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o abastecimento.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  void dispose() {
    _precoController.dispose();
    _litrosController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = widget.ultimo;
    final total = _valorTotal;
    final avisoData = _avisoData;
    const teclado = TextInputType.numberWithOptions(decimal: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Novo abastecimento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Combustível'),
            const SizedBox(height: 8),
            SegmentedButton<Combustivel>(
              segments: [
                for (final combustivel in Combustivel.values)
                  ButtonSegment(
                    value: combustivel,
                    label: Text(combustivel.rotulo),
                  ),
              ],
              selected: {_combustivel},
              onSelectionChanged: (selecao) {
                setState(() => _combustivel = selecao.first);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _precoController,
              decoration: const InputDecoration(
                labelText: 'Preço por litro',
                hintText: 'Ex.: 5,89',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: teclado,
              textInputAction: TextInputAction.next,
              validator: _validarPreco,
              onChanged: (_) => setState(() {}), // Atualiza o valor total
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _litrosController,
              decoration: const InputDecoration(
                labelText: 'Quantidade de litros',
                hintText: 'Ex.: 40,5',
                suffixText: 'L',
                border: OutlineInputBorder(),
              ),
              keyboardType: teclado,
              textInputAction: TextInputAction.next,
              validator: _validarLitros,
              onChanged: (_) => setState(() {}), // Atualiza o valor total
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kmController,
              decoration: InputDecoration(
                labelText: 'Quilometragem do veículo',
                hintText: 'Ex.: 45230',
                suffixText: 'km',
                helperText: ultimo == null
                    ? 'Primeiro abastecimento: será a referência inicial.'
                    : 'Último abastecimento: '
                          '${formatarNumero(ultimo.quilometragem, casas: 0)} km',
                border: const OutlineInputBorder(),
              ),
              keyboardType: teclado,
              textInputAction: TextInputAction.done,
              validator: _validarKm,
            ),
            const SizedBox(height: 16),
            const Text('Data e horário do abastecimento'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _escolherData,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(formatarData(_dataHora)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _escolherHora,
                    icon: const Icon(Icons.access_time),
                    label: Text(formatarHora(_dataHora)),
                  ),
                ),
              ],
            ),
            if (avisoData != null) ...[
              const SizedBox(height: 6),
              Text(avisoData, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.payments),
                title: const Text('Valor total'),
                subtitle: const Text('Preço por litro × quantidade de litros'),
                trailing: Text(
                  total == null ? '--' : formatarReais(total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(_salvando ? 'Salvando...' : 'Salvar abastecimento'),
            ),
          ],
        ),
      ),
    );
  }
}
