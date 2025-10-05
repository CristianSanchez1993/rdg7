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
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose(); // el Provider se encarga de dispose del bloc
  }

  Future<void> _navigateToForm({SportModel? sport}) async {
    final SportModel? result = await Navigator.push<SportModel?>(
      context,
      MaterialPageRoute<SportModel?>(
        builder: (_) => SportFormScreen(sport: sport),
      ),
    );
    if (result != null) {
      if (sport == null) {
        await _bloc.createSport(result);
      } else {
        // asegurar que mandamos id al actualizar
        await _bloc.updateSport(result.copyWith(id: sport.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<SportBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Deportes')),
      body: StreamBuilder<List<SportModel>>(
        stream: bloc.sportListStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando deportes'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sports = snapshot.data!;
          if (sports.isEmpty) {
            return const Center(child: Text('No hay deportes disponibles'));
          }

          return ListView.builder(
            itemCount: sports.length,
            itemBuilder: (context, index) {
              final sport = sports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    sport.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _navigateToForm(sport: sport),
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
