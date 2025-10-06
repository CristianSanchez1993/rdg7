import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/reservation_bloc.dart';
import '../../model/reservation_model.dart';
import 'reservation_form_screen.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReservationBloc>().loadReservations(),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ReservationModel r) async {
  final bloc = context.read<ReservationBloc>(); 

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar reserva'),
      content: const Text('¿Estás seguro de eliminar esta reserva?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    try {
      await bloc.deleteReservation(r.id.toString());
      _showSnackBar('Reserva eliminada');
    } catch (e) {
      _showSnackBar('Error al eliminar la reserva');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<ReservationBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Reservas')),
      body: StreamBuilder<List<ReservationModel>>(
        stream: bloc.reservationListStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando reservas'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final reservations = snapshot.data!;
          if (reservations.isEmpty) {
            return const Center(child: Text('No hay reservas registradas'));
          }

          return ListView.separated(
            itemCount: reservations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final r = reservations[index];
              return ListTile(
                title: Text(
                  'Cancha: ${r.courtId} | Usuario: ${r.userId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Inicio: ${r.startAt}\n'
                  'Fin: ${r.endAt}\n'
                  'Estado: ${r.statusCode}'
                  '${r.notes != null && r.notes!.isNotEmpty ? '\nNotas: ${r.notes}' : ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, r),
                ),
                onTap: () async {
                  
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ReservationFormScreen(reservation: r),
                    ),
                  );
                  if (mounted) await bloc.loadReservations();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const ReservationFormScreen()),
          );
          if (mounted) await bloc.loadReservations();
        },
      ),
    );
  }
}
