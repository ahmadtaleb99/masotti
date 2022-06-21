import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import 'app_exceptions.dart';

class NetworkingHelper {
  static Future<dynamic> getData(String url,
      {Map<String, String>? headers}) async {
    var responseJson;

    try {
      http.Response response = await http
          .get(Uri.parse(Constants.apiUrl + url),
              headers: headers ?? {'referer': Constants.apiReferer})
          .timeout(Duration(seconds: 12));

      log(response.body.toString());
      return responseJson = _returnResponse(response);

    } on SocketException {
      throw FetchDataException(message: 'Error Occurred while getting data'.tr());
    } catch (e) {
      throw FetchDataException(message: 'Error Occurred while getting data'.tr());

      rethrow;
    }
  }

  static Future<dynamic> postData(String url,
      {required, Map<String, String>? headers, required Object? body}) async {
    var responseJson;

    try {
      final response = await http.post(Uri.parse(Constants.apiUrl + url),
                body: body,
      headers: headers ?? {'referer': Constants.apiReferer}
      ).timeout(const Duration(seconds: 9));

      return responseJson = _returnResponse(response);
          } on SocketException {
      throw FetchDataException(message: 'Error Occurred while getting data'.tr());
      } catch (e) {
throw FetchDataException(message: 'Error Occurred while getting data'.tr());
      rethrow;
      }
  }

  static dynamic _returnResponse(http.Response response) {

    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;

      case 400:
        throw BadRequestException(response.body.toString());

      case 401:

      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:

      default:
        throw FetchDataException(
            message:
                'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
