import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class NetworkAPI {
  final Dio _dio = Dio();
  // ignore: non_constant_identifier_names
  API() {
    // _dio.options.baseUrl = 'https://jsonplaceholder.typicode.com';
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
  }

  Dio get sendRequest => _dio;
}
