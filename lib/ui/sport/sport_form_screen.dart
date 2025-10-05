import 'package:flutter/material.dart';
import '../../model/sport_model.dart';

class SportFormScreen extends StatefulWidget {
  final SportModel? sport;

  const SportFormScreen({super.key, this.sport});

  @override
  State<SportFormScreen> createState() => _SportFormScreenState();
}

class _SportFormScreenState extends State<SportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sport?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final sport = SportModel(
        id: widget.sport?.id,
        name: _nameController.text.trim(),
      );
      Navigator.pop(context, sport);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(
            widget.sport == null ? 'Nuevo Deporte' : 'Editar Deporte',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shadowColor: Colors.black26,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Deporte',
                        prefixIcon: const Icon(Icons.sports),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, size: 22),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _saveForm,
                        label: Text(
                          widget.sport == null ? 'Guardar' : 'Actualizar',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
