import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contacto.dart';
import '../pages/contacto_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void dispose() {
    super.dispose();
  }

  final List<String> categorias = ['Trabajo', 'Personal', 'Otros'];
  String filtroCategoria = 'Todas';

  final List<Contacto> contactos = [];

  List<Contacto> get contactosFiltrados {
    if (filtroCategoria == 'Todas') return contactos;
    return contactos.where((c) => c.categoria == filtroCategoria).toList();
  }

  Future<void> confirmarEliminacionContacto(Contacto contacto) async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Estás seguro de que deseas eliminar a ${contacto.nombre}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      setState(() {
        contactos.removeWhere((c) => c.id == contacto.id);
      });
    }
  }

  void crearContacto() {
    final nuevo = Contacto(
      id: DateTime.now().millisecondsSinceEpoch,
      categoria: 'Otros',
      nombre: 'Juan',
      primerApellido: 'Pérez',
      segundoApellido: '',
      telefono: '600000000',
      correo: 'juan@correo.com',
    );

    setState(() {
      contactos.add(nuevo);
    });
  }

  void editarContactoDemo(Contacto c) {
    final idx = contactos.indexWhere((x) => x.id == c.id);
    if (idx == -1) return;

    setState(() {
      final actual = contactos[idx];
      contactos[idx] = Contacto(
        id: actual.id,
        categoria: actual.categoria == 'Trabajo' ? 'Personal' : 'Trabajo',
        nombre: actual.nombre,
        primerApellido: actual.primerApellido,
        segundoApellido: actual.segundoApellido,
        telefono: actual.telefono,
        correo: actual.correo,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Contactos')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categorías', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildFilterDropdown(
              context: context,
              items: const [
                DropdownMenuItem(
                  value: 'Todas',
                  child: Text('Todas las categorías'),
                ),
                DropdownMenuItem(value: 'Trabajo', child: Text('Trabajo')),
                DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                DropdownMenuItem(value: 'Otros', child: Text('Otros')),
              ],
              hint: 'Seleccionar categoría',
              icon: Icons.category,
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            Text(
              'Contactos existentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('contactos')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error cargando contactos');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Text('No hay contactos disponibles.');
                  }

                  final filtrados = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final cat = (data['categoria'] ?? 'Otros').toString();
                    return filtroCategoria == 'Todas' || cat == filtroCategoria;
                  }).toList();

                  if (filtrados.isEmpty) {
                    return const Text('No hay contactos en esta categoría.');
                  }

                  return ListView.builder(
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final doc = filtrados[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final nombre = (data['nombre'] ?? '').toString();
                      final apellido1 = (data['primerApellido'] ?? '')
                          .toString();
                      final categoria = (data['categoria'] ?? 'Otros')
                          .toString();

                      return Card(
                        child: ListTile(
                          title: Text('$nombre $apellido1 - $categoria'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  // editar: abre formulario con Contacto construido desde Firestore
                                  final c = Contacto(
                                    id: doc
                                        .id
                                        .hashCode, 
                                    categoria: categoria,
                                    nombre: nombre,
                                    primerApellido: apellido1,
                                    segundoApellido:
                                        (data['segundoApellido'] ?? '')
                                            .toString(),
                                    telefono: (data['telefono'] ?? '')
                                        .toString(),
                                    correo: (data['correo'] ?? '').toString(),
                                  );

                                  final Contacto? actualizado =
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ContactoPage(contacto: c),
                                        ),
                                      );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('contactos')
                                      .doc(doc.id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Contacto? nuevo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactoPage()),
          );

          if (nuevo != null) {
            setState(() => contactos.add(nuevo));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required BuildContext context,
    required List<DropdownMenuItem<String>> items,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor, // Fondo del dropdown
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor.withValues(
            alpha: 0.3,
          ), // Borde semitransparente
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Icono del filtro
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: filtroCategoria,
              isExpanded: true, // Ocupa todo el ancho disponible
              underline: const SizedBox(), // Elimina la línea por defecto
              borderRadius: BorderRadius.circular(12),
              dropdownColor: theme.cardColor, // Color del menú desplegable
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
              items: items, // Opciones del dropdown
              onChanged: (value) {
                setState(() {
                  filtroCategoria = value ?? 'Todas';
                });
              }, // Acción al seleccionar una opción
              hint: Text(
                hint,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ), // Texto semitransparente
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
