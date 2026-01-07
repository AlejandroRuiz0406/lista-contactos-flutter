import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contacto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactoPage extends StatefulWidget {
  final Contacto? contacto; // null = crear, no-null = editar

  const ContactoPage({super.key, this.contacto});

  @override
  State<ContactoPage> createState() => _ContactoPageState();
}

class _ContactoPageState extends State<ContactoPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellido1Ctrl;
  late final TextEditingController _apellido2Ctrl;
  late final TextEditingController _tel1Ctrl;
  late final TextEditingController _emailCtrl;

  String categoria = 'Otros';
  bool get esEdicion => widget.contacto != null;

  @override
  void initState() {
    super.initState();

    final c = widget.contacto;

    categoria = c?.categoria ?? 'Otros';

    _nombreCtrl = TextEditingController(text: widget.contacto?.nombre);
    _apellido1Ctrl = TextEditingController(
      text: widget.contacto?.primerApellido,
    );
    _apellido2Ctrl = TextEditingController(
      text: widget.contacto?.segundoApellido,
    );
    _tel1Ctrl = TextEditingController(text: widget.contacto?.telefono);
    _emailCtrl = TextEditingController(text: widget.contacto?.correo);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellido1Ctrl.dispose();
    _apellido2Ctrl.dispose();
    _tel1Ctrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String? validarNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es obligatorio';
    }
    return null;
  }

  String? validarTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es obligatorio';
    }
    final regex = RegExp(r'^\+?\d{7,15}$');
    if (!regex.hasMatch(value)) {
      return 'Número de teléfono no válido';
    }
    return null;
  }

  String? validarCorreo(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es obligatorio';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Correo electrónico no válido';
    }
    return null;
  }

  // void guardarContacto() {
  //   if (!_formKey.currentState!.validate()) return;

  //   final nuevo = Contacto(
  //     id: esEdicion
  //         ? widget.contacto!.id
  //         : DateTime.now().millisecondsSinceEpoch,
  //     categoria: categoria,
  //     nombre: _nombreCtrl.text.trim(),
  //     primerApellido: _apellido1Ctrl.text.trim(),
  //     segundoApellido: _apellido2Ctrl.text.trim(),
  //     telefono: _tel1Ctrl.text.trim(),
  //     correo: _emailCtrl.text.trim(),
  //   );

  //   Navigator.pop(context, nuevo);
  // }

  void guardarContacto() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'primerApellido': _apellido1Ctrl.text.trim(),
      'segundoApellido': _apellido2Ctrl.text.trim(),
      'telefono': _tel1Ctrl.text.trim(),
      'correo': _emailCtrl.text.trim(),
      'categoria': categoria,
    };

    if (esEdicion) {
      await FirebaseFirestore.instance
          .collection('contactos')
          .doc(widget.contacto!.id.toString())
          .set(data);
    } else {
      await FirebaseFirestore.instance.collection('contactos').add(data);
    }

    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar contacto' : 'Crear contacto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: validarNombre,
              ),
              TextFormField(
                controller: _apellido1Ctrl,
                decoration: const InputDecoration(labelText: 'Primer Apellido'),
              ),
              TextFormField(
                controller: _apellido2Ctrl,
                decoration: const InputDecoration(
                  labelText: 'Segundo Apellido',
                ),
              ),
              TextFormField(
                controller: _tel1Ctrl,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: validarTelefono,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: validarCorreo,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: ['Trabajo', 'Personal', 'Otros']
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    categoria = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: guardarContacto,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
