import 'package:flutter/material.dart';

import 'package:app_combustivel/features/combustivel/data/repositories/repositorio_veiculo.dart';
import 'package:app_combustivel/features/combustivel/models/opcao_fipe.dart';
import 'package:app_combustivel/features/combustivel/models/veiculo.dart';
import 'package:app_combustivel/features/combustivel/services/erro_consulta.dart';
import 'package:app_combustivel/features/combustivel/services/servico_fipe.dart';

class TelaCadastroVeiculo extends StatefulWidget {
  const TelaCadastroVeiculo({super.key});

  @override
  State<TelaCadastroVeiculo> createState() => _TelaCadastroVeiculoState();
}

class _TelaCadastroVeiculoState extends State<TelaCadastroVeiculo> {
  final _formKey = GlobalKey<FormState>();
  final _servico = const ServicoFipe();
  final _repositorio = const RepositorioVeiculo();
  final _anoController = TextEditingController();
  final _cilindradaController = TextEditingController();

  TipoVeiculo _tipo = TipoVeiculo.carros;

  // Marcas (vêm da BrasilAPI)
  List<OpcaoFipe> _marcas = [];
  bool _carregandoMarcas = false;
  String? _erroMarcas;
  OpcaoFipe? _marca;
  String? _avisoMarca;

  // Modelos (vêm da BrasilAPI, conforme a marca escolhida)
  List<OpcaoFipe> _modelos = [];
  bool _carregandoModelos = false;
  String? _erroModelos;
  OpcaoFipe? _modelo;
  String? _avisoModelo;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarMarcas();
  }

  Future<void> _carregarMarcas() async {
    final tipo = _tipo;

    setState(() {
      _carregandoMarcas = true;
      _erroMarcas = null;
      _marcas = [];
      _marca = null;
      _modelos = [];
      _modelo = null;
    });

    try {
      final marcas = await _servico.buscarMarcas(tipo);
      // Se o usuário trocou o tipo enquanto esperava, ignora esta resposta.
      if (!mounted || tipo != _tipo) return;
      setState(() => _marcas = marcas);
    } on ErroConsulta catch (erro) {
      if (!mounted || tipo != _tipo) return;
      setState(() => _erroMarcas = erro.mensagem);
    } catch (erro) {
      debugPrint('Erro inesperado ao buscar marcas: $erro');
      if (!mounted || tipo != _tipo) return;
      setState(() => _erroMarcas = 'Não foi possível carregar as marcas.');
    } finally {
      if (mounted && tipo == _tipo) setState(() => _carregandoMarcas = false);
    }
  }

  void _selecionarMarca(OpcaoFipe? marca) {
    if (marca == null) return;

    setState(() {
      _marca = marca;
      _avisoMarca = null;
      _modelo = null; // Trocou a marca: o modelo anterior não vale mais.
    });
    _carregarModelos(marca);
  }

  Future<void> _carregarModelos(OpcaoFipe marca) async {
    setState(() {
      _carregandoModelos = true;
      _erroModelos = null;
      _modelos = [];
    });

    try {
      final modelos = await _servico.buscarModelos(_tipo, marca.codigo);
      // Se o usuário trocou a marca enquanto esperava, ignora esta resposta.
      if (!mounted || _marca?.codigo != marca.codigo) return;
      setState(() => _modelos = modelos);
    } on ErroConsulta catch (erro) {
      if (!mounted || _marca?.codigo != marca.codigo) return;
      setState(() => _erroModelos = erro.mensagem);
    } catch (erro) {
      debugPrint('Erro inesperado ao buscar modelos: $erro');
      if (!mounted || _marca?.codigo != marca.codigo) return;
      setState(() => _erroModelos = 'Não foi possível carregar os modelos.');
    } finally {
      if (mounted && _marca?.codigo == marca.codigo) {
        setState(() => _carregandoModelos = false);
      }
    }
  }

  String? _validarAno(String? valor) {
    final ano = int.tryParse(valor?.trim() ?? '');
    final limite = DateTime.now().year + 1;

    if (ano == null) return 'Informe o ano.';
    if (ano < 1900 || ano > limite) {
      return 'Informe um ano entre 1900 e $limite.';
    }
    return null;
  }

  String? _validarCilindrada(String? valor) {
    final cilindrada = int.tryParse(valor?.trim() ?? '');

    if (cilindrada == null) return 'Informe a cilindrada em cm³.';
    if (cilindrada < 50 || cilindrada > 20000) {
      return 'Informe um valor entre 50 e 20000 cm³.';
    }
    return null;
  }

  Future<void> _salvar() async {
    final formularioValido = _formKey.currentState!.validate();
    final marca = _marca;
    final modelo = _modelo;

    // Marca e modelo não são TextFormField, então são conferidos à parte.
    setState(() {
      _avisoMarca = marca == null ? 'Selecione a marca.' : null;
      _avisoModelo = modelo == null ? 'Selecione o modelo.' : null;
    });

    if (!formularioValido || marca == null || modelo == null) return;

    setState(() => _salvando = true);

    try {
      await _repositorio.salvar(
        Veiculo(
          tipo: _tipo,
          marca: marca.nome,
          modelo: modelo.nome,
          ano: int.parse(_anoController.text.trim()),
          cilindrada: int.parse(_cilindradaController.text.trim()),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true); // Avisa a tela principal que salvou
    } catch (erro) {
      debugPrint('Erro ao salvar veículo: $erro');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o veículo.')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  // Linha mostrada enquanto uma lista carrega.
  Widget _carregandoLista(String texto) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      title: Text(texto),
    );
  }

  // Linha mostrada quando uma lista falha, com botão para tentar de novo.
  Widget _erroLista(String texto, VoidCallback tentarDeNovo) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.wifi_off, color: Colors.red),
      title: Text(texto),
      trailing: TextButton(
        onPressed: tentarDeNovo,
        child: const Text('Tentar'),
      ),
    );
  }

  Widget _campoMarca() {
    if (_carregandoMarcas) return _carregandoLista('Carregando marcas...');

    final erro = _erroMarcas;
    if (erro != null) return _erroLista(erro, _carregarMarcas);

    // DropdownMenu com filtro: o usuário digita e a lista é filtrada.
    // A key muda com o tipo para o campo começar vazio ao trocar o tipo.
    return DropdownMenu<OpcaoFipe>(
      key: ValueKey('marcas-${_tipo.name}'),
      expandedInsets: EdgeInsets.zero,
      label: const Text('Marca'),
      hintText: 'Digite para filtrar',
      enableFilter: true,
      requestFocusOnTap: true,
      menuHeight: 320,
      errorText: _avisoMarca,
      dropdownMenuEntries: [
        for (final marca in _marcas)
          DropdownMenuEntry(value: marca, label: marca.nome),
      ],
      onSelected: _selecionarMarca,
    );
  }

  Widget _campoModelo() {
    final marca = _marca;

    if (marca == null) {
      return DropdownMenu<OpcaoFipe>(
        enabled: false,
        expandedInsets: EdgeInsets.zero,
        label: const Text('Modelo'),
        helperText: 'Escolha a marca primeiro',
        errorText: _avisoModelo,
        dropdownMenuEntries: const [],
      );
    }

    if (_carregandoModelos) {
      return _carregandoLista('Carregando modelos de ${marca.nome}...');
    }

    final erro = _erroModelos;
    if (erro != null) return _erroLista(erro, () => _carregarModelos(marca));

    if (_modelos.isEmpty) {
      return const Text('Nenhum modelo encontrado para esta marca.');
    }

    // A key muda com a marca para o campo começar vazio ao trocar a marca.
    return DropdownMenu<OpcaoFipe>(
      key: ValueKey('modelos-${marca.codigo}'),
      expandedInsets: EdgeInsets.zero,
      label: const Text('Modelo'),
      hintText: 'Digite para filtrar',
      enableFilter: true,
      requestFocusOnTap: true,
      menuHeight: 320,
      errorText: _avisoModelo,
      dropdownMenuEntries: [
        for (final modelo in _modelos)
          DropdownMenuEntry(value: modelo, label: modelo.nome),
      ],
      onSelected: (modelo) => setState(() {
        _modelo = modelo;
        _avisoModelo = null;
      }),
    );
  }

  @override
  void dispose() {
    _anoController.dispose();
    _cilindradaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar veículo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Tipo de veículo'),
            const SizedBox(height: 8),
            SegmentedButton<TipoVeiculo>(
              segments: [
                for (final tipo in TipoVeiculo.values)
                  ButtonSegment(value: tipo, label: Text(tipo.rotulo)),
              ],
              selected: {_tipo},
              onSelectionChanged: (selecao) {
                setState(() => _tipo = selecao.first);
                _carregarMarcas();
              },
            ),
            const SizedBox(height: 20),
            _campoMarca(),
            const SizedBox(height: 16),
            _campoModelo(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _anoController,
              decoration: const InputDecoration(
                labelText: 'Ano',
                hintText: 'Ex.: 2020',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: _validarAno,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cilindradaController,
              decoration: const InputDecoration(
                labelText: 'Cilindrada do motor',
                hintText: 'Ex.: 1000 (motor 1.0) ou 160 (moto)',
                suffixText: 'cm³',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: _validarCilindrada,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(_salvando ? 'Salvando...' : 'Salvar veículo'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Marcas e modelos: BrasilAPI (tabela FIPE).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
