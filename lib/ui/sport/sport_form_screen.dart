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
  Widget build(BuildContext context) {
    final isEditing = widget.sport != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              isEditing ? 'Editar Deporte' : 'Nuevo Deporte',
              key: ValueKey<bool>(isEditing),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                
                _FormCard(
                  formKey: _formKey,
                  nameController: _nameController,
                  onSubmit: _saveForm,
                ),

                const SizedBox(height: 16),

                // Acciones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: Colors.blue[700]!),
                          foregroundColor: Colors.blue[700],
                        ),
                        onPressed: () => Navigator.pop(context),
                        label: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _saveForm,
                        label: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            isEditing ? 'Actualizar' : 'Guardar',
                            key: ValueKey<bool>(isEditing),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required this.onSubmit,
  })  : _formKey = formKey,
        _nameController = nameController;

  final GlobalKey<FormState> _formKey;
  final TextEditingController _nameController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 8,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (context, value, _) {
                    final baseBorder = OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.blue[200]!),
                    );

                    return TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => onSubmit(),
                      autofillHints: const [AutofillHints.name],
                      decoration: InputDecoration(
                        labelText: 'Nombre del Deporte',
                        hintText: 'Ej. Fútbol, Tenis…',
                        prefixIcon: const Icon(Icons.sports),
                        filled: true,
                        fillColor: Colors.blue[50],
                        enabledBorder: baseBorder,
                        focusedBorder: baseBorder.copyWith(
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                        errorBorder: baseBorder.copyWith(
                          borderSide: BorderSide(color: Colors.red[400]!),
                        ),
                        focusedErrorBorder: baseBorder.copyWith(
                          borderSide: BorderSide(color: Colors.red[400]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        helperText: 'Usa un nombre claro y corto.',
                        suffixIcon: value.text.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                tooltip: 'Limpiar',
                                icon: const Icon(Icons.clear),
                                onPressed: _nameController.clear,
                              ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Campo requerido'
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
}
