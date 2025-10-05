import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/court_bloc.dart';
import '../../model/court_model.dart';
import 'court_form_screen.dart';

class CourtListScreen extends StatefulWidget {
  const CourtListScreen({super.key});

  @override
  State<CourtListScreen> createState() => _CourtListScreenState();
}

class _CourtListScreenState extends State<CourtListScreen> {
  late CourtBloc _bloc;
  StreamSubscription<String>? _msgSub;

  // Búsqueda local
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc = context.read<CourtBloc>();
      _bloc.loadCourts();

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

  Future<void> _navigateToForm({CourtModel? court}) async {
    final messenger = ScaffoldMessenger.of(context);
    final CourtModel? result = await Navigator.push<CourtModel?>(
      context,
      MaterialPageRoute<CourtModel?>(
        builder: (_) => CourtFormScreen(court: court),
      ),
    );

    if (!mounted || result == null) return;

    if (court == null) {
      await _bloc.createCourt(result);
    } else {
      // defensivo: no intentes actualizar sin id
      if (court.id == null) {
        messenger.showSnackBar(
          const SnackBar(
            content:
                Text('No se puede actualizar: el backend no envía id en GET.'),
          ),
        );
        return;
      }
      await _bloc.updateCourt(result.copyWith(id: court.id));
    }

    // Refrescar lista tras crear/editar
    await _bloc.loadCourts();
    messenger.hideCurrentSnackBar();
  }

  Future<void> _confirmAndDelete(CourtModel court) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text(
          court.isActive
              ? '¿Deseas desactivar esta cancha?'
              : 'Esta cancha ya está inactiva.\n¿Deseas desactivarla nuevamente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (!mounted || confirm != true) return;

    final id = court.id;
    if (id == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo desactivar: id nulo')),
      );
      return;
    }

    // deleteCourt() devuelve void -> solo esperamos y luego refrescamos
    await _bloc.deleteCourt(id);
    await _bloc.loadCourts();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<CourtBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canchas'),
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            onPressed: () => _bloc.loadCourts(),
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
                  setState(() => _query = v.trim().toLowerCase()),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar cancha por nombre…',
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
      body: StreamBuilder<List<CourtModel>>(
        stream: bloc.courtListStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _StateMessage(
              icon: Icons.error_outline,
              title: 'Error cargando canchas',
              subtitle:
                  'Intenta refrescar con el botón de la barra superior.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          // Filtro local por nombre
          final courts = _query.isEmpty
              ? all
              : all
                  .where((c) => c.name.toLowerCase().contains(_query))
                  .toList();

          if (all.isEmpty) {
            return const _StateMessage(
              icon: Icons.sports_tennis_outlined,
              title: 'No hay canchas disponibles',
              subtitle: 'Toca el botón + para crear la primera.',
            );
          }

          if (courts.isEmpty) {
            return const _StateMessage(
              icon: Icons.search_off,
              title: 'Sin coincidencias',
              subtitle: 'Ajusta el término de búsqueda.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => _bloc.loadCourts(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: courts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final court = courts[index];
                final inactiveStyle =
                    court.isActive ? null : const TextStyle(color: Colors.grey);
                final initial = court.name.trim().isNotEmpty
                    ? court.name[0].toUpperCase()
                    : '?';

                return Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(initial)),
                    title: Text(
                      court.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: court.isActive ? null : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      '${court.location} • \$${court.pricePerHour.toStringAsFixed(0)}'
                      '${court.isActive ? '' : '  (inactiva)'}',
                      style: inactiveStyle,
                    ),
                    onTap: () => _navigateToForm(court: court),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToForm(court: court),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmAndDelete(court),
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
        label: const Text('Nueva'),
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
