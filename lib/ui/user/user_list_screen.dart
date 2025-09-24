import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rdg7/bloc/user_bloc.dart';
import 'package:rdg7/model/user_model.dart';
import 'package:rdg7/ui/user/user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().loadUsers();
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  void mostrarDetalleUsuario(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("ID: ${user.id}"),
              Text("Identificación: ${user.identification}"),
              Text("Contraseña: ${user.password}"),
              Text("Correo: ${user.email}"),
              Text("Nombre: ${user.firstName}"),
              Text("Segundo nombre: ${user.secondName}"),
              Text("Apellido: ${user.lastName}"),
              Text("Segundo apellido: ${user.secondLastName}"),
              Text("Teléfono: ${user.phone}"),
              Text("Estado: ${user.isActive == true ? "Activo" : "Inactivo"}"),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Lista de usuarios"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: context.read<UserBloc>().userListStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error cargando usuarios"));
                } else if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.data!.isEmpty) {
                  return const Center(child: Text("No se encontraron usuarios"));
                }

                final users = snapshot.data!;
                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      onTap: () => mostrarDetalleUsuario(context, user),

                      title: Text("${user.firstName} ${user.lastName}"),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                              MaterialPageRoute(
                              builder: (_) => UserFormScreen(user: user),
                             ),
                                ).then((value) {
                              if (value == true) {
                                context.read<UserBloc>().loadUsers();
                                }
                                  });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Eliminar usuario"),
                                  content: const Text(
                                      "¿Estás seguro de que deseas eliminar este usuario?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancelar"),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                    TextButton(
                                      child: const Text("Eliminar"),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                context
                                    .read<UserBloc>()
                                    .deleteUser(user.id.toString())
                                    .then((_) => showSnackBar("Usuario eliminado"))
                                    .catchError((e) =>
                                        showSnackBar("Error al eliminar usuario"));
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormScreen()),
          );
        },
      ),
    );
  }
}
