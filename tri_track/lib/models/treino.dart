class Treino {
  final int? id;
  final String tipo;
  final double distancia;
  final int duracao;
  final String data;
  final String? observacao;

  const Treino({
    this.id,
    required this.tipo,
    required this.distancia,
    required this.duracao,
    required this.data,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'distancia': distancia,
      'duracao': duracao,
      'data': data,
      'observacao': observacao,
    };
  }

  factory Treino.fromMap(Map<String, dynamic> map) {
    return Treino(
      id: map['id'],
      tipo: map['tipo'],
      distancia: map['distancia'],
      duracao: map['duracao'],
      data: map['data'],
      observacao: map['observacao'],
    );
  }
}