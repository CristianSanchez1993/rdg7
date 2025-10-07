import 'package:flutter/material.dart';
import '../../model/court_model.dart';
import '../../repository/sport_repository.dart';
import '../../model/sport_model.dart';

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
  late TextEditingController _priceController;
  bool _isActive = true;

  // Dropdown de deportes
  final SportRepository _sportRepo = SportRepository();
  List<SportModel> _sports = [];
  bool _loadingSports = true;
  int? _selectedSportId;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.court?.name ?? '');
    _locationController =
        TextEditingController(text: widget.court?.location ?? '');

    final double? price = widget.court?.pricePerHour;
    _priceController = TextEditingController(
      text: (price == null || price == 0) ? '' : price.toString(),
    );

    _isActive = widget.court?.isActive ?? true;
    _selectedSportId = (widget.court?.sportId ?? 0) == 0
        ? null
        : widget.court?.sportId;

    _loadSports();
  }

  Future<void> _loadSports() async {
    try {
      final list = await _sportRepo.getSports();
      setState(() {
        _sports = list;
        _loadingSports = false;

        if (_selectedSportId != null &&
            !_sports.any((s) => s.id == _selectedSportId)) {
          _selectedSportId = null;
        }
      });
    } catch (_) {
      setState(() => _loadingSports = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _norm(String s) => s.trim();

  void _saveForm() {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) return;

    if (_selectedSportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un deporte')),
      );
      return;
    }

    final double? parsedPrice =
        double.tryParse(_priceController.text.trim());

    final court = CourtModel(
      id: widget.court?.id,
      name: _norm(_nameController.text),
      location: _norm(_locationController.text),
      sportId: _selectedSportId, 
      pricePerHour: parsedPrice ?? 0.0,
      isActive: _isActive,
    );
    Navigator.pop(context, court);
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Nombre
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
                          value == null || value.trim().isEmpty
                              ? 'Campo requerido'
                              : null,
                    ),
                    const SizedBox(height: 15),

                    // Ubicación
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
                          value == null || value.trim().isEmpty
                              ? 'Campo requerido'
                              : null,
                    ),
                    const SizedBox(height: 15),

                    _loadingSports
                        ? const ListTile(
                            leading: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            title: Text('Cargando deportes…'),
                          )
                        : DropdownButtonFormField<int>(
                            initialValue: _selectedSportId, 
                            items: _sports
                                .map(
                                  (s) => DropdownMenuItem<int>(
                                    value: s.id,
                                    child: Text(
                                      '${s.id} – ${s.name}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedSportId = val),
                            decoration: InputDecoration(
                              labelText: 'Deporte',
                              prefixIcon: const Icon(Icons.sports),
                              filled: true,
                              fillColor: Colors.blue[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) =>
                                value == null ? 'Selecciona un deporte' : null,
                          ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Precio por Hora',
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        final raw = (value ?? '').trim();
                        if (raw.isEmpty) return 'Campo requerido';
                        final d = double.tryParse(raw);
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
