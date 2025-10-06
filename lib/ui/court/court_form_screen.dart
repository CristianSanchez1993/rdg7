import 'package:flutter/material.dart';
import '../../model/court_model.dart';

class CourtFormScreen extends StatefulWidget {
  final CourtModel? court;

  const CourtFormScreen({super.key, this.court});

  @override
  State<CourtFormScreen> createState() => _CourtFormScreenState();
}

class _CourtFormScreenState extends State<CourtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _sportIdController;
  late TextEditingController _priceController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.court?.name ?? '');
    _locationController =
        TextEditingController(text: widget.court?.location ?? '');
    _sportIdController = TextEditingController(
      text: (widget.court?.sportId ?? 0) == 0 ? '' : widget.court!.sportId.toString(),
    );
    _priceController = TextEditingController(
      text: widget.court?.pricePerHour == null || (widget.court?.pricePerHour ?? 0) == 0
          ? ''
          : widget.court!.pricePerHour.toString(),
    );
    _isActive = widget.court?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _sportIdController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final int? parsedSportId = int.tryParse(_sportIdController.text);
      final double? parsedPrice = double.tryParse(_priceController.text);

      final court = CourtModel(
        id: widget.court?.id,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        sportId: parsedSportId,
        pricePerHour: parsedPrice ?? 0.0,
        isActive: _isActive,
      );
      Navigator.pop(context, court);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(
            widget.court == null ? 'Nueva Cancha' : 'Editar Cancha',
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
                        labelText: 'Nombre de la Cancha',
                        prefixIcon: const Icon(Icons.sports_soccer),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Ubicación',
                        prefixIcon: const Icon(Icons.location_on),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _sportIdController,
                      decoration: InputDecoration(
                        labelText: 'ID del Deporte',
                        prefixIcon: const Icon(Icons.numbers),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        final n = int.tryParse(value);
                        if (n == null || n <= 0) {
                          return 'Debe ser un número mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Precio por Hora',
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        final d = double.tryParse(value);
                        if (d == null || d <= 0) {
                          return 'Debe ser un valor numérico > 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: Text(
                        'Activo',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isActive
                              ? Colors.blue.shade800
                              : Colors.grey.shade600,
                        ),
                      ),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.blue.shade700;
                        }
                        return Colors.grey.shade400;
                      }),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.blue.shade200;
                        }
                        return Colors.grey.shade300;
                      }),
                      secondary: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          _isActive ? Icons.check_circle : Icons.cancel,
                          key: ValueKey(_isActive),
                          color: _isActive
                              ? Colors.blue.shade700
                              : Colors.grey.shade500,
                          size: 28,
                        ),
                      ),
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
                          widget.court == null ? 'Guardar' : 'Actualizar',
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
