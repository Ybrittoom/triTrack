import 'package:flutter/material.dart';

class TipoSelector extends StatelessWidget {
  final String tipoSelecionado;
  final ValueChanged<String> onTipoChanged;

  static const tipos = [
    {'nome': 'Corrida', 'icone': Icons.directions_run},
    {'nome': 'Ciclismo', 'icone': Icons.directions_bike},
    {'nome': 'Nataçao', 'icone': Icons.pool}
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
        final cor = Theme.of(context).colorScheme.primary;

        return Expanded(
          child: GestureDetector(
            onTap: () => onTipoChanged(tipo['nome'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selecionado ? cor : Colors.transparent,
                border: Border.all(color: selecionado ? cor : Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(
                    tipo['icone'] as IconData,
                    color: selecionado ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tipo['nome'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: selecionado ? Colors.white : Colors.grey,
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