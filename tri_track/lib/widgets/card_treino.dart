

import 'package:flutter/material.dart';
import 'package:tri_track/models/treino.dart';
import 'package:tri_track/services/treino_service.dart';

class CardTreino extends StatelessWidget {
  final Treino treino;
  final VoidCallback? onDelete;

  static const coresTipo = {
    'Corrida':  Colors.orange,
    'Ciclismo': Colors.green,
    'Natação':  Colors.blue,
  };

  static const iconesTipo = {
    'Corrida': Icons.directions_run,
    'Ciclismo': Icons.directions_bike,
    'Natação': Icons.pool,
  };

  const CardTreino({
    super.key,
    required this.treino,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cor = coresTipo[treino.tipo] ?? Colors.grey;
    final icone = iconesTipo[treino.tipo] ?? Icons.fitness_center;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: cor),
                const SizedBox(width: 8),
                Text(
                  treino.tipo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
                const Spacer(),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
            Text('Data: ${treino.data}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoItem(label: 'Distância', valor: '${treino.distancia.toStringAsFixed(2)} km'),
                _InfoItem(label: 'Duração', valor: TreinoService.formatarDuracao(treino.duracao)),
                _InfoItem(label: 'Pace', valor: TreinoService.pacePorKm(treino.distancia, treino.duracao)),
              ],
            ),
            if (treino.observacao != null && treino.observacao!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Obs: ${treino.observacao}',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}

  class _InfoItem extends StatelessWidget {
    final String label;
    final String valor;

    const _InfoItem({required this.label, required this.valor});

    @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
  }