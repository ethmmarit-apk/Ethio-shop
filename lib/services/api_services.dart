import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ethio_shop/utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  final String _baseUrl = Constants.apiBaseUrl;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add Ethiopian locale
        options.headers['Accept-Language'] = 'am-ET';
        options.headers['X-Currency'] = 'ETB';
        
        print('🌐 API Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException error, handler) async {
        print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
        
        // Handle token expiration
        if (error.response?.statusCode == 401) {
          await _handleTokenExpiration();
        }
        
        return handler.next(error);
      },
    ));
  }
  
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  Future<void> _handleTokenExpiration() async {
    // Clear auth token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    // Navigate to login (you might want to use a global navigator key)
    print('⚠️ Token expired, please login again');
  }
  
  // Auth endpoints
  Future<Response> login(String email, String password) async {
    return await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }
  
  Future<Response> register(Map<String, dynamic> userData) async {
    return await _dio.post('/auth/register', data: userData);
  }
  
  Future<Response> logout() async {
    return await _dio.post('/auth/logout');
  }
  
  // Product endpoints
  Future<Response> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder = 'desc',
  }) async {
    final params = {
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    
    if (category != null) params['category'] = category;
    if (search != null) params['search'] = search;
    
    return await _dio.get('/products', queryParameters: params);
  }
  
  Future<Response> getProduct(String productId) async {
    return await _dio.get('/products/$productId');
  }
  
  Future<Response> createProduct(Map<String, dynamic> productData) async {
    return await _dio.post('/products', data: productData);
  }
  
  Future<Response> updateProduct(String productId, Map<String, dynamic> productData) async {
    return await _dio.put('/products/$productId', data: productData);
  }
  
  Future<Response> deleteProduct(String productId) async {
    return await _dio.delete('/products/$productId');
  }
  
  // Order endpoints
  Future<Response> createOrder(Map<String, dynamic> orderData) async {
    return await _dio.post('/orders', data: orderData);
  }
  
  Future<Response> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final params = {
      'page': page,
      'limit': limit,
    };
    
    if (status != null) params['status'] = status;
    
    return await _dio.get('/orders', queryParameters: params);
  }
  
  Future<Response> getOrder(String orderId) async {
    return await _dio.get('/orders/$orderId');
  }
  
  Future<Response> cancelOrder(String orderId, String reason) async {
    return await _dio.post('/orders/$orderId/cancel', data: {'reason': reason});
  }
  
  // User endpoints
  Future<Response> getProfile() async {
    return await _dio.get('/users/profile');
  }
  
  Future<Response> updateProfile(Map<String, dynamic> profileData) async {
    return await _dio.put('/users/profile', data: profileData);
  }
  
  // Chat endpoints
  Future<Response> getConversations() async {
    return await _dio.get('/chat/conversations');
  }
  
  Future<Response> getMessages(String conversationId, int page) async {
    return await _dio.get('/chat/$conversationId/messages', queryParameters: {
      'page': page,
      'limit': 50,
    });
  }
  
  Future<Response> sendMessage(Map<String, dynamic> messageData) async {
    return await _dio.post('/chat/messages', data: messageData);
  }
  
  // Upload endpoints
  Future<Response> uploadImage(File imageFile, {String? folder}) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
      if (folder != null) 'folder': folder,
    });
    
    return await _dio.post('/upload/image', data: formData);
  }
  
  // Ethiopian-specific endpoints
  Future<Response> getEthiopianRegions() async {
    return await _dio.get('/ethiopia/regions');
  }
  
  Future<Response> getEthiopianCities(String regionId) async {
    return await _dio.get('/ethiopia/regions/$regionId/cities');
  }
  
  Future<Response> getEthiopianHolidays(int year) async {
    return await _dio.get('/ethiopia/holidays/$year');
  }
  
  // Helper methods
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  bool isSuccess(Response response) {
    return response.statusCode != null && 
           response.statusCode! >= 200 && 
           response.statusCode! < 300;
  }
  
  Map<String, dynamic> parseResponse(Response response) {
    try {
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': 'Invalid response format'};
    }
  }
  
  String? getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        if (data is Map && data.containsKey('error')) {
          return data['error'];
        }
      }
      return error.message;
    }
    return error.toString();
  }
}

// API Response model
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: fromJsonT != null && json['data'] != null 
          ? fromJsonT(json['data']) 
          : json['data'] as T?,
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value)? toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': toJsonT != null && data != null 
          ? toJsonT(data as T) 
          : data,
      'error': error,
      'statusCode': statusCode,
    };
  }
}

// API constants
class ApiEndpoints {
  static const String baseUrl = Constants.apiBaseUrl;
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Products
  static const String products = '/products';
  static String product(String id) => '/products/$id';
  
  // Orders
  static const String orders = '/orders';
  static String order(String id) => '/orders/$id';
  static String cancelOrder(String id) => '/orders/$id/cancel';
  
  // Users
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  
  // Chat
  static const String conversations = '/chat/conversations';
  static String messages(String conversationId) => '/chat/$conversationId/messages';
  static const String sendMessage = '/chat/messages';
  
  // Upload
  static const String uploadImage = '/upload/image';
  
  // Ethiopian
  static const String ethiopianRegions = '/ethiopia/regions';
  static String ethiopianCities(String regionId) => '/ethiopia/regions/$regionId/cities';
  static String ethiopianHolidays(int year) => '/ethiopia/holidays/$year';
}

// Dio singleton for easy access
Dio get dio => ApiService()._dio;