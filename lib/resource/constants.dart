// coverage:ignore-file
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static const Color primaryColor = Color.fromRGBO(50, 171, 172, 1);
  static const Color secondaryColor = Color.fromRGBO(156, 156, 156, 1);
  static const Color accentColor = Color.fromARGB(200, 50, 171, 172);

  static const double fontSizeTitle = 18;
  static const double fontSizeButton = 17;

  static String get urlAuthority => dotenv.env['API_URL_AUTHORITY'] ?? '';
  static String get contextPath => dotenv.env['API_CONTEXT_PATH'] ?? '';

  static const String contentTypeHeader = 'application/json';

  static String get authorizationHeader {
    final username = dotenv.env['API_USERNAME']!;
    final password = dotenv.env['API_PASSWORD']!;
    final credentials = '$username:$password';
    final encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }

  static http.Client httpClient = http.Client();

  static void overrideHttpClient(http.Client client) {
    httpClient = client;
  }

  static final String userAPIGetAll = '$contextPath/user/all';
  static final String userAPIGetById = '$contextPath/user';
  static final String userAPICreate = '$contextPath/user/create';
  static final String userAPIUpdate = '$contextPath/user/update';
  static final String userAPIDelete = '$contextPath/user/delete';
}
