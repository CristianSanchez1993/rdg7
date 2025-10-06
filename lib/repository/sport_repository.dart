import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/sport_model.dart';
import '../resource/constants.dart';

class SportRepository {
  final http.Client httpClient;
  SportRepository({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  final StreamController<String> _errorController = StreamController<String>();
  Stream<String> get errorStream => _errorController.stream;

  Map<String, String> getHeaders() => {
        HttpHeaders.contentTypeHeader: Constants.contentTypeHeader,
        HttpHeaders.authorizationHeader: Constants.authorizationHeader,
      };

  Future<List<SportModel>> getSports() async {
    try {
      final response = await httpClient.get(
        Uri.parse('${Constants.urlAuthority}/${Constants.sportAPIGetAll}'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final List<dynamic> data = decoded['data'] as List<dynamic>;
          return data
              .map((e) => SportModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _errorController.add("Respuesta inválida: falta 'data' lista.");
        }
      } else {
        _errorController.add(
          'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
      }
    } catch (e) {
      _errorController.add('Error al obtener deportes: $e');
    }
    return [];
  }

  Future<SportModel?> getSportById(int id) async {
    try {
      final url = Uri.parse(
        '${Constants.urlAuthority}/${Constants.sportAPIGetById}/$id',
      );
      final response = await httpClient.get(url, headers: getHeaders());

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is Map) {
          return SportModel.fromJson(decoded['data'] as Map<String, dynamic>);
        } else {
          _errorController.add("Respuesta inválida: 'data' no es objeto.");
        }
      } else {
        _errorController.add(
          'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
      }
    } catch (e) {
      _errorController.add('Error al obtener deporte por ID: $e');
    }
    return null;
  }

  Future<SportModel> createSport(SportModel sport) async {
    try {
      final response = await httpClient.post(
        Uri.parse('${Constants.urlAuthority}/${Constants.sportAPICreate}'),
        headers: getHeaders(),
        body: jsonEncode(sport.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is Map) {
          return SportModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        throw Exception("Respuesta inválida: falta 'data'.");
      }
      throw Exception(
          'Error creando deporte: ${response.statusCode} ${response.body}');
    } catch (e) {
      _errorController.add('Error al crear deporte: $e');
      rethrow;
    }
  }

  Future<bool> updateSport(SportModel sport) async {
    try {
      final response = await httpClient.put(
        Uri.parse('${Constants.urlAuthority}/${Constants.sportAPIUpdate}'),
        headers: getHeaders(),
        body: jsonEncode(sport.toJson()),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> && decoded['success'] == true;
      }
      throw Exception(
          'Error actualizando deporte: ${response.statusCode} ${response.body}');
    } catch (e) {
      _errorController.add('Error al actualizar deporte: $e');
      return false;
    }
  }

  Future<bool> deleteSport(int id) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('${Constants.urlAuthority}/${Constants.sportAPIDelete}/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isEmpty) return true;
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          
          if (decoded['success'] == true) return true;
        }
        
        return true;
      } else {
        _errorController.add(
          'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
        return false;
      }
    } catch (e) {
      _errorController.add('Error al eliminar deporte: $e');
      return false;
    }
  }

  void dispose() {
    _errorController.close();
  }
}
