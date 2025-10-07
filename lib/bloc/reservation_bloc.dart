import 'dart:async';
import '../repository/reservation_repository.dart';
import '../model/reservation_model.dart';

class ReservationBloc {
  final ReservationRepository _repository = ReservationRepository();

  final _reservationListController =
      StreamController<List<ReservationModel>>.broadcast();
  final _reservationController = StreamController<ReservationModel>();
  final _messageController = StreamController<String>();

  List<ReservationModel> _reservationList = [];

  Stream<List<ReservationModel>> get reservationListStream =>
      _reservationListController.stream;
  Stream<ReservationModel> get reservationStream =>
      _reservationController.stream;
  Stream<String> get messageStream => _messageController.stream;

  ReservationBloc() {
    _repository.errorStream.listen((error) {
      _messageController.sink.add(error);
    });
  }

  Future<void> loadReservations() async {
    _reservationList = await _repository.getReservations();
    _reservationListController.sink.add(_reservationList);
  }

  Future<void> loadReservationById(String id) async {
    final reservation = await _repository.getReservationById(id);
    if (reservation != null) {
      _reservationController.sink.add(reservation);
    }
  }

  Future<ReservationModel?> buscarPorId(String id) async {
    try {
      return _reservationList.firstWhere((r) => r.id.toString() == id);
    } catch (_) {
      return await _repository.getReservationById(id);
    }
  }

  Future<void> createReservation(ReservationModel reservation) async {
    final created = await _repository.createReservation(reservation);
    if (created != null) {
      _reservationList.add(created);
      _reservationListController.sink.add(_reservationList.toList());
      _messageController.sink.add('Reserva creada exitosamente');
    }
  }

  Future<void> updateReservation(ReservationModel reservation) async {
    final updated = await _repository.updateReservation(reservation);
    if (updated != null) {
      final index = _reservationList.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        _reservationList[index] = updated;
        _reservationListController.sink.add(_reservationList.toList());
        _messageController.sink.add('Reserva actualizada exitosamente');
      }
    }
  }

  Future<void> deleteReservation(String id) async {
    final success = await _repository.deleteReservation(id);
    if (success) {
      _reservationList.removeWhere((r) => r.id.toString() == id);
      _reservationListController.sink.add(_reservationList.toList());
      _messageController.sink.add('Reserva eliminada exitosamente');
    }
  }

  void dispose() {
    _reservationListController.close();
    _reservationController.close();
    _messageController.close();
    _repository.dispose();
  }
}
