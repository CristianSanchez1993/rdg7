import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';
import '../resource/constants.dart';

class UserRepository {
  final StreamController<String> _errorController = StreamController<String>();

  Stream<String> get errorStream => _errorController.stream;

  Map<String, String> getHeaders() {
    return {
      HttpHeaders.contentTypeHeader: Constants.contentTypeHeader,
      HttpHeaders.authorizationHeader: Constants.authorizationHeader,
    };
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse("${Constants.urlAuthority}/${Constants.userAPIGetAll}"),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        if (decoded.containsKey('data') && decoded['data'] is List) {
          final List<dynamic> data = decoded['data'];
          return data.map((item) => UserModel.fromJson(item)).toList();
        } else {
          _errorController.add(
            "Respuesta inválida: campo 'data' no encontrado o incorrecto.",
          );
        }
      } else {
        _errorController.add(
          "Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}",
        );
      }
    } catch (e) {
      _errorController.add("Error: $e");
    }
    return [];
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final url = Uri.parse(
        "${Constants.urlAuthority}/${Constants.userAPIGetById}?id=$id",
      );

      final response = await http.get(url, headers: getHeaders());

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded.containsKey('data')) {
          return UserModel.fromJson(decoded['data']);
        } else {
          _errorController.add(
            "Respuesta inválida: campo 'data' no encontrado.",
          );
        }
      } else {
        _errorController.add(
          "Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}",
        );
      }
    } catch (e) {
      _errorController.add("Error: $e");
    }
    return null;
  }

  Future<UserModel?> createUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.urlAuthority}/${Constants.userAPICreate}"),
        headers: getHeaders(),
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded.containsKey('data')) {
          return UserModel.fromJson(decoded['data']);
        } else {
          _errorController.add(
            "Respuesta inválida: campo 'data' no encontrado.",
          );
        }
      } else {
        _errorController.add(
          "Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}",
        );
      }
    } catch (e) {
      _errorController.add("Error: $e");
    }
    return null;
  }

  Future<UserModel?> updateUser(UserModel user) async {
    try {
      final response = await http.put(
        Uri.parse(
          "${Constants.urlAuthority}/${Constants.userAPIUpdate}/${user.id}",
        ),
        headers: getHeaders(),
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded.containsKey('data')) {
          return UserModel.fromJson(decoded['data']);
        } else {
          _errorController.add(
            "Respuesta inválida: campo 'data' no encontrado.",
          );
        }
      } else {
        _errorController.add(
          "Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}",
        );
      }
    } catch (e) {
      _errorController.add("Error: $e");
    }
    return null;
  }

  Future<bool> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("${Constants.urlAuthority}/${Constants.userAPIDelete}/$id"),
        headers: getHeaders(),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        _errorController.add(
          "Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}",
        );
        return false;
      }
    } catch (e) {
      _errorController.add("Error: $e");
      return false;
    }
  }

  void dispose() {
    _errorController.close();
  }
}
