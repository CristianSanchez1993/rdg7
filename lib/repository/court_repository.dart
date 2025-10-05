import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/court_model.dart';
import '../resource/constants.dart';

class CourtRepository {
  final http.Client httpClient;
  CourtRepository({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  final StreamController<String> _errorController = StreamController<String>();
  Stream<String> get errorStream => _errorController.stream;

  Map<String, String> getHeaders() => {
        HttpHeaders.contentTypeHeader: Constants.contentTypeHeader,
        HttpHeaders.authorizationHeader: Constants.authorizationHeader,
      };

  Future<List<CourtModel>> getCourts() async {
    try {
      final url = Uri.parse('${Constants.urlAuthority}/${Constants.courtAPIGetAll}');
      if (kDebugMode) print('[GET] $url');
      final response = await httpClient.get(url, headers: getHeaders());

      if (kDebugMode) {
        print('[GET] status: ${response.statusCode}');
        if (response.body.isNotEmpty) print('[GET] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final List<dynamic> data = decoded['data'] as List<dynamic>;
          return data
              .map((e) => CourtModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _errorController.add("Respuesta inválida: falta 'data' lista.");
        }
      } else {
        _errorController.add('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _errorController.add('Error al obtener canchas: $e');
    }
    return [];
  }

  // GET /get-by-id/{id}
  Future<CourtModel?> getCourtById(int id) async {
    try {
      final url = Uri.parse('${Constants.urlAuthority}/${Constants.courtAPIGetById}/$id');
      if (kDebugMode) print('[GET] $url');
      final response = await httpClient.get(url, headers: getHeaders());

      if (kDebugMode) {
        print('[GET] status: ${response.statusCode}');
        if (response.body.isNotEmpty) print('[GET] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is Map) {
          return CourtModel.fromJson(decoded['data'] as Map<String, dynamic>);
        } else {
          _errorController.add("Respuesta inválida: 'data' no es objeto.");
        }
      } else {
        _errorController.add('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _errorController.add('Error al obtener cancha por ID: $e');
    }
    return null;
  }

  // POST /create
  Future<CourtModel> createCourt(CourtModel court) async {
    try {
      final url = Uri.parse('${Constants.urlAuthority}/${Constants.courtAPICreate}');
      final body = jsonEncode(court.toJson());
      if (kDebugMode) {
        print('[POST] $url');
        print('[POST] body: $body');
      }

      final response = await httpClient.post(url, headers: getHeaders(), body: body);

      if (kDebugMode) {
        print('[POST] status: ${response.statusCode}');
        if (response.body.isNotEmpty) print('[POST] resp: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is Map) {
          return CourtModel.fromJson(decoded['data'] as Map<String, dynamic>);
        } else {
          // Algunos backends devuelven el mismo DTO enviado (sin id). Lo toleramos:
          return court;
        }
      }
      throw Exception('Error creando cancha: ${response.statusCode} ${response.body}');
    } catch (e) {
      _errorController.add('Error al crear cancha: $e');
      rethrow;
    }
  }

  // PUT /update-by-id (id va en el body)
  Future<bool> updateCourt(CourtModel court) async {
    try {
      final url = Uri.parse('${Constants.urlAuthority}/${Constants.courtAPIUpdate}');
      final body = jsonEncode(court.toJson());

      if (kDebugMode) {
        print('[PUT] $url');
        print('[PUT] body: $body');
      }

      final response = await httpClient.put(url, headers: getHeaders(), body: body);

      if (kDebugMode) {
        print('[PUT] status: ${response.statusCode}');
        if (response.body.isNotEmpty) print('[PUT] resp: ${response.body}');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> && decoded['success'] == true;
      }
      throw Exception('Error actualizando cancha: ${response.statusCode} ${response.body}');
    } catch (e) {
      _errorController.add('Error al actualizar cancha: $e');
      return false;
    }
  }

  // Soft delete (no delete real)
  Future<bool> softDeleteCourt(int id) async {
    try {
      final current = await getCourtById(id);
      if (current == null) {
        _errorController.add('Cancha no encontrada');
        return false;
      }
      final updated = current.copyWith(isActive: false);
      return await updateCourt(updated);
    } catch (e) {
      _errorController.add('Error al desactivar cancha: $e');
      return false;
    }
  }

  void dispose() {
    _errorController.close();
  }
}
