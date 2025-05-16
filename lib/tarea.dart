class Tarea {
  final int? id;
  String nombre;
  int completada;

  Tarea({
    this.id,
    required this.nombre,
    this.completada = 0,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      completada: json['completada'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'completada': completada,
    };
  }

  static Tarea fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'],
      nombre: map['nombre'],
      completada: map['completada'] ?? 0,
    );
  }
}