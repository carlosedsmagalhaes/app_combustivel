import 'package:flutter/material.dart';

import 'package:app_combustivel/features/combustivel/data/repositories/repositorio_abastecimentos.dart';
import 'package:app_combustivel/features/combustivel/data/repositories/repositorio_veiculo.dart';
import 'package:app_combustivel/features/combustivel/models/abastecimento.dart';
import 'package:app_combustivel/features/combustivel/models/indicador.dart';
import 'package:app_combustivel/features/combustivel/models/veiculo.dart';
import 'package:app_combustivel/features/combustivel/presentation/screens/tela_cadastro_veiculo.dart';
import 'package:app_combustivel/features/combustivel/presentation/screens/tela_novo_abastecimento.dart';
import 'package:app_combustivel/features/combustivel/presentation/widgets/aba_abastecimentos.dart';
import 'package:app_combustivel/features/combustivel/presentation/widgets/aba_dashboard.dart';
import 'package:app_combustivel/features/combustivel/presentation/widgets/aba_veiculo.dart';
import 'package:app_combustivel/features/combustivel/presentation/widgets/mensagem_estado.dart';

// Tela inicial. Sem veículo: pede o cadastro.
// Com veículo: mostra as abas Dashboard, Abastecimentos e Veículo.
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final _repositorioVeiculo = const RepositorioVeiculo();
  final _repositorioAbastecimentos = const RepositorioAbastecimentos();

  Veiculo? _veiculo;
  List<Abastecimento> _abastecimentos = [];
  bool _carregando = true;
  String? _erro;
  int _aba = 0; // 0 = Dashboard, 1 = Abastecimentos, 2 = Veículo

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // Lê o veículo e os abastecimentos salvos no SQLite.
  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final veiculo = await _repositorioVeiculo.buscar();
      final abastecimentos = veiculo == null
          ? <Abastecimento>[]
          : await _repositorioAbastecimentos.listar(veiculo.id!);

      if (!mounted) return;
      setState(() {
        _veiculo = veiculo;
        _abastecimentos = abastecimentos;
      });
    } catch (erro) {
      debugPrint('Erro ao carregar os dados: $erro');
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível ler os dados salvos.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _cadastrarVeiculo() async {
    // A tela de cadastro devolve true quando salva o veículo.
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const TelaCadastroVeiculo()),
    );

    if (salvou == true) await _carregar();
  }

  Future<void> _novoAbastecimento() async {
    final veiculo = _veiculo;
    if (veiculo == null) return;

    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaNovoAbastecimento(
          veiculoId: veiculo.id!,
          // O último registro serve para validar a nova quilometragem e data.
          ultimo: _abastecimentos.isEmpty ? null : _abastecimentos.last,
        ),
      ),
    );

    if (salvou != true) return;
    await _carregar();
    _mostrarMensagem('Abastecimento registrado.');
  }

  // Janela de confirmação reutilizada nas duas exclusões.
  Future<bool> _confirmar(String titulo, String texto, String acao) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(acao),
          ),
        ],
      ),
    );

    // Tocar fora da janela devolve null: conta como "não".
    return confirmado == true;
  }

  Future<void> _excluirAbastecimento(Abastecimento abastecimento) async {
    final confirmado = await _confirmar(
      'Excluir abastecimento',
      'Este abastecimento será excluído permanentemente.',
      'Excluir',
    );
    if (!confirmado) return;

    try {
      await _repositorioAbastecimentos.excluir(abastecimento.id!);
      await _carregar();
      _mostrarMensagem('Abastecimento excluído.');
    } catch (erro) {
      debugPrint('Erro ao excluir abastecimento: $erro');
      _mostrarMensagem('Não foi possível excluir o abastecimento.');
    }
  }

  Future<void> _excluirVeiculo() async {
    final veiculo = _veiculo;
    if (veiculo == null) return;

    final confirmado = await _confirmar(
      'Excluir veículo',
      'O veículo ${veiculo.marca} ${veiculo.modelo} e seus '
          '${_abastecimentos.length} abastecimento(s) serão excluídos '
          'permanentemente.',
      'Excluir veículo',
    );
    if (!confirmado) return;

    try {
      await _repositorioVeiculo.excluir(veiculo.id!);
      _aba = 0;
      await _carregar();
      _mostrarMensagem('Veículo e abastecimentos excluídos.');
    } catch (erro) {
      debugPrint('Erro ao excluir veículo: $erro');
      _mostrarMensagem('Não foi possível excluir o veículo.');
    }
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final erro = _erro;
    if (erro != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Controle de Combustível')),
        body: MensagemEstado(
          icone: Icons.error_outline,
          texto: erro,
          textoBotao: 'Tentar novamente',
          aoPressionar: _carregar,
        ),
      );
    }

    final veiculo = _veiculo;
    if (veiculo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Controle de Combustível')),
        body: MensagemEstado(
          icone: Icons.directions_car,
          texto:
              'Nenhum veículo cadastrado.\n'
              'Cadastre seu veículo para registrar os abastecimentos.',
          textoBotao: 'Cadastrar veículo',
          aoPressionar: _cadastrarVeiculo,
        ),
      );
    }

    // Os indicadores são recalculados a partir dos abastecimentos salvos.
    final indicadores = Indicador.calcular(_abastecimentos);

    const titulos = ['Dashboard', 'Abastecimentos', 'Veículo'];
    final abas = [
      AbaDashboard(indicadores: indicadores),
      AbaAbastecimentos(
        indicadores: indicadores,
        aoExcluir: _excluirAbastecimento,
      ),
      AbaVeiculo(veiculo: veiculo, aoExcluir: _excluirVeiculo),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulos[_aba]),
            Text(
              '${veiculo.marca} ${veiculo.modelo}',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: abas[_aba],
      floatingActionButton: _aba == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: _novoAbastecimento,
              icon: const Icon(Icons.add),
              label: const Text('Abastecer'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (indice) => setState(() => _aba = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_gas_station),
            label: 'Abastecimentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car),
            label: 'Veículo',
          ),
        ],
      ),
    );
  }
}
