import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';


class NetworkingHelper{



  static Future<dynamic>  getData (String url,{Map<String, String>? headers}) async {

    try{
        http.Response response  = await http.get(Uri.parse(Constants.apiUrl + url),headers: headers ??  {'referer': Constants.apiReferer} );
        var data = jsonDecode(response.body);

        if(response.statusCode == 200){
          return data;
        }


      }
    catch(e){
    print('networking class error :::::::::::; $e');
    rethrow;
    }
  }


  static  Future<dynamic>  postData (
  String url,
      { required ,
    Map<String, String>? headers,
        required Object? body}) async {

    try{
      final response = await http.post(Uri.parse(Constants.apiUrl + url),
          body: body, headers: {'referer': Constants.apiReferer}).timeout(const Duration(seconds: 9));
      var data = jsonDecode(response.body);

      if(response.statusCode == 200){
        return data;
      }


    }
    catch(e){
      print('networking class error :::::::::::; $e');
      rethrow;
    }
  }


}