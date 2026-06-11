import 'package:flutter/material.dart';
import 'package:tri_track/models/treino.dart';
import 'package:tri_track/services/treino_service.dart';

class CardTreino extends StatelessWidget {
  final Treino treino;
  final VoidCallback? onDelete;

  static const coresTipo = {
    'Corrida':  Colors.orange,
    'Ciclismo': Colors.green,
    'Natação':  Colors.blue, // Corrigido o til
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
  // Normaliza para evitar problemas com strings sem acento do banco antigo
  final tipoNormalizado = treino.tipo.contains('Nata') ? 'Natação' : treino.tipo;
  final cor = coresTipo[tipoNormalizado] ?? Colors.grey;
  final icone = iconesTipo[tipoNormalizado] ?? Icons.fitness_center;

  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        // O SEGREDO ESTÁ AQUI: o border e a cor de fundo precisam estar no BoxDecoration
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: cor, width: 6)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icone, color: cor, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipoNormalizado,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      treino.data.split(' - ').first,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
                const Spacer(),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F1F1)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoItem(label: 'DISTÂNCIA', valor: '${treino.distancia.toStringAsFixed(2)} km'),
                _InfoItem(label: 'DURAÇÃO', valor: TreinoService.formatarDuracao(treino.duracao)),
                _InfoItem(label: 'PACE MÁX', valor: TreinoService.pacePorKm(treino.distancia, treino.duracao)),
              ],
            ),
            if (treino.observacao != null && treino.observacao!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '“${treino.observacao}”',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700], fontSize: 13),
                ),
              ),
            ],
          ],
        ),
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
  return Column(
    children: [
      Text(
        valor,
        style: const TextStyle(
          fontWeight: FontWeight.w900, // Corrigido aqui
          fontSize: 16, 
          color: Colors.black87,       // Corrigido aqui (tom premium de preto)
        ),
      ), // Text
      const SizedBox(height: 2),
      Text(
        label,
        style: TextStyle(
          color: Colors.grey[500], 
          fontSize: 10, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 0.5,
        ),
      ), // Text
    ],
  ); // Column
}
}