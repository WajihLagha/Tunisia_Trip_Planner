import 'package:dio/dio.dart';


class DioHelper {
  static late Dio dio;

  static inti() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://newsapi.org/",
        receiveDataWhenStatusError: false,
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String lang = 'en',
    String? token,
  }) async {
    dio.options.headers = {
      'content-type': 'application/json',
      'lang' : lang,
      'Authorization' : token,
    };

    return await dio.get(
      url,
      queryParameters: query,
    );
  }


  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? query,
    required Map<String, dynamic> data,
    String? token,
    var lang = "en",

  }) async {
    dio.options.headers = {
      'content-type': 'application/json',
      'lang' : lang,
      'Authorization' : token,
    };

    return await dio.put(
      url,
      queryParameters: query,
      data: data,
    );
  }


  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? query,
    required Map<String, dynamic> data,
    String? token,
    var lang = "en",
  }) async {
    dio.options.headers = {
      'content-type': 'application/json',
      "lang" : lang,
      "Authorization": token,
    };
    return await dio.post(
      url,
      data: data,
      queryParameters: query,
    );
  }
}

