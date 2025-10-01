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

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Lista de Reservas')),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ReservationModel>>(
                stream: context.read<ReservationBloc>().reservationListStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error cargando reservas'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay reservas'));
                  }

                  final reservations = snapshot.data!;
                  return ListView.separated(
                    itemCount: reservations.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = reservations[index];
                      return ListTile(
                        title: Text(
                          'Cancha: ${r.courtId} | Usuario: ${r.userId}',
                        ),
                        subtitle: Text(
                          'Inicio: ${r.startAt} - Fin: ${r.endAt}\n'
                          'Estado: ${r.statusCode}'
                          '${r.notes != null && r.notes!.isNotEmpty ? '\nNotas: ${r.notes}' : ''}', 
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar reserva'),
                                content: const Text(
                                  '¿Estás seguro de que deseas eliminar esta reserva?',
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
                              try {
                                await context
                                    .read<ReservationBloc>()
                                    .deleteReservation(r.id.toString());
                                if (!mounted) return;
                                showSnackBar('Reserva eliminada');
                              } catch (e) {
                                if (!mounted) return;
                                showSnackBar('Error al eliminar reserva');
                              }
                            }
                          },
                        ),
                        onTap: () {
                          //  Abrir en modo edición
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ReservationFormScreen(reservation: r),
                            ),
                          );
                        },
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ReservationFormScreen(),
              ),
            );
          },
        ),
      );
}
