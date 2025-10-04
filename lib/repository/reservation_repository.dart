import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/reservation_model.dart';
import '../resource/constants.dart';

class ReservationRepository {
  final StreamController<String> _errorController = StreamController<String>();

  Stream<String> get errorStream => _errorController.stream;

  Map<String, String> getHeaders() => {
        HttpHeaders.contentTypeHeader: Constants.contentTypeHeader,
        HttpHeaders.authorizationHeader: Constants.authorizationHeader,
      };

  /// Obtener todas las reservaciones
  Future<List<ReservationModel>> getReservations() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.urlAuthority}/${Constants.reservationAPIGetAll}'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;

        if (decoded.containsKey('data') && decoded['data'] is List) {
          final data = decoded['data'] as List<dynamic>;
          return data
              .map((item) => ReservationModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _errorController.add('Respuesta inválida: campo "data" no encontrado o incorrecto.');
        }
      } else {
        _errorController.add(
          'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
      }
    } catch (e) {
      _errorController.add('Error: $e');
    }
    return [];
  }

  /// Obtener reservación por ID
  Future<ReservationModel?> getReservationById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.urlAuthority}/${Constants.reservationAPIGetById}/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded.containsKey('data')) {
          return ReservationModel.fromJson(decoded['data'] as Map<String, dynamic>);
        } else {
          _errorController.add('Respuesta inválida: campo "data" no encontrado.');
        }
      } else {
        _errorController.add(
          'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
      }
    } catch (e) {
      _errorController.add('Error: $e');
    }
    return null;
  }

  /// Crear nueva reservación
  Future<ReservationModel?> createReservation(ReservationModel reservation) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.urlAuthority}/${Constants.reservationAPICreate}'),
        headers: getHeaders(),
        body: jsonEncode(reservation.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded.containsKey('data')) {
          return ReservationModel.fromJson(decoded['data'] as Map<String, dynamic>);
        } else {
          _errorController.add('Respuesta inválida: campo "data" no encontrado.');
        }
      } else {
        _errorController.add(
          'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
      }
    } catch (e) {
      _errorController.add('Error: $e');
    }
    return null;
  }

  /// Actualizar reservación
  Future<ReservationModel?> updateReservation(ReservationModel reservation) async {
    try {
      final response = await http.put(
        Uri.parse('${Constants.urlAuthority}/${Constants.reservationAPIUpdate}/${reservation.id}'),
        headers: getHeaders(),
        body: jsonEncode(reservation.toJson()),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded.containsKey('data')) {
          return ReservationModel.fromJson(decoded['data'] as Map<String, dynamic>);
        } else {
          _errorController.add('Respuesta inválida: campo "data" no encontrado.');
        }
      } else {
        _errorController.add(
          'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
      }
    } catch (e) {
      _errorController.add('Error: $e');
    }
    return null;
  }

  /// Eliminar reservación
  Future<bool> deleteReservation(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${Constants.urlAuthority}/${Constants.reservationAPIDelete}/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        _errorController.add(
          'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
      }
    } catch (e) {
      _errorController.add('Error: $e');
    }
    return false;
  }

  void dispose() => _errorController.close();
}
