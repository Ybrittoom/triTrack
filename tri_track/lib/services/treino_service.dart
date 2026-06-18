import 'package:intl/intl.dart';
import 'package:tri_track/models/treino.dart';

class TreinoService {
  static Treino criar({
    required String tipo,
    required double distancia,
    required int duracao,
    String? observacao,
  }) {
    return Treino(
      tipo: tipo,
      distancia: distancia,
      duracao: duracao,
      data: DateTime.now().toIso8601String(),
      observacao: observacao,
    );
  }

  static String formatarDuracao(int minutos) {
    final h = minutos ~/ 60;
    final m = minutos % 60;
    if (h == 0) return '${m}min';
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  static String pacePorKm(double distancia, int duracao) {
    if (distancia == 0) return '--';
    final paceDecimal = duracao / distancia;
    final paceMin = paceDecimal.floor();
    final paceSeg = ((paceDecimal - paceMin) * 60).round();
    return '${paceMin}\'${paceSeg.toString().padLeft(2, '0')}"';
  }
}