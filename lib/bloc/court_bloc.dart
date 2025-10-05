import 'dart:async';
import '../repository/court_repository.dart';
import '../model/court_model.dart';

class CourtBloc {
  final CourtRepository _repository = CourtRepository();

  final _courtListController = StreamController<List<CourtModel>>.broadcast();
  final _courtController = StreamController<CourtModel>();
  final _messageController = StreamController<String>();

  List<CourtModel> _courtList = [];

  Stream<List<CourtModel>> get courtListStream => _courtListController.stream;
  Stream<CourtModel> get courtStream => _courtController.stream;
  Stream<String> get messageStream => _messageController.stream;

  CourtBloc() {
    _repository.errorStream.listen((error) {
      _messageController.sink.add(error);
    });
  }

  Future<void> loadCourts() async {
    _courtList = await _repository.getCourts();
    _courtListController.sink.add(_courtList);
  }

  Future<void> loadCourtById(int id) async {
    final court = await _repository.getCourtById(id);
    if (court != null) {
      _courtController.sink.add(court);
    }
  }

  Future<CourtModel?> buscarCourtPorId(int id) async =>
      await _repository.getCourtById(id);

  Future<void> createCourt(CourtModel court) async {
    await _repository.createCourt(court);
    await loadCourts();
    _messageController.sink.add('Cancha creada exitosamente');
  }

  Future<void> updateCourt(CourtModel court) async {
    final success = await _repository.updateCourt(court);
    if (success) {
      await loadCourts();
      _messageController.sink.add('Cancha actualizada exitosamente');
    }
  }

  Future<void> deleteCourt(int id) async {
    final success = await _repository.softDeleteCourt(id);
    if (success) {
      await loadCourts();
      _messageController.sink.add('Cancha desactivada exitosamente');
    }
  }

  void dispose() {
    _courtListController.close();
    _courtController.close();
    _messageController.close();
    _repository.dispose();
  }
}
