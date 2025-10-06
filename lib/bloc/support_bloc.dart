import 'package:flutter/foundation.dart';

class SupportBloc extends ChangeNotifier {
  final String phone;
  final String email;

  SupportBloc({
    this.phone = '3173870395',
    this.email = 'cristianandressanchez.1993@gmail.com',
  });
}
