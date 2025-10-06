import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rdg7/bloc/user_bloc.dart';
import 'package:rdg7/model/user_model.dart';

const kCardBorderBlue = Color(0xFF3B82F6);
const kCardShadowBlue = Color(0xFF1E3A8A);
const kGradBlueEnd = Color(0xFF2563EB);
const kGradBlueStart = Color(0xFF60A5FA);

class UserFormScreen extends StatefulWidget {
  final UserModel? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();
  bool _formularioValido = false;

  late TextEditingController _idController;
  late TextEditingController _identificationController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _secondNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _secondLastNameController;
  late TextEditingController _phoneController;

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final user = widget.user;

    _idController = TextEditingController(text: user?.id.toString() ?? '');
    _identificationController = TextEditingController(
      text: user?.identification ?? '',
    );
    _passwordController = TextEditingController();
    _emailController = TextEditingController(text: user?.email ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _secondNameController = TextEditingController(text: user?.secondName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _secondLastNameController = TextEditingController(
      text: user?.secondLastName ?? '',
    );
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _isActive = user?.isActive ?? true;

    _identificationController.addListener(validarFormulario);
    _passwordController.addListener(validarFormulario);
    _emailController.addListener(validarFormulario);
    _firstNameController.addListener(validarFormulario);
    _secondNameController.addListener(validarFormulario);
    _lastNameController.addListener(validarFormulario);
    _secondLastNameController.addListener(validarFormulario);
    _phoneController.addListener(validarFormulario);
  }

  void validarFormulario() {
    setState(() {
      _formularioValido =
          _identificationController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _firstNameController.text.isNotEmpty &&
          // _secondNameController.text.isNotEmpty (opcional)
          _lastNameController.text.isNotEmpty &&
          // _secondLastNameController.text.isNotEmpty (opcional)
          _phoneController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _identificationController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _secondNameController.dispose();
    _lastNameController.dispose();
    _secondLastNameController.dispose();
    _phoneController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  void saveUser() async {
    if (_formKey.currentState!.validate()) {
      final newUser = UserModel(
        id: int.tryParse(_idController.text) ?? 0,
        identification: _identificationController.text,
        password: _passwordController.text,
        email: _emailController.text,
        firstName: _firstNameController.text,
        secondName: _secondNameController.text,
        lastName: _lastNameController.text,
        secondLastName: _secondLastNameController.text,
        phone: _phoneController.text,
        isActive: _isActive,
      );

      try {
        if (widget.user == null) {
          await context.read<UserBloc>().createUser(newUser);
          showSnackBar('Usuario creado exitosamente');
        } else {
          await context.read<UserBloc>().updateUser(newUser);
          showSnackBar('Usuario actualizado exitosamente');
        }

        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        showSnackBar('Ocurrió un error: $e');
      }
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    bool obligatorio = true,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) {
        if (obligatorio && (value == null || value.isEmpty)) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: scheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 150, 191, 241),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 150, 191, 241),
            width: 1,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: kCardBorderBlue, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEditing ? 'Editar Usuario' : 'Crear Usuario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color.fromARGB(255, 157, 188, 228)],
          ),
        ),
        child: SafeArea(
          child: Scrollbar(
            controller: _scrollCtrl,
            thumbVisibility: true, 
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 6),
                            blurRadius: 14,
                            spreadRadius: -6,
                            color: kCardShadowBlue.withValues(alpha: 0.28),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: kCardBorderBlue,
                            width: 1.4,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                widget.user != null
                                    ? 'Editar usuario'
                                    : 'Crear usuario',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 16),

                              buildTextField(
                                'Identificación',
                                _identificationController,
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                'Contraseña',
                                _passwordController,
                                obscure: true,
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                'Correo Electrónico',
                                _emailController,
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                'Primer Nombre',
                                _firstNameController,
                              ),
                              const SizedBox(height: 12),
                              buildTextField(
                                'Segundo Nombre (opcional)',
                                _secondNameController,
                                obligatorio: false,
                              ),
                              const SizedBox(height: 12),
                              buildTextField('Apellido', _lastNameController),
                              const SizedBox(height: 12),
                              buildTextField(
                                'Segundo Apellido (opcional)',
                                _secondLastNameController,
                                obligatorio: false,
                              ),
                              const SizedBox(height: 12),
                              buildTextField('Teléfono', _phoneController),

                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Estado del usuario:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Row(
                                    children: [
                                      Text(_isActive ? 'Activo' : 'Inactivo'),
                                      Switch(
                                        value: _isActive,
                                        onChanged: (value) =>
                                            setState(() => _isActive = value),
                                        activeThumbColor: Colors.teal,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              GradientButtonWide(
                                label: widget.user != null
                                    ? 'Actualizar'
                                    : 'Crear',
                                enabled: _formularioValido,
                                onPressed: _formularioValido ? saveUser : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientButtonWide extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  const GradientButtonWide({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [kGradBlueStart, kGradBlueEnd],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                offset: Offset(0, 6),
                color: Color(0x33000000),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  label, 
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
