import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/sport_bloc.dart';
import '../../model/sport_model.dart';
import 'sport_form_screen.dart';

class SportListScreen extends StatefulWidget {
  const SportListScreen({super.key});

  @override
  State<SportListScreen> createState() => _SportListScreenState();
}

class _SportListScreenState extends State<SportListScreen> {
  late SportBloc _bloc;
  StreamSubscription<String>? _msgSub;

  // Búsqueda local
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc = context.read<SportBloc>();
      _bloc.loadSports();

      _msgSub = _bloc.messageStream.listen((msg) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
        );
      });
    });

    _searchCtrl.addListener(() {
      if (!mounted) return;
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigateToForm({SportModel? sport}) async {
    final messenger = ScaffoldMessenger.of(context);
    final SportModel? result = await Navigator.push<SportModel?>(
      context,
      MaterialPageRoute<SportModel?>(
        builder: (_) => SportFormScreen(sport: sport),
      ),
    );

    if (!mounted || result == null) return;

    if (sport == null) {
      await _bloc.createSport(result);
    } else {
      await _bloc.updateSport(result.copyWith(id: sport.id));
    }

    await _bloc.loadSports();
    messenger.hideCurrentSnackBar();
  }

  Future<void> _confirmAndDelete(SportModel sport) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar el deporte "${sport.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!mounted || confirm != true) return;

    final id = sport.id;
    if (id == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar: id nulo')),
      );
      return;
    }

    final ok = await _bloc.deleteSport(id);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el deporte')),
      );
    } else {
      await _bloc.loadSports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<SportBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deportes'),
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            onPressed: () => _bloc.loadSports(),
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) =>
                  setState(() => _query = v.trim().toLowerCase()), // <- FIX
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<SportModel>>(
        stream: bloc.sportListStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _StateMessage(
              icon: Icons.error_outline,
              title: 'Error cargando deportes',
              subtitle:
                  'Intenta refrescar con el botón de la barra superior.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          final sports = _query.isEmpty
              ? all
              : all
                  .where((s) => s.name.toLowerCase().contains(_query))
                  .toList();

          if (all.isEmpty) {
            return const _StateMessage(
              icon: Icons.sports_volleyball_outlined,
              title: 'No hay deportes',
              subtitle: 'Toca el botón + para crear el primero.',
            );
          }

          if (sports.isEmpty) {
            return const _StateMessage(
              icon: Icons.search_off,
              title: 'Sin coincidencias',
              subtitle: 'Ajusta el término de búsqueda.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => _bloc.loadSports(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: sports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sport = sports[index];
                final initial =
                    sport.name.trim().isNotEmpty ? sport.name[0].toUpperCase() : '?';

                return Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(initial)),
                    title: Text(
                      sport.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: sport.id != null
                        ? Text('ID: ${sport.id}')
                        : const Text('Sin ID'),
                    onTap: () => _navigateToForm(sport: sport),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit, color: Colors.blue), // <- color original
                          onPressed: () => _navigateToForm(sport: sport),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: const Icon(Icons.delete, color: Colors.red), // <- color original
                          onPressed: () => _confirmAndDelete(sport),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _StateMessage({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      );
}
