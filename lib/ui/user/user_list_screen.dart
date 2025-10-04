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
  final TextEditingController _searchController = TextEditingController();
  UserModel? _usuarioFiltrado;

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

  void buscarPorId() async {
    final id = _searchController.text.trim();

    if (id.isEmpty) {
      setState(() {
        _usuarioFiltrado = null;
      });
      await context.read<UserBloc>().loadUsers();
      return;
    }

    final user = await context.read<UserBloc>().buscarUsuarioPorId(id);

    if (user == null) {
      showSnackBar('No se encontró ningún usuario con ID $id');
      setState(() {
        _usuarioFiltrado = null;
      });
    } else {
      setState(() {
        _usuarioFiltrado = user;
      });
      showSnackBar('Usuario encontrado: ${user.firstName} ${user.lastName}');
    }
  }

  void mostrarDetalleUsuario(BuildContext context, UserModel user) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
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
            Text('ID: ${user.id}'),
            Text('Identificación: ${user.identification}'),
            Text('Contraseña: ${user.password}'),
            Text('Correo: ${user.email}'),
            Text('Nombre: ${user.firstName}'),
            Text('Segundo nombre: ${user.secondName}'),
            Text('Apellido: ${user.lastName}'),
            Text('Segundo apellido: ${user.secondLastName}'),
            Text('Teléfono: ${user.phone}'),
            Text("Estado: ${user.isActive == true ? "Activo" : "Inactivo"}"),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Lista de usuarios'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar por ID',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: buscarPorId,
                    child: const Text('Buscar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _usuarioFiltrado != null
                  ? ListView(
                      children: [
                        ListTile(
                          onTap: () =>
                              mostrarDetalleUsuario(context, _usuarioFiltrado!),
                          title: Text(
                            '${_usuarioFiltrado!.firstName} ${_usuarioFiltrado!.lastName}',
                          ),
                          subtitle: Text(_usuarioFiltrado!.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final bloc = context.read<UserBloc>();
                                  final value = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserFormScreen(
                                          user: _usuarioFiltrado),
                                    ),
                                  );

                                  if (mounted && value == true) {
                                    await bloc.loadUsers();
                                  }
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final bloc = context.read<UserBloc>();
                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmación'),
                                      content: const Text(
                                          '¿Estás seguro de que deseas eliminar este usuario?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancelar'),
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                        ),
                                        TextButton(
                                          child: const Text('Eliminar'),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmar == true) {
                                    await bloc.deleteUser(
                                        _usuarioFiltrado!.id.toString());

                                    if (!mounted) return;

                                    showSnackBar('Usuario eliminado');

                                    setState(() {
                                      _usuarioFiltrado = null;
                                    });
                                    await bloc.loadUsers();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : StreamBuilder<List<UserModel>>(
                      stream: context.read<UserBloc>().userListStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Error cargando usuarios'),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No se encontraron usuarios'),
                          );
                        }

                        final users = snapshot.data!;
                        return ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              onTap: () =>
                                  mostrarDetalleUsuario(context, user),
                              title:
                                  Text('${user.firstName} ${user.lastName}'),
                              subtitle: Text(user.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      final bloc = context.read<UserBloc>();
                                      final value = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              UserFormScreen(user: user),
                                        ),
                                      );

                                      if (mounted && value == true) {
                                        await bloc.loadUsers();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final bloc = context.read<UserBloc>();
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Eliminar usuario'),
                                          content: const Text(
                                            '¿Estás seguro de que deseas eliminar este usuario?',
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancelar'),
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                            ),
                                            TextButton(
                                              child: const Text('Eliminar'),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await bloc.deleteUser(
                                            user.id.toString());

                                        if (!mounted) return;

                                        showSnackBar('Usuario eliminado');

                                        await bloc.loadUsers();
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
          child: const Icon(Icons.add),
          onPressed: () async {
  
          final userBloc = context.read<UserBloc>();
          final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => const UserFormScreen()),
       );

          if (!mounted) return;

          if (result == true) {
            await userBloc.loadUsers();
          }
        },
        ),
      );
}
