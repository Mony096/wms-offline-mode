import 'dart:convert';
import 'dart:developer';

import '../constant/api.dart';

import 'package:dio/dio.dart';
import '../core/error/failure.dart';
import '/utilies/storage/locale_storage.dart';

class DioClient {
  Dio _dio = Dio();

  // Create a new CancelToken
  final cancelToken = CancelToken();

  DioClient() {
    _dio = Dio(
      BaseOptions(
        receiveDataWhenStatusError: true,
        // connectTimeout: const Duration(seconds: 5),
        // receiveTimeout: const Duration(seconds: 5),
      ),
    );
  }

  Future<Response> get(String uri,
      {Options? options, Map<String, dynamic>? query}) async {
    try {
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');
      final token = await LocalStorageManger.getString('SessionId');
      final res = await _dio.get(
        '${host == '' ? 'https://lk.biz-dimension.com' : host}:${port == '' ? '50000' : port}/b1s/v1/$uri',
        queryParameters: query,
        options: Options(
          headers: {
            'Content-Type': "application/json",
            'Cookie': 'B1SESSION=$token; ROUTEID=.node9'
            // ...options,
          },
        ),
        cancelToken: cancelToken,
      );

      return res;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ConnectionRefuse(
          message: "Sorry due our server is error. please contact our support.",
        );
      }

      if (e.response?.statusCode == 401) {
        throw UnauthorizeFailure(message: 'Session already timeout');
      }

      throw ServerFailure(
        message: e.response?.data['error']['message']['value'],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String uri,
      {Options? options,
      Object? data,
      Map<String, dynamic>? queryParameters}) async {
    try {
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');
      final token = await LocalStorageManger.getString('SessionId');
      _dio.options.headers['Content-Type'] = "application/json";
      // _dio.options.headers['Authorization'] = "Bearer $token";

      return await _dio
          .post(
        '${host == '' ? 'https://lk.biz-dimension.com' : host}:${port == '' ? '50000' : port}/b1s/v1/$uri',
        data: data,
        options: Options(
          headers: {
            'Content-Type': "application/json",
            'Cookie': 'B1SESSION=$token; ROUTEID=.node9'
            // ...options,
          },
        ),
        cancelToken: cancelToken,
        queryParameters: queryParameters,
      )
          .then((value) {
        return value;
      });
    } on DioException catch (e) {
      log(e.requestOptions.method);
      log(e.requestOptions.uri.toString());
      log(jsonEncode(e.requestOptions.data));
      log('dio ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionError) {
        throw const ConnectionRefuse(
          message: "Invalid server host name.",
        );
      }

      // log(jsonEncode(message));
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ConnectionRefuse(
          message: "Sorry due our server is error. please contact our support.",
        );
      }

      if (e.response?.statusCode == 401) {
        throw UnauthorizeFailure(message: 'Session already timeout');
      }

      throw ServerFailure(
        message: e.response?.data['error']['message']['value'],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(String uri,
      {Options? options,
      Object? data,
      Map<String, dynamic>? queryParameters}) async {
    try {
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');
      final token = await LocalStorageManger.getString('SessionId');
      _dio.options.headers['Content-Type'] = "application/json";
      // _dio.options.headers['Authorization'] = "Bearer $token";

      return await _dio
          .patch(
            '${host == '' ? 'https://lk.biz-dimension.com' : host}:${port == '' ? '50000' : port}/b1s/v1/$uri',
            data: data,
            options: Options(
              headers: {
                'Content-Type': "application/json",
                'Cookie': 'B1SESSION=$token; ROUTEID=.node9'
                // ...options,
              },
            ),
            cancelToken: cancelToken,
            queryParameters: queryParameters,
          )
          .then((value) => value);
    } on DioException catch (e) {
      log(e.requestOptions.method);
      log(e.requestOptions.uri.toString());
      log(jsonEncode(e.requestOptions.data));
      log('dio ${e.response?.statusCode}');

      dynamic message = e.response?.data['error']['message']['value'];

      log(jsonEncode(message));

      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ConnectionRefuse(
          message: "Sorry due our server is error. please contact our support.",
        );
      }

      if (e.response?.data != null) {
        throw HttpError(message: message);
      }

      throw const ServerFailure(message: 'Invalid request.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String uri,
      {Options? options,
      Object? data,
      Map<String, dynamic>? queryParameters}) async {
    try {
      final host = await LocalStorageManger.getString('host');
      final port = await LocalStorageManger.getString('port');
      final token = await LocalStorageManger.getString('SessionId');
      _dio.options.headers['Content-Type'] = "application/json";
      // _dio.options.headers['Authorization'] = "Bearer $token";

      return await _dio
          .put(
            '${host == '' ? 'https://lk.biz-dimension.com' : host}:${port == '' ? '50000' : port}/b1s/v1/$uri',
            data: data,
            options: Options(
              headers: {
                'Content-Type': "application/json",
                'Cookie': 'B1SESSION=$token; ROUTEID=.node9'
                // ...options,
              },
            ),
            cancelToken: cancelToken,
            queryParameters: queryParameters,
          )
          .then((value) => value);
    } on DioException catch (e) {
      log(e.requestOptions.method);
      log(e.requestOptions.uri.toString());
      log(jsonEncode(e.requestOptions.data));
      log('dio ${e.response?.statusCode}');

      dynamic message = e.response?.data['error']['message']['value'];

      log(jsonEncode(message));

      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ConnectionRefuse(
          message: "Sorry due our server is error. please contact our support.",
        );
      }

      if (e.response?.data != null) {
        throw HttpError(message: message);
      }

      throw const ServerFailure(message: 'Invalid request.');
    } catch (e) {
      rethrow;
    }
  }
}
