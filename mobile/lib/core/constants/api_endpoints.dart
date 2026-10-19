class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.sportsstore.vn/api/v1';
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;

  // Products
  static const String products = '/products';

  // Categories
  static const String categories = '/categories';
}
