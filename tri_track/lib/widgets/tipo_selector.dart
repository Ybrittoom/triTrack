import 'package:flutter/material.dart';

class TipoSelector extends StatelessWidget {
  final String tipoSelecionado;
  final ValueChanged<String> onTipoChanged;

  static const tipos = [
    {'nome': 'Corrida', 'icone': Icons.directions_run, 'cor': Colors.orange},
    {'nome': 'Ciclismo', 'icone': Icons.directions_bike, 'cor': Colors.green},
    {'nome': 'Natação', 'icone': Icons.pool, 'cor': Colors.blue} // Corrigido o til
  ];

  const TipoSelector({
    super.key,
    required this.tipoSelecionado,
    required this.onTipoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tipos.map((tipo) {
        final selecionado = tipoSelecionado == tipo['nome'];
        final corEsporte = tipo['cor'] as Color;

        return Expanded(
          child: GestureDetector(
            onTap: () => onTipoChanged(tipo['nome'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: selecionado ? corEsporte.withOpacity(0.15) : Colors.grey[50],
                border: Border.all(
                  color: selecionado ? corEsporte : Colors.grey[300]!,
                  width: selecionado ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    tipo['icone'] as IconData,
                    color: selecionado ? corEsporte : Colors.grey[500],
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tipo['nome'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selecionado ? FontWeight.bold : FontWeight.w500,
                      color: selecionado ? corEsporte : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}