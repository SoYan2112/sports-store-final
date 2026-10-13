import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

class DioClient {
  final Dio dio;

  DioClient({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.baseUrl,
                connectTimeout: const Duration(milliseconds: ApiEndpoints.connectTimeoutMs),
                receiveTimeout: const Duration(milliseconds: ApiEndpoints.receiveTimeoutMs),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );
}
