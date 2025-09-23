import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rdg7/bloc/user_bloc.dart';
import 'package:rdg7/model/user_model.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _identificationController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _secondNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _secondLastNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = widget.user;

    _idController = TextEditingController(text: user?.id.toString() ?? '');
    _identificationController = TextEditingController(text: user?.identification ?? '');
    _passwordController = TextEditingController();
    _emailController = TextEditingController(text: user?.email ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _secondNameController = TextEditingController(text: user?.secondName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _secondLastNameController = TextEditingController(text: user?.secondLastName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
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
    super.dispose();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void saveUser() async {
    if (_formKey.currentState!.validate()) {
      final newUser = UserModel(
        id: int.tryParse(_idController.text) ?? 0,

        identification: _identificationController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : "",
        email: _emailController.text,
        firstName: _firstNameController.text,
        secondName: _secondNameController.text,
        lastName: _lastNameController.text,
        secondLastName: _secondLastNameController.text,
        phone: _phoneController.text,
      );

      try {
        if (widget.user == null) {
          await context.read<UserBloc>().createUser(newUser);
          showSnackBar("Usuario creado exitosamente");
        } else {
          await context.read<UserBloc>().updateUser(newUser);
          showSnackBar("Usuario actualizado exitosamente");
        }

        Navigator.pop(context);
      } catch (e) {
        showSnackBar("Ocurrió un error");
      }
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEditing ? "Editar Usuario" : "Crear Usuario"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField("Identificacion", _identificationController,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Required" : null),
              buildTextField("Contraseña", _passwordController, obscure: true),
              buildTextField("Correo Electrónico", _emailController,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Required" : null),
              buildTextField("Primer Nombre", _firstNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Required" : null),
              buildTextField("Segundo Nombre", _secondNameController),
              buildTextField("Apellido", _lastNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Required" : null),
              buildTextField("Segundo Apellido", _secondLastNameController),
              buildTextField("Teléfono", _phoneController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveUser,
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white, // ✅ texto blanco
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
                child: Text(
                isEditing ? "Actualizar" : "Crear",
                style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
            ),
          ),
        ),
          ],
          ),
        ),
      ),
    );
  }
}
