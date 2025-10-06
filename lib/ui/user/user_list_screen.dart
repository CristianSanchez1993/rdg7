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
  
    const activeGreen = Color(0xFF16A34A);
    final inactiveGray = Theme.of(context).colorScheme.outline;

    final borderColor = user.isActive == true ? activeGreen : inactiveGray;
    final shadowColor = (user.isActive == true ? activeGreen : inactiveGray)
        .withValues(alpha: 0.25);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors
          .transparent,
      builder: (_) {
        final surface = Theme.of(context).colorScheme.surface;
        final onSurface = Theme.of(context).colorScheme.onSurface;

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 12,
                  spreadRadius: -4,
                  color: shadowColor,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Información usuario',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1),

                    const SizedBox(height: 12),

                    _InfoRow(label: 'ID', value: '${user.id}'),
                    _InfoRow(
                      label: 'Identificación',
                      value: user.identification,
                    ),
                    _InfoRow(label: 'Contraseña', value: user.password),
                    _InfoRow(label: 'Correo', value: user.email),
                    _InfoRow(label: 'Nombre', value: user.firstName),
                    _InfoRow(
                      label: 'Segundo nombre',
                      value: user.secondName,
                    ),
                    _InfoRow(label: 'Apellido', value: user.lastName),
                    _InfoRow(
                      label: 'Segundo apellido',
                      value: user.secondLastName,
                    ),
                    _InfoRow(label: 'Teléfono', value: user.phone),
                    _InfoRow(
                      label: 'Estado',
                      value: user.isActive == true ? 'Activo' : 'Inactivo',
                      valueColor: user.isActive == true
                          ? activeGreen
                          : inactiveGray,
                    ),

                    const SizedBox(height: 16),

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
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(centerTitle: true, title: const Text('Lista de usuarios')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => buscarPorId(),
                  keyboardType: TextInputType
                      .number, 
                  decoration: InputDecoration(
                    hintText: 'Buscar por ID',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF2563EB),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GradientButton(label: 'Buscar', onPressed: buscarPorId),
            ],
          ),
        ),
        Expanded(
          child: _usuarioFiltrado != null
              ? ListView(
                  children: [
                    UserCard(
                      name:
                          '${_usuarioFiltrado!.firstName} ${_usuarioFiltrado!.lastName}',
                      email: _usuarioFiltrado!.email,
                      onTap: () =>
                          mostrarDetalleUsuario(context, _usuarioFiltrado!),
                      onEdit: () async {
                        final bloc = context.read<UserBloc>();
                        final value = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UserFormScreen(user: _usuarioFiltrado),
                          ),
                        );
                        if (mounted && value == true) await bloc.loadUsers();
                      },
                      onDelete: () async {
                        final bloc = context.read<UserBloc>();
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmación'),
                            content: const Text(
                              '¿Estás seguro de que deseas eliminar este usuario?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        if (confirmar == true) {
                          await bloc.deleteUser(
                            _usuarioFiltrado!.id.toString(),
                          );
                          if (!mounted) return;
                          showSnackBar('Usuario eliminado');
                          setState(() => _usuarioFiltrado = null);
                          await bloc.loadUsers();
                        }
                      },
                      
                      borderColor: (_usuarioFiltrado!.isActive == true)
                          ? const Color(0xFF16A34A)
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.8),

                      shadowColor: (_usuarioFiltrado!.isActive == true)
                          ? const Color(0xFF16A34A).withValues(alpha: 0.35)
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.35),
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
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No se encontraron usuarios'),
                      );
                    }

                    final users = snapshot.data!;

                    return ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return UserCard(
                          name: '${user.firstName} ${user.lastName}',
                          email: user.email,
                          onTap: () => mostrarDetalleUsuario(context, user),
                          onEdit: () async {
                            final bloc = context.read<UserBloc>();
                            final value = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserFormScreen(user: user),
                              ),
                            );
                            if (mounted && value == true) {
                              await bloc.loadUsers();
                            }
                          },
                          onDelete: () async {
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
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await bloc.deleteUser(user.id.toString());
                              if (!mounted) return;
                              showSnackBar('Usuario eliminado');
                              await bloc.loadUsers();
                            }
                          },
                          
                          borderColor: (user.isActive == true)
                              ? const Color(0xFF16A34A)
                              : Theme.of(
                                  context,
                                ).colorScheme.outline..withValues(alpha: 0.8),

                          
                          shadowColor: (user.isActive == true)
                              ? const Color(0xFF16A34A).withValues(alpha: 0.35)
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.35),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    ),
    floatingActionButton: GradientFab(
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
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
  );
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final EdgeInsets padding;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: Colors.white);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, 6),
              color: Color(0x33000000),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          child: Padding(
            padding: padding,
            child: Text(label, style: txt),
          ),
        ),
      ),
    );
  }
}

class GradientFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const GradientFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) => Material(
      elevation: 6,
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: Ink(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.primary,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
}

class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  final Color? borderColor;
  final Color? shadowColor;

  const UserCard({
    super.key,
    required this.name,
    required this.email,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.borderColor,
    this.shadowColor,
  });

  String _initials(String full) {
    final p = full.trim().split(RegExp(r'\s+'));
    if (p.isEmpty) return '?';
    if (p.length == 1) {
      return p.first.characters.take(2).toString().toUpperCase();
    }
    return (p.first.characters.first + p.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bColor = borderColor ?? scheme.primary.withValues(alpha: 0.35);
    final sColor = shadowColor ?? bColor.withValues(alpha: 0.35);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 6),
            blurRadius: 12,
            spreadRadius: -6,
            color: sColor,
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: bColor,
            width: 1.5,
          ), 
        ),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Text(_initials(name)),
          ),
          title: Text(name, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            email,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          trailing: Wrap(
            spacing: 8,
            children: [
              _ActionIcon(
                icon: Icons.edit_note_rounded,
                bg: scheme.primary,
                onTap: onEdit,
                tooltip: 'Editar',
              ),
              _ActionIcon(
                icon: Icons.delete_forever_rounded,
                bg: scheme.error,
                onTap: onDelete,
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionIcon({
    required this.icon,
    required this.bg,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: Ink(
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor ?? scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
