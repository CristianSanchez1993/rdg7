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
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }

  Future<void> _navigateToForm({CourtModel? court}) async {
    final CourtModel? result = await Navigator.push<CourtModel?>(
      context,
      MaterialPageRoute<CourtModel?>(
        builder: (_) => CourtFormScreen(court: court),
      ),
    );

    if (result != null) {
      if (court == null) {
        await _bloc.createCourt(result);
      } else {
        // defensivo: no intentes actualizar sin id
        if (court.id == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se puede actualizar: el backend no envía id en GET.'),
            ),
          );
          return;
        }
        await _bloc.updateCourt(result.copyWith(id: court.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<CourtBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Canchas')),
      body: StreamBuilder<List<CourtModel>>(
        stream: bloc.courtListStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando canchas'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final courts = snapshot.data!;
          if (courts.isEmpty) {
            return const Center(child: Text('No hay canchas disponibles'));
          }

          return ListView.builder(
            itemCount: courts.length,
            itemBuilder: (context, index) {
              final court = courts[index];
              final inactiveStyle =
                  court.isActive ? null : const TextStyle(color: Colors.grey);

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    court.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: court.isActive ? null : Colors.grey,
                    ),
                  ),
                  subtitle: Text(
                    '${court.location} - \$${court.pricePerHour.toStringAsFixed(0)}'
                    '${court.isActive ? '' : '  (inactiva)'}',
                    style: inactiveStyle,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToForm(court: court),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
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
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Aceptar'),
                                ),
                              ],
                            ),
                          );
                          if (!mounted) return;

                          if (confirm == true) {
                            final id = court.id;
                            if (id != null) {
                              await bloc.deleteCourt(id);
                              if (!mounted) return;
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('No se pudo desactivar: id nulo'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
