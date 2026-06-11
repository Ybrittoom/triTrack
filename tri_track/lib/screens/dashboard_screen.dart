import 'package:flutter/material.dart';
import 'package:tri_track/database/treino_crud.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override 
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, Map<String, dynamic>> estatisticas = {};
  bool carregando = true;

  // CORRIGIDO: Agora com o 'ã' correto para bater com o banco de dados
  static const modalidades = [
    {'tipo': 'Corrida', 'icone': Icons.directions_run, 'cor': Colors.orange},
    {'tipo': 'Ciclismo', 'icone': Icons.directions_bike, 'cor': Colors.green},
    {'tipo': 'Natação', 'icone': Icons.pool, 'cor': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    carregarEstatisticas();
  }

  Future<void> carregarEstatisticas() async {
    setState(() => carregando = true);

    final Map<String, Map<String, dynamic>> dados = {};
    for (final m in modalidades) {
      final nomeTipo = m['tipo'] as String; // CORRIGIDO: Forçando o Dart a entender como String
      dados[nomeTipo] = await TreinoCrud.estatisticasPorTipo(nomeTipo);
    }

    setState(() {
      estatisticas = dados;
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: modalidades.map((m) {
                  final tipo = m['tipo'] as String;
                  final icone = m['icone'] as IconData;
                  final cor = m['cor'] as Color;
                  final dados = estatisticas[tipo] ?? {'total': 0, 'km': '0.00', 'tempo': '0min', 'media': '0.00'};

                  final total = dados['total'];
                  final km = dados['km'];
                  final tempo = dados['tempo'];
                  final media = dados['media'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icone, color: cor, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                tipo,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: cor,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$total treino${total != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1, color: Color(0xFFF5F5F5)),
                          ),
                          Row(
                            children: [
                              _StatCol(label: 'TOTAL KM', valor: '$km km'),
                              _StatCol(label: 'TEMPO TOTAL', valor: '$tempo'),
                              _StatCol(label: 'MÉDIA KM', valor: '$media km'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String valor; // Garanta que o tipo aqui seja String!

  const _StatCol({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valor, 
            style: const TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 16, 
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              color: Colors.grey[400], 
              fontSize: 10, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
