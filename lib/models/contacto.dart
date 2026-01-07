class Contacto{
  int id;
  String categoria;
  String nombre;
  String primerApellido;
  String segundoApellido;
  String telefono;
  String correo;

  Contacto({
    required this.id,
    required this.categoria,
    required this.nombre,
    required this.primerApellido,
    required this.segundoApellido,
    required this.telefono,
    required this.correo,
  });

  factory Contacto.fromJson(Map<String, dynamic> json) {
    return Contacto(
      id: json['id'],
      categoria: json['categoria'] ?? 'Otros',
      nombre: json['nombre'],
      primerApellido: json['primerApellido'],
      segundoApellido: json['segundoApellido'],
      telefono: json['telefono'],
      correo: json['correo'],
    );
  }
}