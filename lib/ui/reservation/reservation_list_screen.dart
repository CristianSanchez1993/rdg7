import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rdg7/bloc/reservation_bloc.dart';
import 'package:rdg7/model/reservation_model.dart';
import 'package:rdg7/ui/reservation/reservation_form_screen.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ReservationModel? _reservaFiltrada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationBloc>().loadReservations();
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  void _buscarPorId() async {
    final id = _searchController.text.trim();
    if (id.isEmpty) {
      setState(() => _reservaFiltrada = null);
      await context.read<ReservationBloc>().loadReservations();
      return;
    }

    final reserva = await context.read<ReservationBloc>().buscarPorId(id);
    if (reserva == null) {
      _showSnack('No se encontró reserva con ID $id');
      setState(() => _reservaFiltrada = null);
    } else {
      _showSnack('Reserva encontrada: ID ${reserva.id}');
      setState(() => _reservaFiltrada = reserva);
    }
  }

  void _mostrarDetalle(BuildContext context, ReservationModel r) {
    final data = r.toJson();
    final courtName = (data['courtDTO']?['name'] ?? 'Cancha #${r.courtId}').toString();
    final userJson = data['userDTO'];
    final userName = userJson != null
        ? '${userJson['firstName'] ?? ''} ${userJson['lastName'] ?? ''}'.trim()
        : 'Usuario #${r.userId}';

    const activeGreen = Color(0xFF16A34A);
    final borderColor = activeGreen.withValues(alpha:0.7);
    final shadowColor = borderColor.withValues(alpha:0.25);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final surface = Theme.of(context).colorScheme.surface;
        final onSurface = Theme.of(context).colorScheme.onSurface;

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: borderColor, width: 1.5),
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
                      'Detalles de la reserva',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),

                    _InfoRow(label: 'Cancha', value: courtName),
                    _InfoRow(label: 'Usuario', value: userName),
                    _InfoRow(label: 'Inicio', value: r.startAt.toString()),
                    _InfoRow(label: 'Fin', value: r.endAt.toString()),
                    _InfoRow(label: 'Estado', value: r.statusCode),
                    _InfoRow(label: 'Notas', value: r.notes ?? '—'),

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
        appBar: AppBar(centerTitle: true, title: const Text('Lista de Reservas')),
        body: Column(
          children: [
            // === Barra de búsqueda ===
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _buscarPorId(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Buscar reserva por ID',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.35),
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
                  GradientButton(label: 'Buscar', onPressed: _buscarPorId),
                ],
              ),
            ),

            // === Lista ===
            Expanded(
              child: _reservaFiltrada != null
                  ? ListView(
                      children: [
                        ReservationCard(
                          reserva: _reservaFiltrada!,
                          onTap: () => _mostrarDetalle(context, _reservaFiltrada!),
                          onEdit: () async {
                            final bloc = context.read<ReservationBloc>();
                            final value = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReservationFormScreen(reservation: _reservaFiltrada),
                              ),
                            );
                            if (mounted && value == true) await bloc.loadReservations();
                          },
                          onDelete: () async {
                            final bloc = context.read<ReservationBloc>();
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Eliminar reserva'),
                                content: const Text('¿Seguro que deseas eliminar esta reserva?'),
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
                            if (confirm == true) {
                              await bloc.deleteReservation(_reservaFiltrada!.id.toString());
                              if (!mounted) return;
                              _showSnack('Reserva eliminada');
                              setState(() => _reservaFiltrada = null);
                              await bloc.loadReservations();
                            }
                          },
                        ),
                      ],
                    )
                  : StreamBuilder<List<ReservationModel>>(
                      stream: context.read<ReservationBloc>().reservationListStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error cargando reservas'));
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final reservas = snapshot.data!;
                        if (reservas.isEmpty) {
                          return const Center(child: Text('No hay reservas registradas'));
                        }

                        return ListView.builder(
                          itemCount: reservas.length,
                          itemBuilder: (context, i) {
                            final r = reservas[i];
                            return ReservationCard(
                              reserva: r,
                              onTap: () => _mostrarDetalle(context, r),
                              onEdit: () async {
                                final bloc = context.read<ReservationBloc>();
                                final value = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReservationFormScreen(reservation: r),
                                  ),
                                );
                                if (mounted && value == true) await bloc.loadReservations();
                              },
                              onDelete: () async {
                                final bloc = context.read<ReservationBloc>();
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Eliminar reserva'),
                                    content: const Text(
                                        '¿Estás seguro de que deseas eliminar esta reserva?'),
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
                                if (confirm == true) {
                                  await bloc.deleteReservation(r.id.toString());
                                  if (!mounted) return;
                                  _showSnack('Reserva eliminada');
                                  await bloc.loadReservations();
                                }
                              },
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
            final bloc = context.read<ReservationBloc>();
            final value = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const ReservationFormScreen()),
            );
            if (!mounted) return;
            if (value == true) await bloc.loadReservations();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
}

// === Card de Reserva ===
class ReservationCard extends StatelessWidget {
  final ReservationModel reserva;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const ReservationCard({
    super.key,
    required this.reserva,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final data = reserva.toJson();
    final courtName = (data['courtDTO']?['name'] ?? 'Cancha #${reserva.courtId}').toString();
    final userJson = data['userDTO'];
    final userName = userJson != null
        ? '${userJson['firstName'] ?? ''} ${userJson['lastName'] ?? ''}'.trim()
        : 'Usuario #${reserva.userId}';

    final scheme = Theme.of(context).colorScheme;
    final isConfirmed = reserva.statusCode == 'CONFIRMED';

    final borderColor = isConfirmed ? const Color(0xFF16A34A) : scheme.outline.withValues(alpha:0.8);
    final shadowColor = borderColor.withValues(alpha:0.3);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(offset: const Offset(0, 6), blurRadius: 12, spreadRadius: -6, color: shadowColor),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: const Icon(Icons.event_available),
          ),
          title: Text(courtName, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            '$userName\n${reserva.startAt} → ${reserva.endAt}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          trailing: Wrap(
            spacing: 8,
            children: [
              _ActionIcon(icon: Icons.edit_note_rounded, bg: scheme.primary, onTap: onEdit, tooltip: 'Editar'),
              _ActionIcon(icon: Icons.delete_forever_rounded, bg: scheme.error, onTap: onDelete, tooltip: 'Eliminar'),
            ],
          ),
        ),
      ),
    );
  }
}

// === Reutilizables (igual que en tu UserListScreen) ===
class GradientFab extends StatelessWidget {
  final VoidCallback onPressed;
  const GradientFab({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) => Material(
        elevation: 6,
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: Ink(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const GradientButton({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      );
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final VoidCallback onTap;
  final String tooltip;
  const _ActionIcon({required this.icon, required this.bg, required this.onTap, required this.tooltip});
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
  const _InfoRow({required this.label, required this.value});
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
            child: Text('$label:',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
