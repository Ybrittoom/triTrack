import 'package:flutter/material.dart';
import 'package:tri_track/database/treino_crud.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, Map<String, dynamic>> estatisticas = {};

  Map<String, dynamic> semanal = {};
  Map<String, dynamic> mensal = {};

  bool carregando = false;

  double kmTotalGeral = 0;
  int totalTreinosGeral = 0;
  String tempoTotalGeral = '0min';

  double percentualCorrida = 0;
  double percentualCiclismo = 0;
  double percentualNatacao = 0;

  int sequenciaAtual = 0;
  String ultimoTreinoTexto = 'Nenhum treino';

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

    final Map<String, dynamic> semanalTemp = {};
    final Map<String, dynamic> mensalTemp = {};

    kmTotalGeral = 0;
    totalTreinosGeral = 0;

    for (final m in modalidades) {
      final nomeTipo = m['tipo'] as String;

      dados[nomeTipo] = await TreinoCrud.estatisticasPorTipo(nomeTipo);
      kmTotalGeral += double.tryParse(dados[nomeTipo]!['km'].toString()) ?? 0;

      totalTreinosGeral += dados[nomeTipo]!['total'] as int;

      semanalTemp[nomeTipo] = await TreinoCrud.evolucaoSemanal(nomeTipo);

      mensalTemp[nomeTipo] = await TreinoCrud.evolucaoMensal(nomeTipo);
    }

    int corridaTreinos = dados['Corrida']?['total'] ?? 0;

    int ciclismoTreinos = dados['Ciclismo']?['total'] ?? 0;

    int natacaoTreinos = dados['Natação']?['total'] ?? 0;

    int totalTreinos = corridaTreinos + ciclismoTreinos + natacaoTreinos;

    if (totalTreinos > 0) {
      percentualCorrida = (corridaTreinos / totalTreinos) * 100;

      percentualCiclismo = (ciclismoTreinos / totalTreinos) * 100;

      percentualNatacao = (natacaoTreinos / totalTreinos) * 100;
    }

    await calcularSequencia();

    setState(() {
      estatisticas = dados;
      semanal = semanalTemp;
      mensal = mensalTemp;

      tempoTotalGeral = calcularTempoTotal(dados);

      carregando = false;
    });
  }

  String calcularTempoTotal(Map<String, Map<String, dynamic>> dados) {
    int minutos = 0;

    for (final item in dados.values) {
      final texto = item['tempo'].toString();

      final numeros = RegExp(r'\d+').allMatches(texto);

      if (numeros.isNotEmpty) {
        minutos += int.parse(numeros.first.group(0)!);
      }
    }

    final horas = minutos ~/ 60;
    final resto = minutos % 60;

    return '${horas}h ${resto}min';
  }

  Future<void> calcularSequencia() async {
    final treinos = await TreinoCrud.listAll();

    if (treinos.isEmpty) {
      sequenciaAtual = 0;
      ultimoTreinoTexto = 'Nenhum treino';
      return;
    }

    treinos.sort((a, b) {
      final dataA = DateTime.parse(a.data);
      final dataB = DateTime.parse(b.data);

      return dataB.compareTo(dataA);
    });

    final ultimoTreino = DateTime.parse(treinos.first.data);

    final diferenca = DateTime.now().difference(ultimoTreino);

    if (diferenca.inDays == 0) {
      ultimoTreinoTexto = 'Hoje';
    } else if (diferenca.inDays == 1) {
      ultimoTreinoTexto = 'Ontem';
    } else {
      ultimoTreinoTexto = '${diferenca.inDays} dias atrás';
    }

    final diasTreinados = <String>{};

    for (final treino in treinos) {
      final data = DateTime.parse(treino.data);

      diasTreinados.add('${data.year}-${data.month}-${data.day}');
    }

    int streak = 0;
    DateTime diaAtual = DateTime.now();

    while (true) {
      final chave = '${diaAtual.year}-${diaAtual.month}-${diaAtual.day}';

      if (diasTreinados.contains(chave)) {
        streak++;
        diaAtual = diaAtual.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    sequenciaAtual = streak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // CARD RESUMO GERAL
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.indigo],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumo Geral',
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '${kmTotalGeral.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '$totalTreinosGeral treinos',
                          style: const TextStyle(color: Colors.white),
                        ),

                        Text(
                          tempoTotalGeral,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  //TREINOS REALIZADOS
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Treinos realizados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Text('🚴', style: TextStyle(fontSize: 24)),

                            const SizedBox(width: 10),

                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentualCiclismo / 100,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text('${percentualCiclismo.toStringAsFixed(0)}%'),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            const Text('🏃', style: TextStyle(fontSize: 24)),

                            const SizedBox(width: 10),

                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentualCorrida / 100,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text('${percentualCorrida.toStringAsFixed(0)}%'),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            const Text('🏊', style: TextStyle(fontSize: 24)),

                            const SizedBox(width: 10),

                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentualNatacao / 100,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text('${percentualNatacao.toStringAsFixed(0)}%'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 28)),

                            const SizedBox(width: 10),

                            Text(
                              '$sequenciaAtual dias seguidos',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Último treino: $ultimoTreinoTexto',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // META SEMANAL
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Meta Semanal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 12),

                        LinearProgressIndicator(
                          value: (kmTotalGeral / 100).clamp(0.0, 1.0),
                        ),

                        const SizedBox(height: 10),

                        Text('${kmTotalGeral.toStringAsFixed(1)} / 20 km'),
                      ],
                    ),
                  ),

                  // LISTA DAS MODALIDADES
                  ...modalidades.map((m) {
                    final tipo = m['tipo'] as String;
                    final icone = m['icone'] as IconData;
                    final cor = m['cor'] as Color;

                    final dados =
                        estatisticas[tipo] ??
                        {
                          'total': 0,
                          'km': '0.00',
                          'tempo': '0min',
                          'media': '0.00',
                        };

                    final total = dados['total'];
                    final km = dados['km'];
                    final tempo = dados['tempo'];
                    final media = dados['media'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
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
                              child: Divider(
                                height: 1,
                                color: Color(0xFFF5F5F5),
                              ),
                            ),

                            Row(
                              children: [
                                _StatCol(label: 'TOTAL KM', valor: '$km km'),
                                _StatCol(label: 'TEMPO TOTAL', valor: '$tempo'),
                                _StatCol(label: 'MÉDIA KM', valor: '$media km'),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'SEMANA',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${((semanal[tipo]?['km'] ?? 0) as num).toStringAsFixed(1)} km',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'MÊS',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${((mensal[tipo]?['km'] ?? 0) as num).toStringAsFixed(1)} km',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
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
