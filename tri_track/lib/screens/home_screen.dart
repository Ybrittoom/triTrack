import 'package:flutter/material.dart';
import 'package:tri_track/database/treino_crud.dart';
import 'package:tri_track/models/treino.dart';
import 'package:tri_track/services/treino_service.dart';
import 'package:tri_track/widgets/card_treino.dart';
import 'package:tri_track/widgets/tipo_selector.dart';
import 'package:tri_track/widgets/treino_input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Treino> historico = [];

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    final dados = await TreinoCrud.listAll();
    setState(() {
      historico = dados;
    });
  }

  final TextEditingController distanciaController = TextEditingController();
  final TextEditingController duracaoController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();

  String tipoSelecionado = 'Corrida';
  Treino? resultado;

  void registrar() async {
    final double distancia = double.tryParse(distanciaController.text) ?? 0;
    final int duracao = int.tryParse(duracaoController.text) ?? 0;

    if (distancia == 0 || duracao == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha distância e duração!')),
      );
      return;
    }

    final treino = TreinoService.criar(
      tipo: tipoSelecionado,
      distancia: distancia,
      duracao: duracao,
      observacao: observacaoController.text.isEmpty ? null : observacaoController.text,
    );

    await TreinoCrud.insert(treino);

    setState(() {
      resultado = treino;
    });

    await carregarHistorico();
  }

  void limpar() async {
    distanciaController.clear();
    duracaoController.clear();
    observacaoController.clear(); 

    await TreinoCrud.delete(resultado?.id??0);

    setState(() {
      resultado = null;
      tipoSelecionado = 'Corrida';
    });

    await carregarHistorico();
  }

  Future<void> deletarItem(Treino treino) async {
    await TreinoCrud.delete(treino.id!);
    await carregarHistorico();
  }

  @override
  void dispose() {
    distanciaController.dispose();
    duracaoController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TriTrack'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Modalidade',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TipoSelector(
              tipoSelecionado: tipoSelecionado,
              onTipoChanged: (tipo) => setState(() => tipoSelecionado = tipo),
            ),
            const SizedBox(height: 16),
            TreinoInput(
              label: 'Distância (km)',
              controller: distanciaController,
              icon: Icons.straighten,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TreinoInput(
              label: 'Duração (minutos)',
              controller: duracaoController,
              icon: Icons.timer,
            ),
            const SizedBox(height: 12),
            TreinoInput(
              label: 'Observação (opcional)',
              controller: observacaoController,
              icon: Icons.notes,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: registrar,
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: limpar,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Limpar tudo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (resultado != null) CardTreino(treino: resultado!),
            const Text(
              'Histórico de Treinos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...historico.map((item) => CardTreino(
                  treino: item,
                  onDelete: () => deletarItem(item),
                )),
          ],
        ),
      ),
    );
  }
}