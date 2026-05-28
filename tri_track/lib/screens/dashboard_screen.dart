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

  static const modalidades = [
    {'tipo': 'Corrida', 'icone': Icons.directions_run, 'cor': Colors.orange},
    {'tipo': 'Ciclismo', 'icone': Icons.directions_bike, 'cor': Colors.green},
    {'tipo': 'Nataçao', 'icone': Icons.pool, 'cor': Colors.blue},
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
      dados[m['tipo'] as String] =
          await TreinoCrud.estatisticasPorTipo(m['tipo'] as String);
    }

    setState(() {
      estatisticas = dados;
      carregando = false;
    });
  }

  String _formatarTempo(dynamic minutos) {
    if (minutos == null) return '0min';
    final total = (minutos as num).toInt();
    final h = total ~/ 60;
    final m = total % 60;
    if (h == 0) return '${m}min';
    return '${h}h${m.toString().padLeft(2, '0')}';
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
                  final stat = estatisticas[m['tipo']] ?? {};
                  final total = (stat['total'] as num?)?.toInt() ?? 0;
                  final km = (stat['totalKm'] as num?)?.toStringAsFixed(1) ?? '0.0';
                  final tempo = _formatarTempo(stat['totalMinutos']);
                  final media = (stat['mediaKm'] as num?)?.toStringAsFixed(1) ?? '0.0';
                  final cor = m['cor'] as Color;
                  final icone = m['icone'] as IconData;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(icone, color: cor, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                m['tipo'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: cor,
                                ),
                              ),
                              const Spacer(),
                              Chip(label: Text('$total treino${total != 1 ? 's' : ''}')),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              _StatCol(label: 'Total km', valor: km),
                              _StatCol(label: 'Tempo total', valor: tempo),
                              _StatCol(label: 'Média km', valor: media),
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
  final String valor;

  const _StatCol({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}