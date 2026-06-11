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
      observacao: observacaoController.text.isEmpty
          ? null
          : observacaoController.text,
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

    await TreinoCrud.delete(resultado?.id ?? 0);

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
            'Registrar Atividade',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          
          // O Seletor de modalidades que tinha sumido!
          TipoSelector(
            tipoSelecionado: tipoSelecionado,
            onTipoChanged: (tipo) => setState(() => tipoSelecionado = tipo),
          ),
          const SizedBox(height: 16),
          
          // Os inputs de dados que tinham sumido!
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
          
          const SizedBox(height: 24),
          
          // Botões modernos alinhados lado a lado
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Registrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: limpar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                  label: const Text('Limpar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          if (resultado != null) ...[
            CardTreino(treino: resultado!),
            const SizedBox(height: 20),
          ],
          
          const Text(
            'Histórico de Treinos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 14),
          
          // Lista do histórico abaixo dos botões
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
