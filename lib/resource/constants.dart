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

  // Users
  static final String userAPIGetAll = '$contextPath/user/all';
  static final String userAPIGetById = '$contextPath/user';
  static final String userAPICreate = '$contextPath/user/create';
  static final String userAPIUpdate = '$contextPath/user/update';
  static final String userAPIDelete = '$contextPath/user/delete';

  // Reservations
  static final String reservationAPIGetAll = '$contextPath/reservations';
  static final String reservationAPIGetById = '$contextPath/reservations';
  static final String reservationAPICreate = '$contextPath/reservations';
  static final String reservationAPIUpdate = '$contextPath/reservations';
  static final String reservationAPIDelete = '$contextPath/reservations';

  // Courts (según tu CourtController)
  static final String courtAPIGetAll  = '$contextPath/court/get-all';
  static final String courtAPIGetById = '$contextPath/court/get-by-id';
  static final String courtAPICreate  = '$contextPath/court/create';
  static final String courtAPIUpdate  = '$contextPath/court/update-by-id';
  static final String courtAPIDelete  = ''; // no existe en backend

  // Sports (según tu SportController)
  static final String sportAPIGetAll  = '$contextPath/sport/get-all';
  static final String sportAPIGetById = '$contextPath/sport/get-by-id';
  static final String sportAPICreate  = '$contextPath/sport/create';
  static final String sportAPIUpdate  = '$contextPath/sport/update-by-id';
  static final String sportAPIDelete  = ''; // no existe en backend
}
