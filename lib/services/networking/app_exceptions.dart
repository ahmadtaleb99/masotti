import 'package:easy_localization/src/public_ext.dart';

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException({String ?  message})
      : super(message, "Internet Error".tr());
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException({String ?  message}) : super(message, "Invalid Input: ");
}