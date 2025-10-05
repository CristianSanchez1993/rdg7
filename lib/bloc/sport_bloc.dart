import 'dart:async';
import '../repository/sport_repository.dart';
import '../model/sport_model.dart';

class SportBloc {
  final SportRepository _repository = SportRepository();

  final _sportListController = StreamController<List<SportModel>>.broadcast();
  final _sportController = StreamController<SportModel>();
  final _messageController = StreamController<String>();

  List<SportModel> _sportList = [];

  Stream<List<SportModel>> get sportListStream => _sportListController.stream;
  Stream<SportModel> get sportStream => _sportController.stream;
  Stream<String> get messageStream => _messageController.stream;

  SportBloc() {
    _repository.errorStream.listen((error) {
      // Asegura que el tipo sea String
      _messageController.sink.add(error.toString());
    });
  }

  Future<void> loadSports() async {
    _sportList = await _repository.getSports();
    _sportListController.sink.add(_sportList);
  }

  Future<void> loadSportById(int id) async {
    final sport = await _repository.getSportById(id);
    if (sport != null) {
      _sportController.sink.add(sport);
    }
  }

  Future<void> createSport(SportModel sport) async {
    await _repository.createSport(sport);
    await loadSports();
    _messageController.sink.add('Deporte creado exitosamente');
  }

  Future<void> updateSport(SportModel sport) async {
    final success = await _repository.updateSport(sport);
    if (success) {
      await loadSports();
      _messageController.sink.add('Deporte actualizado exitosamente');
    }
  }

  // No hay endpoint DELETE para sports: dejamos un stub amigable
  Future<bool> deleteSport(int id) async {
    _messageController.sink.add('Eliminar deporte no está disponible en el backend.');
    return false;
  }

  void dispose() {
    _sportListController.close();
    _sportController.close();
    _messageController.close();
    _repository.dispose();
  }
}
