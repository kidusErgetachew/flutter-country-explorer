import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import 'api_exception.dart';

class CountryApiService {
  final String _baseUrl = 'restcountries.com';
  final Duration _timeout = const Duration(seconds: 10);
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static List<Country>? _cache;
  static DateTime? _lastFetchTime;
  
  bool isFromCache = false;

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to load data',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<Country>> getAllCountries() async {
    if (_cache != null && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference.inMinutes < 5) {
        isFromCache = true;
        return _cache!;
      }
    }

    isFromCache = false;
    try {
      final uri = Uri.https(_baseUrl, '/v3.1/all', {
        'fields': 'name,flag,region,population,capital,cca3'
      });
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);
      
      _checkResponse(response);
      
      final List<dynamic> decodedJson = jsonDecode(response.body);
      _cache = decodedJson.map((json) => Country.fromJson(json)).toList();
      _lastFetchTime = DateTime.now();
      return _cache!;
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Unexpected data format received');
    }
  }

  Future<List<Country>> findCountriesByName(String name) async {
    try {
      final uri = Uri.https(_baseUrl, '/v3.1/name/$name');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);
          
      _checkResponse(response);
      
      final List<dynamic> decodedJson = jsonDecode(response.body);
      return decodedJson.map((json) => Country.fromJson(json)).toList();
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Unexpected data format received');
    }
  }

  Future<Country> getCountryDetailsByCode(String code) async {
    try {
      final uri = Uri.https(_baseUrl, '/v3.1/alpha/$code');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);
          
      _checkResponse(response);
      
      final List<dynamic> decodedJson = jsonDecode(response.body);
      return Country.fromJson(decodedJson.first);
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Unexpected data format received');
    }
  }
}
